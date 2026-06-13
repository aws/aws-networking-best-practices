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

When workloads in AWS need to resolve on-premises domain names (for example, `corp.example.com`), create Resolver outbound endpoints and forwarding rules that send those queries to on-premises DNS servers over Direct Connect or VPN. Conversely, when on-premises workloads need to resolve AWS private hosted zone names, create Resolver inbound endpoints that on-premises DNS servers forward to.

Design the forwarding rules to be as specific as possible. Forward `corp.example.com` to on-premises, not `.` (the root). A wildcard forward rule sends all DNS traffic to on-premises, which adds latency to every query, creates a dependency on hybrid connectivity for all DNS resolution, and bypasses DNS Firewall for forwarded queries.

#### Deploy Resolver endpoints across multiple Availability Zones

Resolver inbound and outbound endpoints create ENIs in the subnets you specify. Deploy at least two ENIs across two Availability Zones for each endpoint. A single-AZ endpoint is a single point of failure for all DNS resolution that depends on it — which in hybrid environments means all cross-boundary name resolution fails if that Availability Zone has an issue.

***Key insight:*** *DNS is the most failure-sensitive dependency in any network. A 30-second DNS resolution failure causes cascading timeouts across every service that makes outbound calls. Design DNS infrastructure for the same availability standard as your most critical workload.*

### Multi-account DNS sharing

#### Use Route 53 Profiles for multi-account DNS distribution

Route 53 Profiles let you bundle private hosted zone associations, Resolver forwarding rules, and DNS Firewall rule groups into a single profile that you share via AWS RAM at the OU level. New accounts added to the OU inherit the full DNS configuration automatically — no custom automation, no cross-account Lambda functions, no manual association steps.

Without Profiles, sharing DNS configuration across accounts requires per-account private hosted zone associations (one API call per VPC per hosted zone), per-account forwarding rule shares, and per-account DNS Firewall associations. That automation is fragile and hard to audit. Profiles replace it with a first-class operation.

#### Centralize private hosted zone ownership in the networking account

Create and manage private hosted zones in your centralized networking account. Share them to consuming accounts through Route 53 Profiles. This gives the networking team control over the authoritative DNS namespace while letting application teams create records in delegated sub-zones where appropriate.

The alternative — letting each account create its own private hosted zones — fragments the namespace, creates resolution conflicts when zones overlap, and makes DNS Firewall and query logging harder to implement consistently.

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

For detailed DNS Firewall best practices and integration with other egress controls, see [Outbound Controls](../security/outbound.md).

#### Enable Resolver query logging for visibility and forensics

Resolver query logging captures every DNS query made from associated VPCs — the query name, type, response code, source IP, and timestamp. Deliver logs to S3 for cost-effective retention and Athena querying, or to CloudWatch Logs for real-time alerting on suspicious resolution patterns (queries for known C2 domains, high-frequency NXDOMAIN responses, unusual query volumes from a single source).

Query logging is the DNS equivalent of VPC Flow Logs: it provides a complete record of what your workloads tried to reach by name. Without it, investigating DNS-related incidents (exfiltration over DNS tunneling, C2 callbacks, misconfigured forwarding) requires guesswork.

### IPv6 considerations

#### Configure dual-stack Resolver endpoints from the start

Resolver inbound and outbound endpoints support IPv6 ENI addresses. If your VPCs are dual-stack, configure Resolver endpoints with both IPv4 and IPv6 addresses so IPv6-only workloads can forward and resolve without NAT64. On-premises DNS servers forwarding to AWS inbound endpoints need reachability to the endpoint's IPv6 address if the on-premises network is also dual-stack.

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

*   :material-post: **Route 53 blog posts**

    ---

    Architecture patterns, feature announcements, and implementation guides from the AWS Networking and Content Delivery blog.

    [:octicons-arrow-right-24: Blog posts](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/amazon-route-53/)

</div>

## Related pages

**Relationship to other Foundation topics:**

* **[Amazon VPC](vpc.md)**: Every VPC gets a Route 53 Resolver automatically. VPC design (number of VPCs, account placement) determines how many private hosted zone associations and Resolver endpoints you need.
* **[AWS Organizations](organizations.md)**: Route 53 Profiles share DNS configuration at the OU level. Your OU structure determines how DNS configuration is distributed.

**Relationship to Connectivity topics:**

* **[Hybrid & Multi-Cloud Connectivity](../connectivity/hybrid-multicloud.md)**: Resolver endpoints and forwarding rules are the DNS complement to Direct Connect and VPN — they enable name resolution across the hybrid boundary that the connectivity layer provides at the network level.

**Relationship to Security topics:**

* **[Outbound Controls](../security/outbound.md)**: DNS Firewall is covered in depth on the Outbound Controls page as the first layer of egress defense. This page covers DNS Firewall from the architecture and deployment perspective; Outbound Controls covers it from the security policy perspective.

**Relationship to Application Networking topics:**

* **[Service to Service](../application-networking/service-to-service.md)**: Private hosted zones and Route 53 alias records are the primary service discovery mechanism covered on that page. DNS architecture decisions directly shape how services find each other.
