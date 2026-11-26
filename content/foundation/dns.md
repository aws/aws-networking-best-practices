# DNS Architecture

!!! info "Prerequisites"
    This section assumes familiarity with [Amazon VPC](vpc.md), [AWS Organizations](organizations.md), and [CIDR Planning](cidr.md). Review those pages first if you're new to AWS networking fundamentals.

Amazon Route 53 Resolver handles every DNS query made from within a VPC — answering queries for private hosted zones, forwarding queries for on-premises domains over hybrid connections, and resolving public internet names, all without deploying any DNS infrastructure. In a multi-account AWS environment, DNS decisions cascade into service discovery, hybrid connectivity, and security posture: a misconfigured forwarding rule silently breaks resolution for an entire account, an unshared private hosted zone makes a service invisible to consumers in other VPCs, and the absence of DNS Firewall leaves every workload able to resolve (and therefore reach) any domain on the internet.

DNS in AWS operates across three layers that must be designed together: **resolution** (how queries are answered), **sharing** (how DNS configuration reaches all accounts), and **security** (how DNS is used as a control point for outbound traffic). Route 53 Resolver is the resolution engine, Route 53 Profiles distribute configuration at scale, and Route 53 Resolver DNS Firewall applies domain-based filtering at the DNS layer.

## Key capabilities

<div class="grid cards" markdown>

*   :material-dns: **Route 53 Resolver**

    ---

    The default recursive resolver in every VPC. Answers queries for private hosted zones, forwards queries for on-premises domains via Resolver endpoints, and resolves public DNS — all automatically.

*   :material-share-variant: **Route 53 Profiles**

    ---

    Distribute private hosted zone associations, Resolver forwarding rules, and DNS Firewall rule groups across accounts at the OU level. New accounts inherit DNS configuration automatically.

*   :material-lock: **Private hosted zones**

    ---

    DNS namespaces visible only to associated VPCs. Used for internal service names, split-horizon DNS (different answers for internal vs. external queries), and custom domain names for VPC Lattice and PrivateLink endpoints.

*   :material-arrow-right-bold: **Resolver endpoints**

    ---

    Inbound endpoints let on-premises DNS servers resolve AWS private hosted zones. Outbound endpoints let VPC workloads resolve on-premises domains by forwarding to on-premises DNS servers.

*   :material-earth: **Route 53 Global Resolver**

    ---

    A managed DNS resolver for clients outside your VPCs, such as branch offices, on-premises sites, and remote users. Resolves public domains and private hosted zones from anycast addresses in the Regions you choose, with DNS filtering, over the internet or over AWS Cloud WAN.

*   :material-shield-lock: **DNS Firewall**

    ---

    Domain-based filtering at the DNS resolution layer. Block, allow, or alert on queries to specific domains before the workload ever connects. The cheapest and broadest egress control available.

*   :material-ip-network: **Dual-stack support**

    ---

    Resolver endpoints, forwarding rules, and DNS Firewall all support both IPv4 and IPv6. AAAA records in private hosted zones work alongside A records for dual-stack workloads.

</div>

## Best Practices

### Resolution architecture

#### Use Route 53 Resolver as the sole DNS resolver for all VPCs

Every VPC gets a Route 53 Resolver at the VPC+2 address automatically. Do not deploy custom DNS servers (BIND, Active Directory DNS, CoreDNS outside of Kubernetes) as the primary resolver for VPC workloads. Custom resolvers add an operational burden (patching, scaling, monitoring), introduce a single point of failure that Route 53 Resolver does not have, and bypass Route 53 features (DNS Firewall, query logging, Resolver rules). The only justified exception is Active Directory-joined Windows workloads that require AD DNS for domain-joined resolution — and even those should forward non-AD queries back to Route 53 Resolver.

#### Design forwarding rules for hybrid DNS resolution

