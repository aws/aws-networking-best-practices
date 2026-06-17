# Remote Access

!!! info "Prerequisites"
    This section assumes familiarity with [Amazon VPC](../foundation/vpc.md) and [AWS Organizations](../foundation/organizations.md). Review those topics first if you're new to AWS networking fundamentals.

Giving authorized users and devices access to internal AWS applications is a distinct architectural concern from infrastructure connectivity. AWS provides two services that address it from opposite directions: [AWS Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-user/what-is.html) places the user on the network so they can reach applications by IP, while [AWS Verified Access](https://docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html) places the application behind a zero-trust policy engine that authenticates and authorizes every request based on identity and device posture, with no VPN client involved. Both services work independently of whether your environment has hybrid connectivity — a pure-cloud organization needs remote access just as much as one with Direct Connect circuits.

For new application access use cases, AWS Verified Access is the preferred option. Zero-trust application access scales better across large numbers of applications and users, removes the operational burden of maintaining VPN clients and endpoint certificates, and enforces per-request policies that are hard to replicate at the network layer.

## AWS Client VPN

AWS Client VPN is a managed OpenVPN-compatible service that gives end users a network-level connection into a VPC. Each connected client receives an IP address from a client CIDR you configure, and can reach resources in the associated VPC (and, through transit paths, other VPCs and on-premises networks). Authentication supports Active Directory, SAML-based federation with identity providers such as AWS IAM Identity Center, and certificate-based mutual authentication.

Client VPN fits when applications genuinely need network-layer reachability: administrators using SSH or RDP to reach EC2 instances, developers using tools that require direct IP connectivity, or legacy applications that authenticate clients by IP address. It also fits established workflows where users are already trained on a VPN client and the applications haven't been refactored for identity-aware access.

### AWS Client VPN Best Practices

#### Use split-tunnel by default

Unless a specific compliance requirement justifies full-tunnel, use split-tunnel so only AWS-destined traffic goes through Client VPN and general internet traffic exits the client's local network directly. Full-tunnel multiplies egress cost and concentrates load on the VPN endpoint. Split-tunnel also improves the user experience — latency-sensitive traffic (video calls, streaming) stays on the local internet path.

#### Define authorization rules, not just routes

Client VPN authorization rules control which users can reach which destinations. Route tables alone allow traffic to flow; without matching authorization rules, users can still reach destinations that their role shouldn't access. Design authorization rules around job functions: administrators get SSH/RDP access to management subnets, developers get access to application VPCs, and general users get access only to the specific applications they need.

#### Plan the client CIDR to avoid conflicts

The client CIDR (the IP range assigned to connected VPN clients) must not overlap with the VPC CIDR, any peered VPCs, on-premises networks, or other VPN client pools. Use a dedicated range from your IPAM plan — a `/16` from the `172.16.0.0/12` space is a common choice that avoids conflicts with the `10.0.0.0/8` space typically used for VPCs and on-premises.

#### Scale by endpoint count, not just Availability Zone

A Client VPN endpoint supports many concurrent connections, but sizing should account for peak simultaneous users, not just steady-state. Monitor `ActiveConnectionsCount` and `CrlDaysToExpiry` in CloudWatch. For organizations with thousands of concurrent users, consider multiple endpoints segmented by user population or application group.

## AWS Verified Access

AWS Verified Access provides zero-trust access to corporate applications without a VPN client. Users reach an application through a browser or an application-specific client, and Verified Access evaluates every request against a policy that combines identity (from AWS IAM Identity Center or a third-party identity provider) and device posture (from an integrated device-trust provider such as CrowdStrike or a mobile-device-management vendor). Requests that don't satisfy the policy are rejected. Requests that satisfy it are forwarded to the application.

Verified Access supports both web-based applications (HTTP/HTTPS) and non-web applications reached over TCP, SSH, or RDP, so it covers most of the use cases that previously required Client VPN. The policies are centrally managed in AWS, expressed in Cedar policy language, and evaluated per-request, which gives you fine-grained control that network-layer access can't provide (for example, blocking access when a device's posture check fails even though the user is authenticated).

### AWS Verified Access Best Practices

#### Start with Verified Access for every new application access use case

For new application access use cases, AWS Verified Access is the preferred option because:

