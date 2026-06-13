# Foundation

This section covers the fundamental building blocks of AWS networking. Understanding these core concepts is essential before implementing connectivity, application networking, security, or observability solutions. Every service and pattern in the rest of this guide builds on the foundation described here.

The foundation layer answers the questions that come before "how do I connect things?": how is your organization structured, where do your networks live, what address space do they use, and how is that address space governed. Getting these decisions right enables everything above them to work cleanly. Getting them wrong creates constraints that are expensive to fix later.

## 1. Before You Start

Every VPC, route table, and Transit Gateway attachment lives inside an account, is governed by IAM policies, is subject to service quotas, and should be deployed through code. Getting these non-networking foundations right before you touch a single CIDR block prevents the class of problems that are hardest to fix later.

**Key topics:**

*   **Identity and Access Management (IAM)** — Cross-account roles, service-linked roles, SCPs, and condition keys for network resources
*   **Infrastructure as Code** — CloudFormation, Terraform, and CDK for network resource management
*   **Service Quotas** — Limits that gate deployment and must be planned around
*   **Tagging Strategy** — Cost allocation, automation targeting, and policy enforcement
*   **Well-Architected Framework** — Security, Reliability, and Cost Optimization pillars applied to networking

## 2. AWS Organizations and Account Structure

**AWS Organizations** is the governance layer that determines how network resources are shared, how security boundaries are enforced, and how teams operate independently without creating connectivity chaos. Without Organizations, every cross-account networking pattern requires manual trust relationships that don't scale.

**Key concepts:**

*   **Organizational Units (OUs)** — Logical groupings that scope RAM shares, SCP enforcement, and attachment automation
*   **Service Control Policies (SCPs)** — Guardrails that enforce network architecture, not just security
*   **Centralized Networking Account** — Dedicated account for Transit Gateway, Direct Connect, Route 53 Resolver, and IPAM
*   **Resource sharing via RAM** — Share networking resources at the OU level for automatic inheritance

***Best Practice:*** *Establish a dedicated networking account before any workload accounts. Every subsequent account will depend on shared networking resources, and retrofitting centralized networking is significantly harder than starting centralized.*

## 3. Amazon VPC

**Amazon Virtual Private Cloud (VPC)** is the foundational security boundary, the IP address domain, and the routing context that shapes every networking decision above it. Every compute resource, database, container, and Lambda function that needs network connectivity runs inside a VPC.

**Key decisions:**

*   **VPC design pattern** — VPC per workload (most common), shared VPCs via RAM (centralized control), or multi-VPC per account
*   **CIDR sizing** — Start with `/16` for production; never go smaller than `/20`
*   **IPv6 adoption** — Enable dual-stack from day one on new VPCs
*   **Flow Logs** — Enable at VPC level for comprehensive security and troubleshooting visibility

***Best Practice:*** *Use custom VPCs for everything. Delete or ignore default VPCs. Deploy an SCP that denies resource creation in default VPCs across your entire Organization.*

## 4. Regions and Availability Zones

**AWS Regions** are separate geographic areas with fully independent infrastructure. Each Region contains multiple **Availability Zones (Availability Zones)** — physically separated data centers connected by low-latency private fiber. Every networking resource you deploy exists in exactly one Availability Zone, and your multi-AZ strategy determines resilience, cost, and blast radius.

**Key considerations:**

