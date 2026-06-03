# Security

This section covers how to protect your AWS network at every layer — from the global edge down to individual resources, from inbound traffic to outbound connections, and from network-level isolation to identity-based access control. Network security in AWS is not a single firewall at the perimeter; it is a series of overlapping controls where each layer catches what the others miss.

The security controls covered here operate on top of the connectivity and application networking layers. They assume you've already designed your VPC structure, subnet tiers, and connectivity patterns. Security is not an afterthought applied to a finished architecture — it shapes the architecture from the start, influencing subnet design (dedicated firewall tiers), route table configuration (traffic directed through inspection), and account structure (isolation as the strongest boundary).

## 1. Perimeter Controls

**Perimeter controls** protect your network boundaries from unauthorized inbound access. In AWS, the perimeter is not a single firewall — it is layered controls operating at different levels of the stack, from the global edge network down to individual ENIs.

**Key services:**

*   **Security Groups** — Stateful, per-ENI access control; the primary mechanism for every workload
*   **Network ACLs** — Stateless, subnet-level deny rules for defense-in-depth
*   **AWS WAF** — L7 request inspection on CloudFront, ALB, and API Gateway
*   **AWS Shield** — DDoS protection (Standard automatic, Advanced for higher-tier)
*   **AWS Network Firewall** — Managed stateful/stateless inspection at the VPC boundary
*   **Gateway Load Balancer** — Transparent insertion of third-party firewall appliances
*   **AWS Firewall Manager** — Centralized policy management across all accounts

***Key insight:*** *Security groups are your primary access control — not NACLs, not Network Firewall. Get security group design right and the other layers become safety nets rather than compensating controls.*

## 2. Outbound Controls

**Outbound controls** determine what your workloads are allowed to reach on the internet and how that traffic is filtered before it leaves your environment. The core principle is default-deny outbound, allow by exception.

**Key services:**

*   **Security Groups (outbound rules)** — Port and protocol restrictions at the ENI level
*   **Route 53 DNS Firewall** — Domain-based filtering at the DNS resolution layer; cheapest and fastest egress control
*   **AWS Network Firewall (egress rules)** — Stateful inspection, IPS signatures, and SNI-based domain filtering
*   **VPC Endpoints** — Eliminate egress entirely for AWS service traffic (S3, DynamoDB, and more)
*   **AWS Network Firewall Proxy (preview)** — Managed explicit forward proxy for outbound web traffic

***Key insight:*** *DNS Firewall is the first egress control you should deploy in every VPC — it covers the widest threat surface at the lowest cost, and it works regardless of whether your egress is centralized or decentralized.*

## 3. Network Segmentation

**Network segmentation** limits blast radius by dividing your network into isolated segments at multiple layers. AWS provides segmentation from account-level isolation (the strongest boundary) down to per-request identity-based access control (the most granular).

**Key mechanisms:**

*   **AWS Accounts** — Strongest isolation: separate IAM, network, and billing boundaries
*   **VPCs** — Network-level isolation with no implicit cross-VPC routing
*   **Cloud WAN Segments / Transit Gateway Route Tables** — Policy-driven routing-domain segmentation
*   **Security Groups** — Micro-segmentation with reference-based rules
*   **VPC Lattice Auth Policies** — Identity-based segmentation independent of network position
*   **Service Insertion** — Network Firewall inspection between segments via Cloud WAN or Transit Gateway routing

***Key insight:*** *The cheapest segmentation is the strongest: account and VPC isolation cost nothing. Invest in proper account structure first, then add routing-layer segmentation only where connectivity between segments is required.*

---

## Explore Security Topics

<div class="grid cards" markdown>

*   :material-shield: **Perimeter Controls**

    ---

    Security groups, NACLs, AWS WAF, Shield, Network Firewall, GWLB, and Firewall Manager for inbound protection.

    [:octicons-arrow-right-24: Perimeter Controls](perimeter-inbound.md)

*   :octicons-sign-out-16: **Outbound Controls**

    ---

    DNS Firewall, Network Firewall egress rules, VPC endpoints, and data exfiltration prevention patterns.

    [:octicons-arrow-right-24: Outbound Controls](outbound.md)

*   :material-chart-pie: **Network Segmentation**

    ---

    Account isolation, Cloud WAN segments, security group micro-segmentation, and zero-trust patterns with VPC Lattice.

    [:octicons-arrow-right-24: Network Segmentation](segmentation.md)

</div>