* **No VPN client to deploy, distribute, or maintain on endpoints.** Users reach applications through standard clients they already use (browsers or protocol-specific clients).
* **Per-request policy evaluation** with identity and device posture, instead of the all-or-nothing trust model of a network connection.
* **Comprehensive logging** of every access attempt (allow and deny), with reason, user, and device context. This is harder to reconstruct from VPN connection logs plus application logs separately.
* **Simpler operational model** at scale. Onboarding a new application means adding a Verified Access endpoint and a policy, rather than expanding VPN authorization rules and re-propagating routes.

#### Integrate device trust from day one

Verified Access policies are most valuable when they combine identity *and* device posture. Connect a device-trust provider (CrowdStrike, Jamf, or another MDM/EDR vendor) at deployment time, not as a later enhancement. A policy that only checks identity is little better than a traditional SSO check; adding device posture (Is the OS patched? Is disk encryption enabled? Is the EDR agent running?) is what makes Verified Access genuinely zero-trust.

#### Use Cedar policies for fine-grained, auditable access control

Cedar, the policy language Verified Access uses, supports conditions on user attributes, group membership, device posture signals, and request attributes (IP, time, application). Write explicit policies per application rather than broad "allow all authenticated users" rules. Fine-grained policies are easier to audit, easier to explain to compliance teams, and reduce the blast radius of a compromised credential.

#### Migrate from Client VPN incrementally

Where Verified Access doesn't fit today, Client VPN remains available, and the two can coexist during migration. The recommended pattern:

1. Deploy Verified Access for new applications from day one
2. Migrate existing applications to Verified Access as their lifecycle allows (typically during the next major update or security review)
3. Gradually reduce Client VPN scope to the cases that genuinely require network-layer access (SSH, RDP, legacy protocols)
4. Consolidate on Verified Access over time as the application portfolio modernizes

The [Client VPN and Verified Access interoperability patterns](https://aws.amazon.com/blogs/networking-and-content-delivery/aws-client-vpn-and-aws-verified-access-migration-and-interoperability-patterns/) cover these migration paths in detail.

## When to use each service

**AWS Verified Access** is the right choice when:

* Users need access to web applications (HTTP/HTTPS) or TCP/SSH/RDP services
* You want per-request identity and device posture evaluation
* You want to eliminate VPN client deployment and maintenance
* You're onboarding new applications to remote access

**AWS Client VPN** is the right choice when:

* Applications require full network-layer IP reachability (not just application-level access)
* Users need access to broad network ranges rather than specific applications
* Legacy protocols or workflows depend on the user having a routable IP inside the VPC
* The organization has established VPN-based workflows that haven't been migrated yet

AWS Client VPN is **not** the long-term answer for application access. For any new application, start with Verified Access and use Client VPN only for the genuine network-layer cases.

## Documentation

<div class="grid cards" markdown>

*   :material-file-document: **AWS Client VPN documentation**

    ---

    Complete service documentation covering endpoints, authentication methods, authorization rules, and split-tunnel configuration.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-user/what-is.html)

*   :material-file-document-outline: **AWS Verified Access documentation**

    ---

    Complete service documentation covering endpoints, policies in Cedar, identity and device trust providers, and supported application types.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html)

*   :material-post: **AWS Client VPN and Verified Access interoperability patterns**

    ---

    Four migration and interoperability patterns for running Client VPN and Verified Access side by side during a transition.

    [:octicons-arrow-right-24: Blog post](https://aws.amazon.com/blogs/networking-and-content-delivery/aws-client-vpn-and-aws-verified-access-migration-and-interoperability-patterns/)

*   :material-currency-usd: **AWS Verified Access pricing**

    ---

    Per-application-hour and per-GB data processing charges for Verified Access endpoints.

    [:octicons-arrow-right-24: Pricing](https://aws.amazon.com/verified-access/pricing/)

</div>

## Related pages

**Relationship to other Connectivity topics:**

* **[Hybrid & Multi-Cloud Connectivity](hybrid-multicloud.md)** — Hybrid connectivity provides the infrastructure-level path between on-premises and AWS. Remote access provides the user-level path to applications. The two are independent: Verified Access and Client VPN work without any hybrid connectivity in place.

**Relationship to Security topics:**

* **[Network Segmentation](../security/segmentation.md)** — Verified Access auth policies provide identity-based segmentation at the application boundary. Client VPN authorization rules provide network-level segmentation for VPN users.
