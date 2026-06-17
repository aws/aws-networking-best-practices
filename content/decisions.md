# Networking Decision Map

This page maps common AWS networking questions to the right service, pattern, and page in this guide. Use it when you know what you're trying to accomplish but aren't sure which AWS service or architectural pattern fits.

## Connecting VPCs and accounts

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Connect many VPCs across multiple Regions with centralized policy | **AWS Cloud WAN** — declarative network policy, automated attachment acceptance, segment-based isolation, global dynamic routing | Higher per-attachment cost than TGW, but policy-driven management eliminates per-Region manual configuration | [Connectivity Within AWS](connectivity/within-aws.md) |
| Connect VPCs in a single Region through a hub | **AWS Transit Gateway** — regional hub for thousands attachments, route table segmentation | Simpler than Cloud WAN for single-Region; becomes complex to manage across Regions | [Connectivity Within AWS](connectivity/within-aws.md) |
| Connect exactly two VPCs with high throughput and zero same-AZ data processing/transfer cost | **VPC Peering** — lowest latency, no bandwidth limit, no per-GB charge for same-AZ traffic, non-transitive | Doesn't scale past a handful of pairs; CIDRs cannot overlap | [Connectivity Within AWS](connectivity/within-aws.md) |
| Expose an HTTP/gRPC service to other VPCs and accounts | **VPC Lattice Services** — cross-VPC without peering or TGW, IAM auth policies, weighted routing, overlapping CIDRs | Operates at L7 only (HTTP/HTTPS/gRPC) | [Connectivity Within AWS](connectivity/within-aws.md) |
| Give another account private TCP access to a database or on-prem endpoint | **VPC Lattice VPC Resources** — resource configurations with custom domain names and DNS as target without NLB required, overlapping CIDRs, expose range of ports | Unidirectional (consumer → resource only); TCP only | [Connectivity Within AWS](connectivity/within-aws.md) |
| Expose a TCP service behind NBL to consumer VPCs | **AWS PrivateLink endpoint service** — NLB-backed, per-consumer interface endpoint, ENI-based | Scales linearly with consumer count (one endpoint per consumer VPC); no auth policies | [Connectivity Within AWS](connectivity/within-aws.md) |

## Reaching the internet

| I need to... | Recommended pattern | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Let private IPv4 resources reach the internet | **NAT gateway** - Zonal or Regional, resilient and scales automatically | Data processing and hourly cost if not centralized | [Internet Connectivity](connectivity/internet.md) |
| Let private IPv6 resources reach the internet | **Egress-only internet gateway** — no data process (data transfer still applies), per-VPC, outbound-only | Cannot be centralized; doesn't support NAT66/NPTv6  | [Internet Connectivity](connectivity/internet.md) |
| Expose an HTTP/HTTPS application to the internet | **CloudFront + AWS WAF + ALB** (decentralized ingress) — edge caching, L7 protection, VPC Origins for private backends | Centralized ingress through a shared VPC adds load-balancer chaining and blast radius; avoid unless compliance mandates it | [Internet Connectivity](connectivity/internet.md) |
| Expose a TCP/UDP service to the internet | **NLB** internet-facing, per-VPC, can preserve client IP | Combine with security groups or Next Generation Firewall for additional security| [Internet Connectivity](connectivity/internet.md) |
| Reduce NAT gateway costs for traffic to AWS Services | **VPC Endpoints** — gateway endpoints for S3/DynamoDB (free), interface endpoints for other services | Interface endpoints have hourly and data processing charges; | [Internet Connectivity](connectivity/internet.md) |

## Connecting to on-premises and other clouds

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Private, predictable bandwidth to on-premises | **AWS Direct Connect** — dedicated circuits at 1/10/100/400 Gbps, partner hosted circuits 50Mbps - 10Gbps; lower egress pricing than internet | Dedicated port ready in up to 72h but provisioning requires cross-connects or provider/partner coordination; design for maximum resiliency (2+ connections, 2+ locations) | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Encrypted connectivity to on-premises with no wait times | **AWS Site-to-Site VPN** — IPsec over internet, up in minutes, up to 5 Gbps per Large tunnel | Internet-based: latency and throughput are unpredictable. Not a substitute for Direct Connect for production hybrid | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Connect AWS to Google Cloud privately | **AWS Interconnect** — managed direct cloud-to-cloud, MACsec encrypted, minutes to provision | Currently supports AWS ↔ Google Cloud only; expanding. Use partner-based Direct Connect for unsupported pairs | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Integrate existing SD-WAN with AWS | **Transit Gateway Connect or Cloud WAN Tunnel-less Connect** — GRE/Tunnel-less attachments with BGP | Requires SD-WAN virtual appliances in a transit VPC (or on-prem with DX underlay for TGW Connect) | [Hybrid & Multi-Cloud](connectivity/hybrid-multicloud.md) |
| Give remote users access to applications | **AWS Verified Access** (preferred) — zero-trust, per-request identity + device posture, no VPN client | Use Client VPN only when applications genuinely need network-layer IP reachability (SSH, RDP, legacy protocols) | [Remote Access](connectivity/remote-access.md) |