When workloads in AWS need to resolve on-premises domain names (for example, `corp.example.com`), create Resolver outbound endpoints and forwarding rules that send those queries to on-premises DNS servers over Direct Connect or VPN. Conversely, when on-premises workloads need to resolve AWS private hosted zone names, create Resolver inbound endpoints that on-premises DNS servers forward to. For branch offices, on-premises sites, and remote users that you want to serve from one multi-Region anycast address set, [Route 53 Global Resolver](#global-resolver-for-clients-outside-vpcs) is the alternative to per-Region inbound endpoints. Outbound endpoints are still required for VPC workloads that resolve on-premises domains.

Design the forwarding rules to be as specific as possible. Forward `corp.example.com` to on-premises, not `.` (the root). A wildcard forward rule sends all DNS traffic to on-premises, which adds latency to every query, creates a dependency on hybrid connectivity for all DNS resolution, and bypasses DNS Firewall for forwarded queries.

#### Deploy Resolver endpoints across multiple Availability Zones

Resolver inbound and outbound endpoints create ENIs in the subnets you specify. Deploy at least two ENIs across two Availability Zones for each endpoint. A single-AZ endpoint is a single point of failure for all DNS resolution that depends on it — which in hybrid environments means all cross-boundary name resolution fails if that Availability Zone has an issue.

***Key insight:*** *DNS is the most failure-sensitive dependency in any network. A 30-second DNS resolution failure causes cascading timeouts across every service that makes outbound calls. Design DNS infrastructure for the same availability standard as your most critical workload.*

### Global Resolver for clients outside VPCs

#### Use Route 53 Global Resolver for branch offices, on-premises sites, and remote users

Route 53 Global Resolver answers DNS queries from authorized clients outside your VPCs. It resolves public domains and the private hosted zones you associate with a DNS view, and clients reach it on anycast IP addresses that route each query to the closest of the two or more Regions you select. If a Region becomes unavailable, queries fail over to the next closest Region ([how it works](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-how-it-works.html)). Clients use one set of addresses instead of per-Region forwarding rules, and DNS filtering applies to these clients through the view.

Choose between Global Resolver and Resolver inbound endpoints by where the clients are and what already exists:

* Choose Global Resolver for multi-Region anycast, no per-Region forwarding, and DNS filtering for clients that are not in a VPC.
* Keep inbound endpoints when resolution must stay inside specific VPCs, or when you run an existing resolver estate that you are not replacing.

Keep VPC workloads on the VPC Resolver as described above. It is built in, works with Route 53 Profiles, per-VPC DNS Firewall, and Resolver query logging, and has no access-source authorization to manage. This is a recommendation, not a limitation: the [AWS blog](https://aws.amazon.com/blogs/networking-and-content-delivery/hybrid-dns-with-amazon-route-53-global-resolver-for-private-connections-on-aws-cloud-wan/) shows VPC instances querying Global Resolver over Cloud WAN. If you send VPC workloads to Global Resolver anyway, you manage a second authorization model and a second place to apply filtering and logging, and you give up the per-VPC controls. Outbound endpoints and forwarding rules are still how VPC workloads reach on-premises domains.

Plan cost before you choose the number of Regions. The [Route 53 pricing page](https://aws.amazon.com/route53/pricing/) bills a charge per Region per hour and a charge per query, and bills internet access and private (Cloud WAN) access separately.

Plan IPv6 from the start. The resolver address type is IPv4 by default, and dual-stack adds IPv6 anycast addresses ([CreateGlobalResolver](https://docs.aws.amazon.com/Route53/latest/APIReference/API_route53globalresolver_CreateGlobalResolver.html)). Choose dual-stack when clients or sites use dual-stack or IPv6, and treat IPv6 access sources as their own dimension on the [quotas page](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-load-balancer-limits.html), separate from IPv4 access sources.

#### Choose the access path and keep authorization narrow

A global resolver can be reached over the internet, over AWS Cloud WAN, or both. Over the internet, authorize clients with access sources (CIDR ranges, for DNS over port 53 (Do53), DNS over TLS (DoT), and DNS over HTTPS (DoH)) or access tokens (DoT and DoH only), as described in [managing access controls](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-managing-access-controls.html). Use access sources for offices and VPN egress with predictable addresses, and tokens for mobile or remote users whose addresses change. Access sources rely on trusting the source IP address, so keep the ranges as narrow as the clients allow.

If every client is on a private network, turn public IP connectivity off so the resolver is reachable only from a connected core network. There are two ways to do this ([CreateGlobalResolver](https://docs.aws.amazon.com/Route53/latest/APIReference/API_route53globalresolver_CreateGlobalResolver.html)). Disabled with the anycast addresses kept reserved lets you re-enable public access later with the same addresses. Disabled with the addresses released frees them, so clients configured with those addresses stop working and the resolver cannot get the same addresses back. Use reserved unless you are certain you do not need the addresses again.

#### Plan the Cloud WAN connection deliberately

Connecting a core network endpoint makes the core network's segments available as access sources in every Region where the resolver runs, so connect only core networks you trust as DNS sources. Plan the following before you create the endpoint ([core network endpoints](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-core-network-endpoints.html), [AWS blog](https://aws.amazon.com/blogs/networking-and-content-delivery/hybrid-dns-with-amazon-route-53-global-resolver-for-private-connections-on-aws-cloud-wan/)):

* One global resolver connects to one core network through one core network endpoint.
* The endpoint needs at least two Regions, taken from the resolver's Regions. The number of private IP addresses per endpoint is limited, so check the [quotas page](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-load-balancer-limits.html). Each IP address can be associated with a different subset of Regions, which lets you steer clients to different Regions and gives them a second IP for redundancy. Associate each IP address with two or more Regions so it can fail over.
* Keep resolver IP addresses from conflicting with the network's CIDR blocks or the core network's inside CIDR blocks, and do not route public IP addresses externally. If they overlap, traffic to the resolver address can follow the wrong route.
* Align the Region sets deliberately. Only Regions that are part of both the global resolver and the core network can provide resolution, so a Region present in only one of them gives clients no resolution path from that Region.
* Use core network policy version 2026.10 or later so queries route to the closest Region. With that version, Cloud WAN breaks ties between equivalent cross-Region routes with a default Multi-Exit Discriminator (MED). If you have not set a routing preference, traffic to destinations with multiple equivalent routes can shift to a different Region once, when the update takes effect. Set the preference with an edge location routing policy before you update to keep traffic on the intended path. See [policy versions](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-policies-json.html#cloudwan-version-json).
* Map DNS views to segments on purpose. Clients in a segment are authorized through the view whose access source references it.
* If the resolver does not run in the Region of a Direct Connect interface, queries are ECMP'd across all the resolver's Regions on the same continent instead of going to the closest one. Consider running the resolver in the Regions where your Direct Connect interfaces terminate.
* Transit Gateway and Direct Connect gateway topologies can also use a private connection to the resolver, as long as there is a path from the transit gateway to the Cloud WAN network.

#### Use DNS views to separate client groups

A DNS view has its own access sources, tokens, firewall rules, and private hosted zone associations ([managing DNS views](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-manage-dns-views.html)). Create separate views for groups with different security needs, locations, or device types, and give each view only the zones and access it needs. Three view settings need a deliberate choice:

* **DNSSEC validation** applies to public domains only. Invalid signatures return `SERVFAIL`.
* **EDNS Client Subnet** sends a partial client address (up to a /24 for IPv4 or a /48 for IPv6) to authoritative servers. It can improve CDN routing, and it is a privacy trade-off.
* **Firewall fail open** is disabled by default, so queries are blocked when firewall rules can't be evaluated. Enable it only where availability matters more than filtering.

Four quota dimensions shape the view layout, and the [quotas page](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-load-balancer-limits.html) has the current values:

* **DNS views per resolver** limits how finely you can split client groups. Merge groups with the same security needs rather than creating a view for each office.
* **Firewall rules per view** limits how much filtering policy one client group can carry. Use domain lists to keep the rule count low.
* **Access sources per resolver** limits how many separate ranges you can authorize. Summarize ranges where the clients allow.
* **Total access source CIDR size per resolver** cannot be raised. Wide ranges consume this budget and also widen who can query, so authorize the narrowest ranges that cover your clients.

#### Apply DNS filtering and logging to these clients too

DNS Firewall rules in a view can allow, alert on, or block queries using custom or AWS managed domain lists, plus advanced protections against domain generation algorithms and DNS tunneling. This complements Route 53 Resolver DNS Firewall in VPCs; it does not replace it. Query logging is off unless you set an observability Region when you create the resolver ([CreateGlobalResolver](https://docs.aws.amazon.com/Route53/latest/APIReference/API_route53globalresolver_CreateGlobalResolver.html)). Without it there is no DNS record of what these clients resolved, which removes the forensics and detection value this practice describes. Logs go to a single destination Region you choose ([use cases](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-cloud-resolver-use-cases.html)), so pick that Region with your audit and retention requirements in mind. Deliver them to Amazon CloudWatch Logs, Amazon Data Firehose, or Amazon S3.

***Key insight:*** *The access and authorization model, meaning who may query and through which view, drives every other Global Resolver decision. Settle it before Regions, addresses, and logging.*

### Multi-account DNS sharing

#### Use Route 53 Profiles for multi-account DNS distribution

Route 53 Profiles let you bundle private hosted zone associations, Resolver forwarding rules, and DNS Firewall rule groups into a single profile that you share via AWS RAM at the OU level. New accounts added to the OU inherit the full DNS configuration automatically — no custom automation, no cross-account Lambda functions, no manual association steps.

Without Profiles, sharing DNS configuration across accounts requires per-account private hosted zone associations (one API call per VPC per hosted zone), per-account forwarding rule shares, and per-account DNS Firewall associations. That automation is fragile and hard to audit. Profiles replace it with a first-class operation.

#### Share DNS views through AWS RAM, not Route 53 Profiles

Global Resolver has its own sharing model. A DNS view can be shared through AWS RAM so other accounts can associate their own private hosted zones with it without transferring ownership of the zone or the view ([sharing DNS views](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-sharing-dns-views.html)). This is separate from Route 53 Profiles, which cover VPCs. Four points matter for governance:

* **Grant associate-only by default.** Use the default AWS RAM managed permission, which lets the consumer view the shared view and associate its own hosted zones. The other managed permissions let a consumer update, enable, or disable the shared view, and a change to the view affects every client of that view in every Region. Granting more than association is a governance risk, not a convenience.
* **Default to central ownership of zone associations.** A shared view lets consumers publish names that resolve for every client of the view. Have the networking account associate the zones, and use consumer-owned associations only for delegated sub-zones. Per-account zones fragment the namespace, as described below.
* **Residency.** The consumer's hosted zone ID and domain name are copied to every Region where the owner's resolver runs, including opt-in Regions the consumer has not enabled, so share views only with accounts you trust and check data residency requirements.
* **Stopping a share is not removal.** Stopping the share does not remove existing associations: they keep resolving until the owner or the consumer removes them.

#### Centralize private hosted zone ownership in the networking account

Create and manage private hosted zones in your centralized networking account. Share them to consuming accounts through Route 53 Profiles. This gives the networking team control over the authoritative DNS namespace while letting application teams create records in delegated sub-zones where appropriate.

The alternative — letting each account create its own private hosted zones — fragments the namespace, creates resolution conflicts when zones overlap, and makes DNS Firewall and query logging harder to implement consistently.

This also applies to VPC Lattice resource configurations: if a consumer VPC has a private hosted zone for the same domain as a custom domain name that VPC Lattice would manage, VPC Lattice reports `PrivateDnsAlreadyExists` and leaves your zone unchanged. See [Use custom domain names for stable consumer contracts](../connectivity/within-aws.md#use-custom-domain-names-for-stable-consumer-contracts) for how to resolve the overlap.

#### Design your internal namespace hierarchy deliberately

Choose a single internal domain (for example, `internal.example.com`) and create sub-zones per environment, Region, or service domain. A well-designed hierarchy makes DNS records self-documenting and enables route-based resolution policies:

```
internal.example.com           (root, networking account)
├── prod.internal.example.com  (production services)
├── dev.internal.example.com   (development services)
└── hybrid.internal.example.com (on-premises forwarding)
```

Avoid flat namespaces where hundreds of records pile into a single zone. Avoid overly deep hierarchies that create long, unreadable FQDNs. Two to three levels below the root is the sweet spot.

### DNS security

#### Deploy DNS Firewall in every VPC

Route 53 Resolver DNS Firewall is the cheapest and broadest egress control in AWS. It evaluates every DNS query made from a VPC against domain lists (managed threat intelligence lists from AWS, or your own custom lists) and can block, allow, or alert. Because virtually all outbound connections start with a DNS lookup, blocking resolution of a malicious domain prevents the connection from ever being attempted.

Deploy DNS Firewall rule groups via Route 53 Profiles so every VPC in the organization gets the same baseline protection. Layer with Network Firewall or third-party inspection for traffic that bypasses DNS (hardcoded IPs, DNS-over-HTTPS).

Beyond the managed threat lists, an [Automated Allowlist rule](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/firewall-advanced-automated-allowlists.html) is the practical route to allow-list mode (permit only approved domains and block the rest) when you do not know every domain your workloads need. DNS Firewall lists the domains your VPCs queried during a look-back period, and you review and approve them instead of writing the list from scratch. The rule requires the DNS Firewall Advanced tier and enforces nothing until you add a block-all rule after it, which you add only after you review the list, because an earlier block-all rule blocks legitimate traffic. See [Build the allow list with an Automated Allowlist rule](../security/outbound.md#build-the-allow-list-with-an-automated-allowlist-rule) in Outbound Controls for the rule order and the checks before you block.

For detailed DNS Firewall best practices and integration with other egress controls, see [Outbound Controls](../security/outbound.md).

#### Enable Resolver query logging for visibility and forensics

Resolver query logging captures every DNS query made from associated VPCs — the query name, type, response code, source IP, and timestamp. Deliver logs to S3 for cost-effective retention and Athena querying, or to CloudWatch Logs for real-time alerting on suspicious resolution patterns (queries for known C2 domains, high-frequency NXDOMAIN responses, unusual query volumes from a single source).

Query logging is the DNS equivalent of VPC Flow Logs: it provides a complete record of what your workloads tried to reach by name. Without it, investigating DNS-related incidents (exfiltration over DNS tunneling, C2 callbacks, misconfigured forwarding) requires guesswork.

#### Turn DNS query logs and DNS Firewall activity into metrics and alarms

To alert on DNS activity rather than just retain it, deliver Resolver query logs to CloudWatch Logs: metric filters, Contributor Insights, and Logs Insights run on log groups, not on the S3 copy you keep for forensics. DNS Firewall also publishes per-VPC and per-rule-group query-volume metrics to CloudWatch every few minutes, which you can alarm on directly without parsing logs.

Alarm on a baseline you establish, not a fixed count: query logs record only unique queries, so lookups answered from the cache are not logged and counts run low. Treat this as detection, not prevention — it sees only what reaches the resolver, so DNS-over-HTTPS and hardcoded-IP traffic bypass it; keep Network Firewall or other inspection for those.

### Protecting critical records

#### Protect critical records from accidental change

Route 53 record set protection rejects any `ChangeResourceRecordSets` request that creates, updates, or deletes records with a protected name and type, in public and private hosted zones. The protection applies to every principal, including those with full Route 53 permissions, so a direct change is blocked and a deliberate extra step is forced. It prevents accidents and is not a security boundary: a principal with broad permissions, such as `route53:*`, can also delete the protection and then change the record (see the permission guidance below). Use it for records that rarely change and would cause an outage if changed by mistake, such as the apex records of a production domain, MX records, and records that route traffic to critical endpoints. Protect only the few records where a mistake is expensive. Each protection turns a routine change into a privileged two-step change, and the number of protections per hosted zone is limited by a [quota](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html#limits-api-entities-records), so protecting broadly slows down routine changes and can exhaust that quota.

Know how it behaves before you rely on it:

* **Scope is name and type.** One protection covers every record with that name and type, whatever its set identifier. You can't protect only some of a set of weighted records. The type is part of the scope: a protection on `A` doesn't cover `AAAA` for the same name, so a dual-stack name needs one protection for each. With only `A` protected, someone can still change or delete the `AAAA` record, and IPv6 clients fail while IPv4 clients keep working, which is a partial outage that is hard to spot.
* **Rejection is whole-batch.** If any change in a request touches a protected name and type, Route 53 rejects the entire request with `InvalidChangeBatch` and applies none of it. A change that touches a protected record fails in the AWS CLI, the AWS SDKs, and AWS CloudFormation; the [Route 53 documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/rrset-protection.html#rrset-protection-blocked-changes) and the [CloudFormation reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-route53-recordsetprotection.html#aws-resource-route53-recordsetprotection--remarks) name the error differently (`InvalidChangeBatch` and `ResourceConflict`), so don't key a runbook or alarm to one error name.
* **CloudFormation updates are ordered.** CloudFormation deletes a removed protection only in its cleanup phase, after it changes the record, so a stack update that changes a protected record and removes its protection fails. Adding a protection and changing the same record in one update can leave the stack in a failed rollback state, and changing a protection's comment replaces it, so the record is unprotected during the replacement. A protection that stays behind, for example with `DeletionPolicy: Retain`, blocks deleting the record and fails teardown. Ship record changes and protection changes as separate stack updates or pipeline stages, and let one pipeline own removal of stray protections. The CloudFormation reference describes the procedures.
* **A protection can reserve a name.** You can create one for a name and type that has no records yet, which stops anyone from creating that record.
* **Write a useful comment.** The optional comment (up to 256 characters) appears in the error when a change is rejected. Say why the record is protected and whom to contact.

Changing a protected record is deliberate: delete the protection, make the change, then create the protection again. A protection can't be edited, so changing its comment also means deleting and recreating it. Plan this into your change process and runbooks. Until the protection is recreated, any principal with change permission can alter the record, and if the change step fails and nothing recreates the protection, the record stays unprotected with no signal. Have automation treat delete, change, and recreate as one unit that restores the protection on failure, and alert on `DeleteResourceRecordSetProtections` calls: [AWS CloudTrail](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/logging-using-cloudtrail.html) logs requests to create, delete, and list protections.

Protections are only as strong as who can remove them. Any principal with `route53:DeleteResourceRecordSetProtections` on the hosted zone can delete any protection in it, and the three record set protection actions (create, delete, and list) support only the hosted zone resource and no service-specific condition keys. Grant that permission to a small set of administrators and consider denying it to everyone else. In an AWS Organizations environment where a networking account owns the hosted zones, apply a [service control policy](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) (SCP) deny at the OU that contains the accounts that own hosted zones, and exempt the central DNS or networking admin role. SCPs don't apply to the management account, and because the actions have no condition keys you can't allow removal of some protections and deny others in the same zone. The protection is only as strong as the broadest delete grant.

A hosted zone that has any protections, including protections on names with no records, can't be deleted. Add a step to teardown automation that lists and deletes the protections first.

Protections don't change how Route 53 answers DNS queries. They only control changes to records.

***Key insight:*** *Record set protection prevents accidents, not deliberate changes. It is only as strong as the control over who can delete protections.*

For the console and CLI steps, see [Protecting records from changes](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/rrset-protection.html). For an example policy that denies removing protections, see [Example 5: Deny removal of record set protections](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/access-control-managing-permissions.html#access-policy-example-deny-delete-rrset-protections).

### IPv6 considerations

#### Configure dual-stack Resolver endpoints from the start

Resolver inbound and outbound endpoints support IPv6 ENI addresses. If your VPCs are dual-stack, configure Resolver endpoints with both IPv4 and IPv6 addresses so IPv6-only workloads can forward and resolve without NAT64. On-premises DNS servers forwarding to AWS inbound endpoints need reachability to the endpoint's IPv6 address if the on-premises network is also dual-stack.

#### Choose dual-stack when you create a Global Resolver

A global resolver uses IPv4 anycast addresses by default, and dual-stack adds IPv6 anycast addresses. If any branch, on-premises, or remote clients use IPv6, choose dual-stack so they can reach the resolver over IPv6 instead of depending on an IPv4 path. Plan IPv6 access sources separately from IPv4 access sources, because they are constrained by their own dimension. See [Global Resolver for clients outside VPCs](#global-resolver-for-clients-outside-vpcs).

#### Include AAAA records alongside A records in private hosted zones

For every internal service running on dual-stack infrastructure, publish both A and AAAA records in the private hosted zone. Applications that prefer IPv6 (or run IPv6-only) will use the AAAA record; IPv4-only consumers use the A record. This is the same principle as dual-stack VPC design: include IPv6 from the start rather than retrofitting later.

## When to use Route 53 Resolver features

Route 53 Resolver is always in use — it's the default resolver in every VPC. The decision is which additional features to enable:

**Private hosted zones** are the right choice when:

* You need internal DNS names for services, databases, or endpoints that should not be resolvable from the public internet
* You need split-horizon DNS (different answers for the same domain depending on whether the query comes from inside or outside AWS)

**Resolver endpoints and forwarding rules** are the right choice when:

* On-premises workloads need to resolve AWS private hosted zone names (inbound endpoints)
* AWS workloads need to resolve on-premises domain names (outbound endpoints + forwarding rules)
* You operate in a hybrid environment with any DNS dependency crossing the AWS boundary

**Route 53 Global Resolver** is the right choice when:

* Branch offices, on-premises sites, or remote users need to resolve private hosted zone names without a resolver endpoint in every Region
* You want one anycast address set with multi-Region failover and DNS filtering for clients outside VPCs
* You connect those clients over AWS Cloud WAN and want private-only DNS resolution

Global Resolver is **not** the right choice when:

* The clients are VPC workloads (use the VPC Resolver)
* A site needs conditional forwarding to an existing resolver estate and has no Cloud WAN or anycast need (use Resolver inbound endpoints)
* Clients cannot be authorized by source address, segment, or token (keep them on their existing resolver)

**Route 53 Profiles** are the right choice when:

* You operate more than a handful of accounts and need consistent DNS configuration across all of them
* You want new accounts to inherit DNS configuration automatically without custom automation

**DNS Firewall** is the right choice in every VPC — there is no scenario where you should not deploy at least the AWS managed threat domain lists.

## Documentation

<div class="grid cards" markdown>

*   :material-file-document: **Route 53 Resolver documentation**

    ---

    Complete documentation for Resolver endpoints, forwarding rules, query logging, and DNSSEC validation.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html)

*   :material-file-document: **Route 53 Profiles documentation**

    ---

    How to create, share, and manage Profiles for multi-account DNS configuration distribution.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/profiles.html)

*   :material-file-document: **Route 53 Resolver DNS Firewall**

    ---

    Domain-based filtering configuration, managed domain lists, and integration with Firewall Manager.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html)

*   :material-file-document: **Route 53 Global Resolver documentation**

    ---

    Concepts, DNS views, access control, core network endpoints, sharing, and quotas for Global Resolver.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/gr-what-is-global-resolver.html)

*   :material-file-document: **Protecting records from changes**

    ---

    How record set protections work, which records to protect, how rejected changes and zone deletion behave, and the permissions that control removal.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/rrset-protection.html)

*   :material-file-document: **AWS::Route53::RecordSetProtection**

    ---

    CloudFormation resource for managing protections, including update ordering, rollback behavior, and importing existing protections.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-route53-recordsetprotection.html)

*   :material-post: **Route 53 blog posts**

    ---

    Architecture patterns, feature announcements, and implementation guides from the AWS Networking and Content Delivery blog.

    [:octicons-arrow-right-24: Blog posts](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/amazon-route-53/)

</div>

## Related pages

**Relationship to other Foundation topics:**

* **[Amazon VPC](vpc.md)**: Every VPC gets a Route 53 Resolver automatically. VPC design (number of VPCs, account placement) determines how many private hosted zone associations and Resolver endpoints you need.
* **[AWS Organizations](organizations.md)**: Route 53 Profiles share DNS configuration at the OU level, and an SCP at the OU restricts who can remove record set protections. Your OU structure determines how DNS configuration is distributed and where that control applies.

**Relationship to Connectivity topics:**

* **[Hybrid & Multi-Cloud Connectivity](../connectivity/hybrid-multicloud.md)**: Resolver endpoints and forwarding rules are the DNS complement to Direct Connect and VPN — they enable name resolution across the hybrid boundary that the connectivity layer provides at the network level.

**Relationship to Security topics:**

* **[Outbound Controls](../security/outbound.md)**: DNS Firewall is covered in depth on the Outbound Controls page as the first layer of egress defense. This page covers DNS Firewall from the architecture and deployment perspective; Outbound Controls covers it from the security policy perspective.

**Relationship to Application Networking topics:**

* **[Service to Service](../application-networking/service-to-service.md)**: Private hosted zones and Route 53 alias records are the primary service discovery mechanism covered on that page. DNS architecture decisions directly shape how services find each other.

**Relationship to Observability topics:**

* **[AWS Services Monitoring](../observability/service-monitoring.md)**: Covers the existing Route 53 Resolver and DNS Firewall CloudWatch metrics (including `FirewallRuleGroupQueryVolume`) and dashboards that the DNS metrics-and-alarms guidance on this page builds on.
* **[Internal Traffic Monitoring](../observability/internal-traffic.md)**: Positions DNS query logging and DNS Firewall metrics as the DNS-layer signal alongside VPC, Transit Gateway, and Cloud WAN Flow Logs.
