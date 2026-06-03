# Connectivity

This section covers how AWS resources communicate with the internet, with each other, and with networks outside AWS. Connectivity is the layer between your foundational infrastructure (VPCs, subnets, IP addressing) and the application networking services that run on top of it.

The connectivity patterns you choose shape cost, latency, security boundaries, and operational ownership across your entire AWS environment. Most organizations use more than one connectivity service simultaneously, with each operating at the layer where it provides the most value.

## 1. Internet Connectivity

**Internet connectivity** covers two distinct concerns: **ingress** (how external clients reach your AWS-hosted applications) and **egress** (how your AWS resources reach external services on the internet). The right pattern for each depends on different criteria, and the decisions you make for one rarely apply cleanly to the other.

**Key decisions:**

*   **Ingress: decentralized vs centralized** — Decentralized (each VPC owns its ingress) is the preferred default; centralized (shared ingress VPC) is reserved for specific compliance cases
*   **Egress: IPv6 vs IPv4** — IPv6 egress is decentralized by design (egress-only internet gateway per VPC); IPv4 egress is a genuine trade-off between decentralized and centralized patterns
*   **Edge services** — Amazon CloudFront, AWS Global Accelerator, and AWS WAF provide centrally-managed protection regardless of ingress pattern

***Key insight:*** *For ingress, the AWS edge (CloudFront, AWS WAF, per-VPC firewall endpoints) effectively becomes a centrally-managed, globally-distributed perimeter, removing the historical reason to route every flow through a shared regional ingress VPC.*

## 2. Connectivity Within AWS

**Within-AWS connectivity** handles how VPCs, accounts, and Regions communicate with each other. The services operate at two complementary layers: network-level connectivity (how VPCs route traffic) and application-level connectivity (how services discover and talk to each other).

**Key services:**

*   **AWS Cloud WAN** — Policy-driven global network management with declarative segmentation
*   **Amazon VPC Lattice** — Application-layer service-to-service communication with IAM-based auth
*   **VPC Lattice VPC Resources** — Private TCP access to databases, on-premises endpoints, and third-party services
*   **AWS Transit Gateway** — Regional hub-and-spoke routing for VPCs, VPN, and Direct Connect
*   **AWS PrivateLink** — Private access to AWS services and exposing your own services to other accounts
*   **VPC Peering** — Direct point-to-point connectivity for specific, justified VPC pairs

***Key insight:*** *These services are complementary layers, not competing alternatives. Build a connectivity stack where each service operates at the layer where it provides the most value.*

## 3. Hybrid and Multi-Cloud Connectivity

**Hybrid and multi-cloud connectivity** covers three distinct concerns: connecting on-premises data centers and branch offices to AWS (hybrid), connecting AWS to other public clouds (multi-cloud), and giving users and devices access to specific AWS applications (client communication).

**Key services:**

*   **AWS Direct Connect** — Private, dedicated circuits for predictable bandwidth and latency; the foundation for most production hybrid deployments
*   **AWS Site-to-Site VPN** — Encrypted IPsec connectivity over the internet; fastest way to establish hybrid connectivity
*   **SD-WAN integration** — Transit Gateway Connect or AWS Cloud WAN Connect attachments for existing SD-WAN overlays
*   **AWS Interconnect** — Managed direct cloud-to-cloud connections (currently AWS ↔ Google Cloud, expanding)
*   **AWS Client VPN** — Network-level user access into VPCs
*   **AWS Verified Access** — Zero-trust application-level access (preferred for new application access use cases)

***Key insight:*** *Most organizations use more than one of these services simultaneously. Direct Connect for the primary private path, VPN for fast-start or encryption overlay, and Verified Access for application access.*

---

## Explore Connectivity Topics

<div class="grid cards" markdown>

*   :material-web: **Internet Connectivity**

    ---

    Ingress and egress patterns, decentralized vs centralized architectures, edge services, NAT gateway, and egress filtering.

    [:octicons-arrow-right-24: Internet Connectivity](internet.md)

*   :material-aws: **Connectivity Within AWS**

    ---

    AWS Cloud WAN, Amazon VPC Lattice, Transit Gateway, PrivateLink, VPC Peering, and how to combine them.

    [:octicons-arrow-right-24: Connectivity Within AWS](within-aws.md)

*   :material-cloud-sync: **Hybrid & Multi-Cloud Connectivity**

    ---

    Direct Connect, Site-to-Site VPN, SD-WAN, AWS Interconnect, Client VPN, and Verified Access.

    [:octicons-arrow-right-24: Hybrid & Multi-Cloud Connectivity](hybrid-multicloud.md)

</div>
