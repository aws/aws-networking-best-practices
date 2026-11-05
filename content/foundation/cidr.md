# IP Address Planning with CIDR Blocks

!!! info "Prerequisites"
    This section assumes familiarity with [Before You Start](aws-prerequisites.md), [Amazon VPC](vpc.md), and [Regions and Availability Zones](regions-azs.md). Review those pages first if you're new to AWS networking fundamentals.

IP address planning is the single most consequential decision you make early in an AWS deployment that you cannot easily change later. Every VPC, every subnet, every peering connection, every hybrid link, and every route table is constrained by the CIDR blocks you chose at creation time. Get this right and your network scales cleanly for years. Get it wrong and you'll spend those years working around overlaps, exhausted address space, and connectivity constrained by overlapping ranges.

CIDR (Classless Inter-Domain Routing) notation is the language of IP address planning. It replaces the old classful system (Class A, B, C) with variable-length prefixes that let you carve address space into precisely the sizes you need. Every AWS networking service — VPC, Transit Gateway, Cloud WAN, Direct Connect, VPN — speaks CIDR. Mastering it is not optional.

![Hierarchical CIDR allocation from organization through environment, Region, VPC, to subnet](../assets/foundation/cidr-hierarchy.png)
/// caption
Hierarchical CIDR allocation — [Drawio Source](../assets/foundation/cidr-hierarchy.drawio)
///

***Key insight:*** *A hierarchical CIDR allocation — organization → environment → Region → VPC → subnet — is not just tidy bookkeeping. It enables route summarization, simplifies firewall rules, and makes your network topology legible to anyone who reads a route table.*

## Understanding CIDR Notation

CIDR notation represents IP address ranges using the format: `IP_ADDRESS/PREFIX_LENGTH`

**Example**: `10.0.0.0/16`

* **IP Address**: `10.0.0.0` — the network address (starting point of the range)
* **Prefix Length**: `/16` — the number of fixed bits in the network portion (the remaining bits are available for hosts)
* **Address Range**: `10.0.0.0` to `10.0.255.255` (65,536 addresses)
* **Subnet Mask**: `255.255.0.0`

The prefix length determines how many addresses the block contains: a `/16` has 2^(32-16) = 65,536 addresses. A shorter prefix means more addresses; a longer prefix means fewer. Every time you increase the prefix by 1, you halve the address space.

### Common CIDR Block Sizes

| CIDR | Addresses | Usable in Subnet* | Typical Use |
| --- | --- | --- | --- |
| /16 | 65,536 | 65,531 | Large VPC for enterprise environments, gives maximum room for subnets |
| /20 | 4,096 | 4,091 | Medium VPC, departmental or single-workload VPCs |
| /24 | 256 | 251 | Standard subnet size, balances density with manageability |
| /26 | 64 | 59 | Smaller subnets for firewall endpoints, NAT gateway, or TGW attachments |
| /28 | 16 | 11 | Minimum VPC or subnet size, used for specific services only |

*AWS reserves 5 IP addresses in each subnet (first four and last one).

### RFC 1918 Private Address Ranges

These are the private IP ranges available for your VPCs:

| Range | CIDR | Addresses | Recommendation |
| ------- | ------ | ----------- | ---------------- |
| 10.0.0.0 – 10.255.255.255 | 10.0.0.0/8 | 16,777,216 | **Preferred for most organizations.** Largest contiguous space, supports deep hierarchical allocation. |
| 172.16.0.0 – 172.31.255.255 | 172.16.0.0/12 | 1,048,576 | Good secondary range. Often already used by on-premises networks. |
| 192.168.0.0 – 192.168.255.255 | 192.168.0.0/16 | 65,536 | Avoid for production AWS use. Too small for multi-account environments and commonly used by home networks and VPN clients, causing overlap issues. |

### Additional Ranges for AWS Workloads

Beyond RFC 1918, AWS VPCs support these ranges:

* **100.64.0.0/10** (Carrier-Grade NAT range): Useful for EKS pod networking with the VPC CNI custom networking feature. Pods get IPs from this range, preserving your primary RFC 1918 space for nodes and other resources. Also used when RFC 1918 space is exhausted.
* **RFC 6815 space** (`198.19.0.0/16`): Available as a secondary CIDR for VPCs when other ranges are exhausted.

