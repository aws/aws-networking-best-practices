# Networking Decision Map

This page maps common AWS networking questions to the right service, pattern, and page in this guide. Use it when you know what you're trying to accomplish but aren't sure which AWS service or architectural pattern fits.

## Connecting VPCs and accounts

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Connect many VPCs across multiple Regions with centralized policy | **AWS Cloud WAN** — declarative network policy, automated attachment acceptance, segment-based isolation | Higher per-attachment cost than TGW, but policy-driven management eliminates per-Region manual configuration | [Connectivity Within AWS](connectivity/within-aws.md) |
| Connect VPCs in a single Region through a hub | **AWS Transit Gateway** — up to 5,000 attachments, route table segmentation, $0.05/hr per attachment + $0.02/GB processing | Simpler than Cloud WAN for single-Region; becomes complex to manage across Regions | [Connectivity Within AWS](connectivity/within-aws.md) |
| Connect exactly two VPCs with high throughput and zero data processing cost | **VPC Peering** — no bandwidth limit, no per-GB charge for same-Region, non-transitive | Doesn't scale past a handful of pairs; CIDRs cannot overlap | [Connectivity Within AWS](connectivity/within-aws.md) |
| Expose an HTTP/gRPC service to other VPCs and accounts | **Amazon VPC Lattice** — cross-VPC without peering or TGW, IAM auth policies, weighted routing, no CIDR coordination | Per-request pricing ($0.025/GB); operates at L7 only (HTTP/HTTPS/gRPC) | [Connectivity Within AWS](connectivity/within-aws.md) |
| Give another account private TCP access to a database or on-prem endpoint | **VPC Lattice VPC Resources** — resource configurations with custom domain names, no NLB required, overlapping CIDRs supported | Unidirectional (consumer → resource only); TCP only | [Connectivity Within AWS](connectivity/within-aws.md) |
| Expose a TCP service to a small number of consumer VPCs | **AWS PrivateLink endpoint service** — NLB-backed, per-consumer interface endpoint, ENI-based | Scales linearly with consumer count (one endpoint per consumer VPC per AZ); no auth policies | [Connectivity Within AWS](connectivity/within-aws.md) |

## Reaching the internet

| I need to... | Recommended pattern | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Let private IPv4 resources reach the internet | **NAT Gateway** (one per AZ in each VPC, or centralized egress VPC) | Per-AZ: no transit charges but per-VPC NAT cost. Centralized: shared NAT but Transit Gateway processing on every flow | [Internet Connectivity](connectivity/internet.md) |
| Let private IPv6 resources reach the internet | **Egress-only Internet Gateway** — free, per-VPC, outbound-only, no NAT | Cannot be centralized; no managed NAT66 exists. IPv6 egress is always decentralized | [Internet Connectivity](connectivity/internet.md) |
| Expose an HTTP/HTTPS application to the internet | **CloudFront + AWS WAF + ALB** (decentralized ingress) — edge caching, L7 protection, VPC Origins for private backends | Centralized ingress through a shared VPC adds load-balancer chaining and blast radius; avoid unless compliance mandates it | [Internet Connectivity](connectivity/internet.md) |
| Expose a TCP/UDP service to the internet | **NLB** (internet-facing, per-VPC) with per-VPC Network Firewall or GWLB inspection | NLB preserves client IP by default; security groups must permit real client ranges | [Internet Connectivity](connectivity/internet.md) |
| Reduce NAT Gateway costs for AWS API traffic | **VPC Endpoints** — gateway endpoints for S3/DynamoDB (free), interface endpoints for other services | Interface endpoints cost $0.01/hr per AZ + $0.01/GB; still cheaper than NAT for high-volume services | [Internet Connectivity](connectivity/internet.md) |

## Connecting to on-premises and other clouds

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Private, predictable bandwidth to on-premises | **AWS Direct Connect** — dedicated circuits at 1/10/100 Gbps, lower egress pricing than internet | Provisioning takes weeks (cross-connects, provider coordination); design for maximum resiliency (2+ connections, 2+ locations) | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Encrypted connectivity to on-premises today | **AWS Site-to-Site VPN** — IPsec over internet, up in minutes, up to 5 Gbps per Large tunnel | Internet-based: latency and throughput are unpredictable. Not a substitute for Direct Connect for production hybrid | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Connect AWS to Google Cloud privately | **AWS Interconnect** — managed direct cloud-to-cloud, MACsec encrypted, minutes to provision | Currently supports AWS ↔ Google Cloud only; expanding. Use partner-based Direct Connect for unsupported pairs | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Integrate existing SD-WAN with AWS | **Transit Gateway Connect or Cloud WAN Connect** — GRE/Tunnel-less attachments with BGP | Requires SD-WAN virtual appliances in a transit VPC (or on-prem with DX underlay for TGW Connect) | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Give remote users access to applications | **AWS Verified Access** (preferred) — zero-trust, per-request identity + device posture, no VPN client | Use Client VPN only when applications genuinely need network-layer IP reachability (SSH, RDP, legacy protocols) | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |

