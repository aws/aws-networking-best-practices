# Connectivity

This section covers how AWS resources communicate with the internet, with each other, and with networks outside AWS. Connectivity is the layer between your foundational infrastructure (VPCs, subnets, IP addressing) and the application networking services that run on top of it.

The connectivity patterns you choose shape cost, latency, security boundaries, and operational ownership across your entire AWS environment. Most organizations use more than one connectivity service simultaneously, with each operating at the layer where it provides the most value.

**How these pages relate:** Internet Connectivity covers your external boundary (how traffic enters and leaves AWS). Within AWS covers internal routing and service communication between VPCs and accounts. Hybrid & Multi-Cloud covers connections to networks outside AWS — on-premises data centers and other cloud providers. Remote Access covers how authorized users and devices reach internal applications. Most architectures touch all four pages: internet for public-facing workloads, within-AWS for the backbone between them, hybrid for the on-premises and multi-cloud leg, and remote access for workforce connectivity.

!!! tip "VPC Lattice coverage"
    Amazon VPC Lattice appears in two places by design. The [Within AWS](within-aws.md) page covers VPC Lattice from the connectivity and network-team perspective: service networks, association models, and how VPC Lattice fits the connectivity stack. The [Application Networking → Service to Service](../application-networking/service-to-service.md) page covers VPC Lattice from the application-team perspective: service discovery, auth policies, traffic management, and deployment patterns.

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

**Hybrid and multi-cloud connectivity** covers two distinct concerns: connecting on-premises data centers and branch offices to AWS (hybrid) and connecting AWS to other public clouds (multi-cloud).

**Key services:**

*   **AWS Direct Connect** — Private, dedicated circuits for predictable bandwidth and latency; the foundation for most production hybrid deployments
*   **AWS Site-to-Site VPN** — Encrypted IPsec connectivity over the internet; fastest way to establish hybrid connectivity
*   **SD-WAN integration** — Transit Gateway Connect or AWS Cloud WAN Connect attachments for existing SD-WAN overlays
*   **AWS Interconnect** — Managed direct cloud-to-cloud connections (currently AWS ↔ Google Cloud, expanding)

***Key insight:*** *Most organizations use more than one of these services simultaneously. Direct Connect for the primary private path, VPN for fast-start or encryption overlay, and SD-WAN Connect for existing branch overlays.*

## 4. Remote Access

**Remote access** addresses how authorized users and devices reach internal AWS applications. This is a distinct decision domain from infrastructure connectivity — it serves identity and security teams rather than network engineering, and works independently of whether your environment has hybrid connectivity.

**Key services:**

*   **AWS Verified Access** — Zero-trust application-level access with per-request identity and device posture evaluation; the preferred option for new use cases
*   **AWS Client VPN** — Network-level user access into VPCs for cases that genuinely require IP reachability

***Key insight:*** *Start with AWS Verified Access for every new application access use case. Use Client VPN only when the application genuinely requires the user to have a routable IP inside the VPC.*

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

    Direct Connect, Site-to-Site VPN, SD-WAN, and AWS Interconnect for on-premises and multi-cloud infrastructure connectivity.

    [:octicons-arrow-right-24: Hybrid & Multi-Cloud Connectivity](hybrid-multicloud.md)

*   :material-account-lock: **Remote Access**

    ---

    AWS Verified Access for zero-trust application access and AWS Client VPN for network-level user connectivity.

    [:octicons-arrow-right-24: Remote Access](remote-access.md)

</div>