***Key insight:*** *The 100.64.0.0/10 range is a strategic tool for EKS-heavy environments. A single EKS cluster can consume thousands of IP addresses for pods. Assigning pod networking to 100.64.0.0/10 via custom networking keeps your primary VPC CIDR available for nodes, load balancers, and other infrastructure. For new clusters, an IPv6 cluster removes the pressure instead of relocating it: pods get IPv6 addresses and consume no IPv4 space at all.*

## Best Practices

### CIDR allocation strategy

#### Allocate contiguously for route summarization

The most important property of a good address plan is that allocations within the same logical group are **contiguous**, for IPv4 and IPv6 alike. Allocate top-down, from your organization's range to a block per Region and then per environment, so a single prefix covers each level. When all production VPCs in us-east-1 fall within `10.0.0.0/12` and `2001:db8::/40`, you advertise one summary route per address family to on-premises instead of one route per VPC. This matters because:

* Route tables and BGP sessions have finite [route capacity](../observability/service-monitoring.md#monitor-quotas-before-you-hit-them), and on-premises routers may support fewer routes than AWS services
* Fewer routes mean faster convergence after failures
* Summary routes simplify firewall rules — one rule covers an entire environment instead of per-VPC entries
* BGP advertisements to on-premises are cleaner and more stable

**Example multi-Region scheme** (IPv4 within `10.0.0.0/9` for AWS, IPv6 within a BYOIP `/32`):

| Region | IPv4 block | IPv6 block | Purpose |
| -------- | ----------- | ----------- | --------- |
| us-east-1 | `10.0.0.0/12` | `2001:db8::/40` | Primary Region |
| us-west-2 | `10.16.0.0/12` | `2001:db8:100::/40` | DR / Secondary |
| eu-west-1 | `10.32.0.0/12` | `2001:db8:200::/40` | European workloads |
| ap-southeast-1 | `10.48.0.0/12` | `2001:db8:300::/40` | Asia-Pacific workloads |
| Reserved | `10.64.0.0/10` | Rest of the `/32` | Future Regions |

Each IPv4 `/12` holds 16 `/16` or 256 `/20` VPCs. An IPv6 Regional pool supports VPC allocations sized for different subnet hierarchies, so in IPv6 the hierarchy exists for summarization and governance rather than scarcity. For publicly routable space without BYOIP, an Amazon-provided contiguous block provisioned to an IPAM Regional pool gives the same per-Region shape, without an organization-wide prefix above it. A private IPv6 ULA or GUA range in IPAM's private scope can provide an organization-wide hierarchy for internal-only addressing.

Non-contiguous allocation breaks summarization in both families. In IPv4 it comes from per-team numbering, such as production VPCs at `10.0.0.0/16` and `10.5.0.0/16` with development at `10.1.0.0/16` between them. In IPv6 it comes from VPCs that each request an Amazon-provided CIDR outside IPAM: each allocation is unrelated to the next, so every VPC is advertised and filtered individually.

***Key insight:*** *Reserve at least 50% of your total address space for future growth. Organizations consistently underestimate how many VPCs, accounts, and Regions they'll need in 3-5 years. Address space is free; running out of it is not.*

#### Retrofit summarization into an existing network

Most large networks were not allocated hierarchically, so every VPC prefix propagates individually through Transit Gateway or AWS Cloud WAN and to on-premises. The symptom appears late: route tables and BGP sessions approach their route limits, and teams look for a filtering feature when the root cause is the address plan. You cannot renumber everything at once.

Import existing VPC and on-premises ranges into IPAM to find the ones that already fall inside a summarizable block. Advertise those blocks now through Cloud WAN [routing policies](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-routing-policies.html), [allowed prefixes](https://docs.aws.amazon.com/directconnect/latest/UserGuide/allowed-to-prefixes.html) on a Direct Connect gateway association with Transit Gateway, or the on-premises router. Check each summary against the full inventory first: a summary that covers ranges living elsewhere attracts their traffic and black-holes it.

Reserve a summary block per Region in IPAM and allocate every new VPC from it. Move existing workloads onto [secondary CIDRs](#use-secondary-cidrs-strategically-not-as-a-crutch) from the new blocks as they are redeployed. Keep routes that cannot yet be summarized out of routing domains that do not need them through purpose-specific Transit Gateway route tables or Cloud WAN segments, as described in [Connectivity Within AWS](../connectivity/within-aws.md).

Track [route counts against their quotas](../observability/service-monitoring.md#monitor-quotas-before-you-hit-them) to measure convergence.

***Key insight:*** *Stop route growth first by allocating every new VPC from the Regional blocks, then shrink the existing problem release by release.*

#### Start with /16 for production VPCs

A `/16` gives you 65,536 addresses and room to create 256 `/24` subnets. This sounds excessive until you account for multi-AZ deployments (3+ Availability Zones × multiple subnet tiers), EKS pod density, future growth, and the fact that you cannot shrink a VPC CIDR after creation. The cost of a `/16` is zero (IP addresses in a VPC are free until you use Elastic IPs or public IPv4), but the cost of running out of space is a painful migration.

For non-production workloads where you're confident about scale, `/20` (4,096 addresses) is a reasonable choice. For isolated single-purpose VPCs (inspection VPCs, Transit Gateway attachment VPCs), `/24` or even `/28` may suffice.

***Key insight:*** *You cannot reduce a VPC's primary CIDR block. You can add secondary CIDRs later, but secondary CIDRs have limitations: they cannot overlap with existing CIDRs, some services don't support them cleanly, and they add operational complexity. Getting the primary CIDR right is always cheaper than fixing it later.*

#### Never overlap CIDR blocks across VPCs you might connect

Design your allocation so VPCs you might connect never overlap. Overlapping ranges block VPC Peering outright: if VPC A uses `10.0.0.0/16` and VPC B uses `10.0.5.0/24`, those VPCs can never peer, because `10.0.5.0/24` falls within `10.0.0.0/16`. Other paths can work around an overlap, but each adds cost, operational overhead, or address bookkeeping you would not otherwise carry. Non-overlapping space is always the clean answer.

If you inherit an overlap you did not choose, such as a merger, a partner network, or multicloud connectivity, you have a few recovery options, none of them free:

* **Re-IP one side.** This restores native, untranslated IP-level routing and is required if you must use VPC Peering. It also avoids permanent translation for unsupported attachment types or overlapping IPv6 Unique Local Address (ULA) ranges, which managed 1:1 NAT does not translate. It is the most invasive option because it touches DNS, application config, firewall rules, and monitoring.
* **Expose the workload as a service through PrivateLink or VPC Lattice.** PrivateLink uses ENIs and doesn't require routable connectivity; VPC Lattice operates at the application layer. The overlap becomes invisible with no translated-address bookkeeping. This is the right fit when access is a one-directional service exposure rather than full connectivity.
* **Translate with managed, static 1:1 NAT on a [Transit Gateway attachment](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-nat.html) or [Cloud WAN attachment](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-nat.html).** This maps an overlapping CIDR to a non-overlapping one of equal prefix length, giving bidirectional IP-level routing without re-IPing. The feature is IPv4 only; IPv6 passes untranslated. Transit Gateway does not support it on AWS Cloud WAN peering and route table attachments, Network Function attachments, or Client VPN attachments. Cloud WAN does not support it on transit gateway route table attachments or tunnel-less Connect attachments. Neither service allows it with appliance mode on the same VPC attachment. It incurs [NAT gateway-hour and per-GB data-processing charges](https://aws.amazon.com/vpc/pricing/), plus applicable standard data-transfer charges.

This applies across your entire organization, including VPCs you haven't created yet. Reserve address space for future accounts and Regions in your allocation plan.

#### Plan for hybrid connectivity from day one

If there is any chance your AWS environment will connect to on-premises networks, corporate data centers, or other clouds, you must coordinate CIDR allocation across all environments from the start. Hybrid connectivity failures caused by CIDR overlap are among the most expensive networking mistakes to fix because they force either re-IPing workloads, which touches DNS, application configurations, firewall rules, and monitoring systems, or permanent address translation on the hybrid path, which adds NAT charges, address bookkeeping, and translated IPs in logs and tracing.

This means:

1. **Document every on-premises IP range** before allocating AWS CIDRs. Include branch offices, partner networks, acquired company networks, and remote access VPN pools. The range you don't know about is the one that will overlap.
2. **Reserve non-overlapping space** for AWS that will never conflict with on-premises allocations. A clean split (for example, on-premises owns `10.128.0.0/9`, AWS owns `10.0.0.0/9`) eliminates ambiguity.
3. **Coordinate with network teams** who manage on-premises addressing. A unilateral AWS CIDR decision that overlaps with the data center range discovered six months later forces a VPC recreation or permanent address translation on the hybrid path.
4. **Account for VPN client pools**. Remote access VPN clients need IP ranges that don't overlap with either AWS or on-premises networks. Many organizations use `172.16.0.0/12` for client VPN pools.
5. **Plan for acquisitions**. When your company acquires another organization, their network ranges become your problem. Reserve space that's unlikely to conflict with typical enterprise allocations.

A common pattern: allocate `10.0.0.0/8` with on-premises using `10.128.0.0/9` and AWS using `10.0.0.0/9`. This gives each environment 8 million addresses with zero overlap risk. For organizations with existing on-premises allocations scattered across `10.0.0.0/8`, use `172.16.0.0/12` for AWS or work with your network team to identify unused portions of the `10.x` space.

***Key insight:*** *The most common hybrid connectivity failure is not a Direct Connect configuration error or a BGP misconfiguration — it's a CIDR overlap discovered after workloads are already running. Document all existing ranges, including those "temporary" lab networks and forgotten branch offices, before making any AWS allocation.*

#### Plan IPv6 alongside IPv4

IPv6 in AWS VPCs works differently from IPv4 and requires separate planning:

* **VPC-level**: Choose the IPv6 prefix length from the subnet hierarchy and growth requirement, then enforce it through IPAM allocation rules. Allocate the CIDR from a Regional hierarchy backed by an Amazon-provided contiguous block, BYOIP, or a private ULA/GUA range.
* **Subnet-level**: Choose subnet prefix lengths within the VPC allocation based on workload scale and future subdivision; IPv6 subnets are no longer limited to a single fixed size.
* **No NAT required for public IPv6**: Public GUA addresses are globally unique, and egress-only internet gateways provide outbound-only internet access without NAT. Private ULA/GUA ranges stay internal and require a routed path through a resource with public addressing for internet access.
* **Dual-stack**: Most organizations run dual-stack (IPv4 + IPv6) rather than IPv6-only, at least during transition.
* **Exhaustion is not the primary sizing concern, summarization is**: Size VPC and subnet allocations for their hierarchy and growth rather than IPv4-style scarcity, and keep each Region contiguous so its routes summarize.

**IPv6 CIDR source options:**

| Source | Use Case | Consideration |
| -------- | ---------- | --------------- |
| IPAM Regional pool with an Amazon-provided contiguous block | Default for multi-account environments | One summarizable prefix per Region; the block is provisioned to a pool with a Region locale, so the hierarchy starts at the Region rather than an organization-wide pool |
| BYOIP (Bring Your Own IP) | Enterprises that need publicly routable, organization-wide IPv6 space | Requires RIR registration and ROA; provides address portability |
| Private IPv6 ULA or GUA in an IPAM private scope | Internal-only networks that need an organization-wide hierarchy | The range cannot be advertised to the internet from AWS; private GUA space must be owned by your organization |
| Amazon-provided per VPC (no IPAM) | Single VPCs, sandboxes | Not contiguous across VPCs, so the allocations cannot be summarized; addresses change if you disassociate |

IPv6 planning is simpler than IPv4 in one respect: you never size for scarcity. The complexity lies in allocating from contiguous blocks and ensuring your security groups, NACLs, route tables, and firewall rules account for IPv6 traffic paths. Public GUA addresses can reach the internet only when routing and security controls allow it; private ULA/GUA ranges cannot be advertised to the internet from AWS.

**IPv6 planning checklist:**

* Decide on the IPv6 source (Amazon-provided contiguous block, BYOIP, or private ULA/GUA range) and create the Regional pools before creating VPCs (changing later requires disassociation)
* Update all security groups to include IPv6 rules (IPv4 rules do not automatically apply to IPv6 traffic)
* Configure IPv6 routes for the chosen source: public GUA uses an internet or egress-only internet gateway; private ULA/GUA uses an internal or hybrid egress path
* Ensure NACLs permit IPv6 traffic for required flows
* Verify that applications and DNS resolution handle dual-stack correctly

#### Use secondary CIDRs strategically, not as a crutch

AWS allows up to 5 IPv4 CIDR blocks per VPC (1 primary + 4 secondary). Secondary CIDRs are useful for:

* **EKS pod networking**: Adding `100.64.0.0/16` as a secondary CIDR for pod IP space
* **Acquisitions**: Integrating a newly acquired company's workloads that need temporary address space
* **Gradual migration**: Adding non-overlapping space while planning a proper re-IP

Secondary CIDRs are **not** a substitute for proper initial planning. They add complexity: route tables need entries for each CIDR, some services handle multiple CIDRs inconsistently, and the operational overhead of managing multiple ranges per VPC compounds across hundreds of VPCs.

***Key insight:*** *If you find yourself routinely adding secondary CIDRs to VPCs, your initial allocation was too small. Treat secondary CIDRs as an escape valve, not a design pattern.*

#### Avoid common CIDR planning mistakes

| Mistake | Why It Hurts | Prevention |
| --------- | ------------- | ------------ |
| Using `192.168.0.0/16` for production | Overlaps with home networks, VPN clients, and many on-premises environments | Use `10.0.0.0/8` for AWS production |
| Allocating `/24` VPCs "to save space" | Exhausts subnet capacity quickly; no room for multi-AZ or EKS | Default to `/16` for production, `/20` minimum for non-production |
| No reserved space for future Regions | Forces non-contiguous allocation when expanding | Reserve 50%+ of your total allocation |
| Ignoring on-premises ranges | Discovered overlaps force re-IPing or address translation on the hybrid path | Document all existing ranges before any AWS allocation |
| Per-team allocation without coordination | Teams independently choose overlapping ranges | Centralize allocation through IPAM or a shared registry |
| Treating VPC CIDR as changeable | Primary CIDR cannot be removed; forces VPC recreation | Plan the primary CIDR as permanent from day one |

## Combining CIDR planning with other services

CIDR planning is not an isolated activity — it directly enables or constrains every other networking service. The decisions you make about address allocation ripple through every connectivity pattern you adopt later. A well-designed CIDR plan makes Transit Gateway route tables clean, Direct Connect BGP advertisements simple, and Cloud WAN segment routing predictable. A poorly designed plan forces workarounds at every layer.

The table below shows how CIDR decisions interact with key AWS networking services.

| Combination | CIDR Planning Enables | Other Service Provides |
| --- | --- | --- |
| **CIDR + IPAM** | Hierarchical allocation scheme, size standards, reserved ranges | Automated allocation enforcement, overlap prevention, compliance auditing, multi-account governance |
| **CIDR + Transit Gateway** | Non-overlapping VPC ranges that can share route tables; contiguous blocks for route summarization | Regional hub-and-spoke routing, centralized egress, shared services connectivity |
| **CIDR + Direct Connect / Hybrid** | AWS ranges that never overlap with on-premises; summarizable blocks for BGP advertisements | Private dedicated connectivity, predictable bandwidth, reduced data transfer costs |
| **CIDR + VPC Peering** | Strictly non-overlapping ranges between peered VPCs (no partial overlap allowed) | Direct low-latency connectivity without bandwidth bottlenecks |
| **CIDR + Cloud WAN** | Per-Region contiguous allocations that align with segment boundaries; [summarizable prefixes for routing policies](../connectivity/within-aws.md#apply-routing-policies-at-network-boundaries) | Global policy-driven network, segment isolation, service insertion, multi-Region routing |
| **CIDR + EKS (VPC CNI)** | Secondary CIDRs (100.64.0.0/10) for pod networking; primary CIDR sized for nodes | Pod-level networking with VPC-native security groups, network policies |

The most common failure mode is discovering a CIDR constraint only when you try to adopt a new service. For example, you deploy Transit Gateway and discover that two VPCs in different accounts use the same `10.0.0.0/16` range because teams allocated independently; the networks must be re-IPed or translated before they can communicate. Or you establish Direct Connect and realize your AWS ranges overlap with a branch office subnet that nobody documented. These are not Transit Gateway or Direct Connect problems; they are CIDR planning problems that surface at deployment time.

***Key insight:*** *Every networking service you adopt later will either benefit from or be constrained by your CIDR plan. The 30 minutes you spend on a proper allocation scheme saves hundreds of hours of workarounds across Transit Gateway, Direct Connect, and Cloud WAN deployments.*

## Subnet CIDR Planning

Within a VPC, subnet design determines how workloads are isolated, how many resources can run in each Availability Zone, and how route tables control traffic flow. Subnet CIDRs are carved from the VPC's CIDR block and cannot overlap with each other.

Every subnet consumes a contiguous portion of the VPC CIDR. AWS reserves 5 addresses in each subnet: the network address, the VPC router (`.1`), the DNS server (`.2`), one reserved for future use (`.3`), and the broadcast address (last IP). A `/24` subnet therefore provides 251 usable addresses, not 256.

**Recommended subnet layout for a `/16` VPC across 3 Availability Zones:**

| Subnet Tier | AZ-A | AZ-B | AZ-C | Size | Purpose |
| ------------- | ------ | ------ | ------ | ------ | --------- |
| Public | 10.0.0.0/24 | 10.0.1.0/24 | 10.0.2.0/24 | /24 (251 usable) | Load balancers, NAT gateways, bastion hosts |
| Private (application) | 10.0.10.0/24 | 10.0.11.0/24 | 10.0.12.0/24 | /24 (251 usable) | Application servers, containers, Lambda |
| Private (data) | 10.0.20.0/24 | 10.0.21.0/24 | 10.0.22.0/24 | /24 (251 usable) | RDS, ElastiCache, OpenSearch |
| Private (spare) | 10.0.30.0/24 | 10.0.31.0/24 | 10.0.32.0/24 | /24 (251 usable) | Future use, additional tiers |
| TGW/Firewall | 10.0.250.0/28 | 10.0.250.16/28 | 10.0.250.32/28 | /28 (11 usable) | Transit Gateway ENIs, firewall endpoints |

**Subnet sizing guidance:**

* `/24` is the standard subnet size for most workloads. It provides 251 usable addresses per Availability Zone, which handles most application tiers comfortably.
* `/20` or larger for EKS worker node subnets if pods use the primary CIDR (each node consumes IPs proportional to its pod capacity).
* `/28` for infrastructure subnets that only host a few ENIs (Transit Gateway attachments, Network Firewall endpoints, NAT gateways).
* Leave gaps in your numbering scheme (notice the jump from `.2.0` to `.10.0` above) to allow inserting new subnet tiers without renumbering.

**Subnet design principles:**

* **Consistent across Availability Zones**: Every Availability Zone should have the same subnet tiers with the same sizes. This ensures workloads can fail over between Availability Zones without capacity differences.
* **Separate route tables per tier**: Public subnets route to an internet gateway; private subnets route through NAT or stay internal. Mixing tiers in a single route table creates security risks.
* **Plan for at least 3 Availability Zones**: Even if you start with 2, design your subnet scheme for 3 Availability Zones from the beginning. Adding a third Availability Zone later with a consistent scheme is trivial if you planned for it.
* **Reserve space for infrastructure subnets**: Transit Gateway attachments, Network Firewall endpoints, and Gateway Load Balancer endpoints each need a subnet per Availability Zone. These only need `/28` but must exist in every Availability Zone.

***Key insight:*** *The numbering gaps in your subnet scheme are not wasted space — they are future-proofing. A VPC that uses 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24 for its first three tiers has no room to insert a new tier between them. A scheme with gaps (0, 10, 20, 30) lets you add tiers at 5, 15, 25 without disrupting existing subnets.*

## Documentation

<div class="grid cards" markdown>

*   :material-file-document: **VPC CIDR blocks**

    ---

    Official documentation on VPC CIDR block configuration, limits, and supported ranges.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html)

*   :material-file-document: **Subnet sizing**

    ---

    How subnet CIDR blocks work, reserved addresses, and sizing considerations.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html#subnet-sizing)

*   :material-file-document: **Subnet CIDR reservations**

    ---

    Reserve portions of subnet CIDR space for specific use cases like exclusive use by specific services.

    [:octicons-arrow-right-24: Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html)

*   :material-book-open-variant: **Building Scalable Multi-VPC Networks**

    ---

    AWS whitepaper covering IP address planning at scale, multi-account strategies, and connectivity patterns.

    [:octicons-arrow-right-24: Whitepaper](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)

*   :material-post: **Designing Hyperscale VPC Networks**

    ---

    Blog post on large-scale CIDR planning, address space management, and growth strategies.

    [:octicons-arrow-right-24: Blog post](https://aws.amazon.com/blogs/networking-and-content-delivery/designing-hyperscale-amazon-vpc-networks/)

*   :material-book-open-variant: **RFC 1918 - Private Address Allocation**

    ---

    The foundational RFC defining private IPv4 address ranges used in VPC CIDR planning.

    [:octicons-arrow-right-24: RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918)

</div>

---

## Related Foundation Topics

This page covers CIDR planning principles. For related foundational topics, see:

* **[Amazon VPC](vpc.md)** — VPC design patterns, multi-AZ architecture, and how VPC structure builds on your CIDR plan
* **[Subnets](subnets.md)** — Subnet tiers, route table design, and network ACLs within your CIDR allocation
* **[AWS IPAM](ipam.md)** — Automating CIDR allocation, preventing overlaps, and enforcing policies across your organization
* **[Regions and Availability Zones](regions-azs.md)** — How Region selection drives your multi-Region CIDR allocation strategy
* **[AWS Organizations](organizations.md)** — Account structure that your CIDR hierarchy should mirror