## Securing network traffic

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Control which resources can communicate | **Security groups** — stateful, per-ENI, reference-based rules. The primary access control for every workload | Cannot deny (allow-only); use NACLs for explicit deny rules at the subnet level | [Perimeter Controls](security/perimeter-inbound.md) |
| Protect web applications from L7 attacks | **AWS WAF** on CloudFront or ALB — managed rule groups, rate limiting, bot control, geo-blocking | WAF is HTTP-only; use Network Firewall for non-HTTP inspection | [Perimeter Controls](security/perimeter-inbound.md) |
| Inspect traffic at the VPC boundary (L3/L4) | **AWS Network Firewall** — managed stateful/stateless inspection, Suricata IPS rules, domain filtering | Per-endpoint-hour + per-GB processing; deploy only where inspection value justifies cost | [Perimeter Controls](security/perimeter-inbound.md) |
| Insert third-party firewall appliances | **Gateway Load Balancer** — GENEVE encapsulation, transparent insertion, preserves original headers | You manage the appliance fleet (patching, scaling, licensing); more expensive than Network Firewall to operate | [Perimeter Controls](security/perimeter-inbound.md) |
| Block workloads from reaching unauthorized domains | **Route 53 DNS Firewall** — domain-based filtering at DNS resolution, fractions of a cent per million queries | Bypassed by hardcoded IPs or DNS-over-HTTPS; layer with Network Firewall for full coverage | [Outbound Controls](security/outbound.md) |
| Prevent data exfiltration to unauthorized S3 buckets | **VPC endpoint policy** on the S3 gateway endpoint — restrict to your organization's buckets only | Only covers S3 traffic through the endpoint; doesn't cover other exfiltration vectors | [Outbound Controls](security/outbound.md) |
| Isolate workloads at the strongest level | **Separate AWS accounts** — independent IAM, network, and billing boundaries. Free, no networking configuration needed | Connecting accounts requires explicit connectivity (Transit Gateway, Cloud WAN, VPC Lattice) | [Network Segmentation](security/segmentation.md) |
| Enforce identity-based access between services | **VPC Lattice auth policies** — IAM SigV4 signing, per-request evaluation, independent of network position | Requires consumers to sign requests with SigV4; can start with VPC/path-based conditions while adopting signing | [Network Segmentation](security/segmentation.md) |

## Monitoring and troubleshooting

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| See what traffic flows in my VPC | **VPC Flow Logs** — enable at VPC level, custom format with 40+ fields, deliver to S3 for cost-effective Athena queries | S3 delivery: $0.25/GB ingestion, cheapest. CloudWatch Logs: $0.50/GB but enables real-time alerting | [Internal Traffic](observability/internal-traffic.md) |
| See all cross-VPC traffic in my organization | **Transit Gateway Flow Logs** — single config in the networking account covers all cross-VPC traffic | Only captures traffic crossing the TGW; intra-VPC traffic requires per-VPC Flow Logs | [Internal Traffic](observability/internal-traffic.md) |
| Monitor load balancer health and performance | **CloudWatch metrics** — HealthyHostCount, TargetResponseTime, HTTPCode_ELB_5XX, RejectedConnectionCount | Metrics are aggregated; use ALB/NLB access logs for per-request investigation | [AWS Services Monitoring](observability/service-monitoring.md) |
| Get alerted when a VPN tunnel or DX connection goes down | **EventBridge rules** for state-change events + **CloudWatch Alarms** on TunnelState/ConnectionState | Alarm on single-tunnel-down (redundancy lost), not just both-tunnels-down (outage) | [Notifications](observability/notifications.md) |
| Understand egress costs and destinations | **NAT Gateway CloudWatch metrics** (BytesOutToDestination, ErrorPortAllocation) + **VPC Flow Logs** (destination IPs) | Combine with DNS query logs to map IPs back to domain names for full attribution | [External Traffic](observability/external-traffic.md) |

## Choosing a load balancer

| Traffic type | Use this | Not this | Why |
| --- | --- | --- | --- |
| HTTP, HTTPS, gRPC | **ALB** | NLB | ALB provides content-based routing, TLS termination, WAF integration, mTLS, and Automatic Target Weights |
| TCP, UDP, TLS, QUIC (non-HTTP) | **NLB** | ALB | NLB forwards without HTTP decoding; preserves client IP; provides static IPs per AZ |
| Need static IPs AND HTTP routing | **NLB with ALB-as-target** | ALB alone | NLB provides the static IPs; ALB provides the L7 routing behind it |
| Third-party firewall insertion | **GWLB** | Network Firewall | GWLB is for your own appliance fleet; Network Firewall is the AWS-managed alternative |
| Service-to-service across VPCs | **VPC Lattice** | ALB + PrivateLink | VPC Lattice bundles cross-VPC reach, auth, weighted routing, and access logs without managing load balancers |