*   **Region selection** — Latency, Direct Connect locations, service availability, compliance, and cost
*   **AZ IDs vs Availability Zone names** — Availability Zone names are mapped randomly per account; use Availability Zone IDs for cross-account coordination
*   **Multi-AZ patterns** — Deploy every stateful networking resource per-AZ; size for N-1 Availability Zone capacity
*   **Cross-AZ cost** — per-GB charge in each direction (see [VPC pricing](https://aws.amazon.com/vpc/pricing/)); minimize unnecessary cross-AZ traffic without sacrificing availability

***Best Practice:*** *Deploy production workloads across at least 3 Availability Zones. Size per-AZ capacity so that losing one Availability Zone doesn't overwhelm the remaining two.*

## 5. IP Address Planning with CIDR Blocks

**CIDR (Classless Inter-Domain Routing)** notation defines IP address ranges for your VPCs and subnets. IP address planning is the single most consequential early decision that you cannot easily change later — every VPC, peering connection, hybrid link, and route table is constrained by the CIDRs you chose at creation time.

**Key principles:**

*   **Allocate contiguously** — Enables route summarization, simplifies firewall rules, and makes topology legible
*   **Never overlap** — VPCs with overlapping CIDRs cannot be connected via peering, Transit Gateway, or Cloud WAN
*   **Plan for hybrid** — Coordinate with on-premises ranges before any AWS allocation
*   **Use 10.0.0.0/8** — Largest contiguous private space; supports deep hierarchical allocation

***Best Practice:*** *Design a hierarchical allocation: Organization → Environment → Region → VPC → Subnet. This structure enables route summarization at every level and makes your network topology self-documenting.*

## 6. Subnets

A **subnet** is where routing policy meets IP addressing. Every resource you launch lands in a subnet, and that subnet's route table determines what the resource can reach. "Public" and "private" are properties of the route table, not the subnet itself.

**Key patterns:**

*   **Five-tier architecture** — Firewall, public, private (application), data, and infrastructure/transit subnets
*   **One subnet per Availability Zone per tier** — Consistent across all Availability Zones
*   **Size for the workload** — `/24` for most tiers; `/22` or larger for EKS/ECS container subnets
*   **Infrastructure subnets** — Dedicated `/28` subnets for Transit Gateway ENIs, firewall endpoints, and VPC endpoint ENIs

***Best Practice:*** *Leave numbering gaps in your subnet scheme (0, 10, 20, 30 instead of 0, 1, 2, 3) so you can insert new tiers later without disrupting existing subnets.*

## 7. IP Address Management (IPAM)

**AWS IPAM** replaces spreadsheets and tribal knowledge with a centralized, policy-driven system that plans, allocates, tracks, and monitors IP addresses across every account and Region. Without IPAM, IP address management degrades into a coordination bottleneck that produces overlaps discovered only when you try to connect VPCs.

**Key capabilities:**

*   **Hierarchical pools** — Organization → Region → Environment → Workload, with allocation rules at every level
*   **Overlap prevention** — Every allocation validated against the entire pool hierarchy
*   **Compliance monitoring** — Continuous detection of VPCs with manually assigned CIDRs that violate your standards
*   **IaC integration** — CloudFormation and Terraform reference IPAM pools instead of hardcoded CIDRs

***Best Practice:*** *Implement IPAM before creating your first production VPC. The cost of a single CIDR overlap (which requires VPC recreation to fix) exceeds the cost of IPAM for years.*

## 8. DNS Architecture

**Amazon Route 53 Resolver** handles every DNS query made from within a VPC — answering queries for private hosted zones, forwarding queries for on-premises domains, and resolving public internet names. In a multi-account environment, DNS decisions cascade into service discovery, hybrid connectivity, and security posture. Route 53 Profiles distribute DNS configuration (private hosted zone associations, forwarding rules, DNS Firewall rule groups) at the OU level so every account inherits consistent resolution automatically.

**Key capabilities:**

*   **Route 53 Profiles** — Bundle and share DNS configuration across all accounts in an OU; new accounts inherit automatically
*   **Private hosted zones** — Internal DNS namespaces visible only to associated VPCs; the foundation of service discovery
*   **Resolver endpoints** — Inbound (on-premises resolves AWS names) and outbound (AWS resolves on-premises names) for hybrid DNS
*   **DNS Firewall** — Domain-based filtering at the resolution layer; the cheapest and broadest egress control

***Best Practice:*** *Deploy Route 53 Profiles from day one. Without them, multi-account DNS turns into fragile per-account automation that drifts over time. With them, DNS configuration is a first-class operation that scales with your organization.*

---

## Explore Foundation Topics

<div class="grid cards" markdown>

*   :material-book-open-outline: **Before You Start**

    ---

    IAM, Infrastructure as Code, service quotas, tagging, and Well-Architected principles for networking.

    [:octicons-arrow-right-24: Before You Start](aws-prerequisites.md)

*   :material-office-building-outline: **AWS Organizations**

    ---

    Multi-account governance, SCPs, centralized networking account, and resource sharing via RAM.

    [:octicons-arrow-right-24: AWS Organizations](organizations.md)

*   :material-cloud-outline: **Amazon VPC**

    ---

    VPC design patterns, CIDR sizing, IPv6, Flow Logs, and the relationship between VPCs and account strategy.

    [:octicons-arrow-right-24: Amazon VPC](vpc.md)

*   :material-earth: **Regions and Availability Zones**

    ---

    Region selection, Availability Zone IDs, multi-AZ patterns, cross-AZ cost management, and Local Zones.

    [:octicons-arrow-right-24: Regions and Availability Zones](regions-azs.md)

*   :material-ip-network: **CIDR Planning**

    ---

    Hierarchical allocation, route summarization, hybrid coordination, IPv6, and common mistakes.

    [:octicons-arrow-right-24: CIDR Planning](cidr.md)

*   :material-network: **Subnets**

    ---

    Tier design, route tables, sizing for containers, NACLs, infrastructure subnets, and VPC sharing.

    [:octicons-arrow-right-24: Subnets](subnets.md)

*   :material-ip: **IPAM**

    ---

    Pool hierarchy, allocation rules, compliance monitoring, IaC integration, and hybrid awareness.

    [:octicons-arrow-right-24: IPAM](ipam.md)

*   :material-dns: **DNS Architecture**

    ---

    Route 53 Resolver, private hosted zones, Resolver endpoints for hybrid DNS, Route 53 Profiles, and DNS Firewall.

    [:octicons-arrow-right-24: DNS Architecture](dns.md)

</div>