## Securing network traffic

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| Control which resources can communicate at network layer | **Security groups** — stateful, per-ENI, reference-based rules. The primary access control for every workload | Cannot deny (allow-only); use NACLs for explicit deny rules at the subnet level | [Perimeter Controls](security/perimeter-inbound.md) |
| Protect web applications from L7 attacks | **AWS WAF** on CloudFront or ALB — managed rule groups, rate limiting, bot control, geo-blocking | AWS WAF is HTTP-only; use Network Firewall for non-HTTP inspection | [Perimeter Controls](security/perimeter-inbound.md) |
| Inspect traffic at the VPC boundary including internet egress or VPC to VPC (L3-L7) | **AWS Network Firewall** — managed stateful/stateless inspection, Suricata IPS rules, domain filtering | Consider costs - per-endpoint-hour + per-GB processing;  | [Perimeter Controls](security/perimeter-inbound.md) |
| Insert third-party firewall appliances | **Gateway Load Balancer** — Maintains session affinity to 3rd party firewall appliances using GENEVE encapsulation, transparent insertion, preserves original headers | You manage the appliance fleet (patching, scaling, licensing); more expensive than Network Firewall to operate. Some vendors offer a fully managed GWLB based solution | [Perimeter Controls](security/perimeter-inbound.md) |
| Block workloads from reaching unauthorized domains | **Route 53 DNS Firewall** — domain-based filtering at DNS resolution, fractions of a cent per million queries | Bypassed by hardcoded IPs or DNS-over-HTTPS; layer with Network Firewall for full coverage | [Outbound Controls](security/outbound.md) |
| Prevent data exfiltration to unauthorized S3 buckets | **VPC endpoint policy** on the S3 gateway endpoint — restrict to your organization's buckets only | Only covers S3 traffic through the endpoint; doesn't cover other exfiltration vectors | [Outbound Controls](security/outbound.md) |
| Isolate workloads at the strongest level | **Separate AWS accounts** — independent IAM, network, and billing boundaries. Free, no networking configuration needed | Connecting accounts requires explicit connectivity (Transit Gateway, Cloud WAN, VPC Lattice) | [Network Segmentation](security/segmentation.md) |
| Enforce identity-based access between micro-services | **VPC Lattice auth policies** — IAM SigV4 signing, per-request evaluation, independent of network position | Requires consumers to sign requests with SigV4; can start with VPC/path-based conditions while adopting signing | [Network Segmentation](security/segmentation.md) |

## Monitoring and troubleshooting

| I need to... | Recommended service | Key trade-off | Learn more |
| --- | --- | --- | --- |
| See what traffic flows in my VPC | **VPC Flow Logs** — enable at VPC level, custom format with 40+ fields, deliver to S3 for cost-effective Athena queries | S3 delivery: most cost effective. CloudWatch Logs: more expensive but enables real-time alerting | [Internal Traffic](observability/internal-traffic.md) |
| See all cross-VPC traffic in my organization | **Transit Gateway Flow Logs** — single config in the networking account covers all cross-VPC traffic | Only captures traffic crossing the TGW; intra-VPC traffic requires per-VPC Flow Logs | [Internal Traffic](observability/internal-traffic.md) |
| Monitor load balancer health and performance | **CloudWatch metrics** — HealthyHostCount, TargetResponseTime, HTTPCode_ELB_5XX, RejectedConnectionCount | Metrics are aggregated; use ALB/NLB access logs for per-request investigation | [AWS Services Monitoring](observability/service-monitoring.md) |
| Get alerted when a VPN tunnel or DX connection goes down | **EventBridge rules** for state-change events + **CloudWatch Alarms** on TunnelState/ConnectionState | Alarm on single-tunnel-down (redundancy lost), not just both-tunnels-down (outage) | [Notifications](observability/notifications.md) |
| Understand egress costs and destinations | **AWS Cost and Usage Reports** (per-resource data transfer line items) + **CloudWatch metrics** (BytesOutToDestination, ActiveConnectionCount) + **VPC Flow Logs** (destination IPs, bytes per flow) | CUR shows cost attribution but is delayed; Flow Logs give real-time destination detail but no cost data — combine both for full picture | [External Traffic](observability/external-traffic.md) |
| Measure real-time packet loss and latency between my EC2 instances and AWS services | **Network Flow Monitor** — lightweight agents on instances report TCP performance stats; dashboards show per-flow packet loss, latency, and attribution | Requires agent installation on each instance; only covers TCP-based flows | [AWS Services Monitoring](observability/service-monitoring.md) |
| Monitor internet performance and availability for my internet-facing applications | **Internet Monitor** — uses AWS global network data to baseline performance; surfaces health events and suggests routing improvements via CloudFront or alternate Regions | Visibility limited to traffic paths AWS can observe; no on-premises coverage | [AWS Services Monitoring](observability/service-monitoring.md) |
| Track latency and packet loss for hybrid connections to on-premises destinations | **Network Synthetic Monitor** — fully-managed probes from AWS resources to on-prem IPs; no agent install required; health event alerts with configurable thresholds | Only measures AWS-to-on-prem direction; requires destination IPs to be reachable from probe source | [AWS Services Monitoring](observability/service-monitoring.md) |

## Choosing a load balancer

| Traffic type | Use this | Not this | Why |
| --- | --- | --- | --- |
| HTTP, HTTPS, gRPC | **ALB** | NLB (can handle but has not app layer visibility) | ALB provides content-based routing, TLS termination, AWS WAF integration, mTLS, and Automatic Target Weights |
| TCP, UDP, TLS, QUIC (non-HTTP) | **NLB** | ALB | NLB forwards without HTTP decoding; preserves client IP; provides static IPs per Availability Zone |
| Need static IPs AND HTTP routing | **NLB with ALB-as-target** | ALB alone | NLB provides the static IPs; ALB provides the L7 routing behind it |
| Third-party firewall insertion | **GWLB** | Network Firewall | GWLB is for your own appliance fleet; Network Firewall is the AWS-managed alternative |
| Service-to-service across VPCs | **VPC Lattice** | ALB + PrivateLink | VPC Lattice bundles cross-VPC reach, auth, weighted routing, and access logs without managing load balancers |
