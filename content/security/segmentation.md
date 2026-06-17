# Network Segmentation

!!! info "Prerequisites"
    This section assumes familiarity with [Amazon VPC](../foundation/vpc.md), [AWS Organizations](../foundation/organizations.md), [Connectivity Within AWS](../connectivity/within-aws.md), and [Perimeter Controls](perimeter-inbound.md). Review those topics first if you're new to AWS networking fundamentals.

Network segmentation is not optional — it is the foundational security control that limits blast radius when (not if) a breach occurs. Every AWS network should be segmented at multiple layers, from account-level isolation down to per-resource security groups. The question is never "should I segment?" but "how many layers of segmentation do I need, and which mechanisms enforce each layer?"

AWS provides segmentation at five distinct layers, each with different enforcement characteristics, operational overhead, and cost implications. The strongest boundaries are at the top (accounts), and the most granular controls are at the bottom (application-layer auth). A well-designed network uses multiple layers simultaneously — defense in depth applied to network architecture.

This page is organized around the segmentation hierarchy: from the strongest isolation boundaries (accounts) down to the most granular controls (identity-based application auth). Each layer adds defense in depth, and no single layer is sufficient on its own.

![Segmentation hierarchy showing five layers from strongest (AWS Accounts) to most granular (Application Auth via VPC Lattice)](../assets/security/segmentation-hierarchy.png)
/// caption
Segmentation hierarchy — [Drawio Source](../assets/security/segmentation-hierarchy.drawio)
///

<div class="grid cards" markdown>

*   :material-shield-account: **Account-level isolation**

    ---

    AWS accounts provide the strongest isolation boundary — separate IAM principals, separate network namespaces, separate billing. A compromised workload in one account cannot reach resources in another without explicit cross-account access.

*   :material-lan-disconnect: **VPC isolation**

    ---

    VPCs have no implicit routing between them. Cross-VPC communication requires explicit connectivity (peering, Transit Gateway, Cloud WAN). This makes VPCs a natural trust boundary within an account.

*   :material-chart-pie: **Cloud WAN segments**

    ---

    Policy-driven network segmentation across Regions. Segments define which VPCs can communicate at the routing layer, enforced centrally through a network policy document.

*   :material-security: **Security group micro-segmentation**

    ---

    Per-resource traffic filtering with reference-based rules. Security groups let you define "service A can talk to service B" without managing IP addresses or CIDR blocks.

*   :material-shield-lock: **Identity-based segmentation**

    ---

    VPC Lattice auth policies enforce access based on caller identity (IAM principal), not network position. A workload's permissions follow it regardless of which VPC or subnet it runs in.

*   :material-eye: **Inspection between segments**

    ---

    AWS Network Firewall or third-party appliances inserted between segments via Cloud WAN service insertion or Transit Gateway routing, providing deep packet inspection at trust boundaries.

</div>

## Account-level isolation — the strongest boundary

AWS accounts are the most powerful segmentation mechanism available. Each account is a completely separate IAM namespace, network namespace, and billing entity. There is no implicit connectivity, no shared IAM principals, and no shared resource quotas between accounts.

This is why multi-account architecture is the default recommendation for production AWS environments. Placing workloads with different trust levels in separate accounts means that even a complete compromise of one account's IAM principals cannot directly access resources in another account.

***Key insight:*** *Account-level isolation is free, requires no networking configuration, and provides the strongest blast-radius containment. Use it as your first segmentation decision.*

### OU-based segmentation patterns

AWS Organizations OUs map naturally to segmentation boundaries:

| OU structure | Segmentation purpose | Example |
| --- | --- | --- |
| **Security OU** | Isolate security tooling (GuardDuty, Security Hub, log archive) from workload accounts | Prevents workload compromises from tampering with audit trails |
| **Infrastructure OU** | Centralize shared networking (Transit Gateway, Cloud WAN, DNS) | Network team controls connectivity; workload teams cannot modify routing |
| **Workloads / Prod OU** | Separate production from non-production | Different compliance controls, different network inspection rules |
| **Workloads / Dev OU** | Lower-trust environment for experimentation | Relaxed segmentation, no connectivity to production segments |
| **Sandbox OU** | Complete isolation for experimentation | No connectivity to any other OU; SCPs prevent VPC peering or TGW attachment |
| **Compliance OU** | Dedicated accounts for regulated workloads (PCI, HIPAA) | Strict inspection, dedicated VPCs, audit-ready configurations |

### Cost implications

Account-level segmentation is free. There is no charge for creating accounts, no per-account networking fee, and no data transfer cost for isolation (since isolated accounts have no connectivity by default). The cost comes when you *connect* accounts — through Transit Gateway attachments, Cloud WAN attachments, or VPC peering. This makes accounts the most cost-effective segmentation boundary.

## VPC-level segmentation

Within an account, VPCs provide network-level isolation. Two VPCs in the same account have no implicit routing between them — connecting them requires explicit action (peering, Transit Gateway attachment, Cloud WAN attachment).

Use separate VPCs when workloads within the same account have different:

* **Trust levels** — a management-plane VPC vs. a data-plane VPC
* **Connectivity requirements** — one VPC needs internet access, another must be fully private
* **Compliance scopes** — a PCI-scoped VPC with strict inspection vs. a general-purpose VPC
* **Lifecycle or team ownership** — different teams manage different VPCs independently

### IPv6 considerations for VPC segmentation

VPC segmentation applies identically to IPv6 traffic. When you create separate VPCs for isolation, ensure:

* Each VPC has its own IPv6 CIDR allocation (from IPAM or Amazon-provided)
* Route tables do not inadvertently create IPv6 connectivity between VPCs that should be isolated
* Security groups include explicit IPv6 rules — a security group that only has IPv4 rules provides no IPv6 filtering if the ENI has an IPv6 address assigned

***Key insight:*** *Security groups are stateful but not protocol-aware by default. If you assign IPv6 addresses to resources, you must add IPv6 rules to security groups explicitly — there is no automatic mirroring of IPv4 rules.*

## Subnets and route tables — routing-based segmentation

Within a VPC, subnets combined with route tables create routing-based segmentation. Resources in different subnets can have different routing behavior (public vs. private vs. isolated) even though they share the same VPC.

The key segmentation patterns:

| Subnet tier | Route table behavior | Use case |
| --- | --- | --- |
| **Public** | Route to internet gateway | Load balancers, bastion hosts, NAT gateways |
| **Private** | Route to NAT gateway (or no internet route) | Application workloads, databases |
| **Isolated** | No route outside the VPC | Sensitive data stores, compliance-scoped resources |
| **Firewall** | Route through Network Firewall endpoints | Inspection tier for traffic entering/leaving the VPC |

Route tables enforce segmentation at the IP routing layer. A resource in an isolated subnet physically cannot reach the internet because no route exists — this is stronger than a security group deny rule because it operates at the routing layer rather than the filtering layer.

## Security groups — micro-segmentation

Security groups provide the most granular network segmentation in AWS: per-ENI (effectively per-resource) traffic filtering. The key feature that makes security groups a segmentation tool rather than just a firewall is **reference-based rules**.

### Reference-based rules for workload segmentation

Instead of allowing traffic from a CIDR block, you allow traffic from another security group:

```yaml
# Allow traffic from the web tier security group
SecurityGroupIngress:
  - IpProtocol: tcp
    FromPort: 8080
    ToPort: 8080
    SourceSecurityGroupId: sg-web-tier
```

This creates a logical segmentation boundary: "only resources in the web tier can reach the application tier on port 8080." The rule follows the workload regardless of which subnet or IP address it uses. When you scale the web tier (add instances, change IPs), the segmentation rule still applies correctly.

### Dual-stack security group rules

Security groups require separate rules for IPv4 and IPv6 traffic. A common mistake is adding IPv4 ingress rules but forgetting IPv6, leaving resources accessible on IPv6 without the intended restrictions (or vice versa — blocking IPv6 when it should be allowed).

```yaml
# Correct: explicit rules for both address families
SecurityGroupIngress:
  - IpProtocol: tcp
    FromPort: 443
    ToPort: 443
    CidrIp: 10.0.0.0/8          # IPv4 corporate range
  - IpProtocol: tcp
    FromPort: 443
    ToPort: 443
    CidrIpv6: 2001:db8:cafe::/48  # IPv6 corporate range
```

When using reference-based rules (source security group), the rule applies to both IPv4 and IPv6 traffic from members of that security group — no duplication needed. This is another reason to prefer reference-based rules over CIDR-based rules.

***Key insight:*** *Reference-based security group rules are the preferred micro-segmentation mechanism because they decouple segmentation from IP addressing, work for both IPv4 and IPv6 automatically, and scale without rule updates as workloads grow.*

## Cloud WAN segments — policy-driven network segmentation

AWS Cloud WAN segments provide network segmentation at the routing layer across your entire multi-Region network. Each segment is an isolated routing domain — VPCs attached to different segments cannot communicate unless you explicitly allow it through segment sharing or service insertion rules in the network policy.

Segments are the right tool when you need:

* Consistent segmentation policies across multiple Regions
* Centralized enforcement that individual account owners cannot bypass
* Automated segment assignment based on attachment metadata (tags, account, Region)
* Inter-segment inspection through service insertion

### Cloud WAN segments vs. Transit Gateway route tables

Both provide routing-domain-based segmentation, but they differ in scope and management model:

| Dimension | Cloud WAN segments | Transit Gateway route tables |
| --- | --- | --- |
| **Scope** | Global (multi-Region, single policy) | Regional (per-TGW) |
| **Management** | Declarative network policy | Manual route table configuration per TGW |
| **Automation** | Tag-based attachment acceptance | Manual or custom automation |
| **Service insertion** | Built-in policy construct | Manual routing through inspection VPCs |
| **Cost** | Core network edge + attachment + data processing | TGW attachment + data processing |
| **Best for** | Organizations with 10+ accounts, multi-Region, or needing centralized governance | Single-Region, smaller environments, or during migration to Cloud WAN |

For new multi-account deployments, Cloud WAN segments are the recommended approach. For existing Transit Gateway environments, you can peer TGW with Cloud WAN and migrate incrementally (see [Connectivity Within AWS](../connectivity/within-aws.md) for migration guidance).

### Cost implications of network segmentation enforcement

Segmentation through accounts and VPCs is free — isolation is the default state. The cost appears when you connect segments and enforce policies at the routing layer:

| Mechanism | Cost components | When it applies |
| --- | --- | --- |
| **Account/VPC isolation** | Free | Always (isolation is default) |
| **Transit Gateway route tables** | Attachment hourly + data processing per GB | Regional segmentation |
| **Cloud WAN segments** | Core network edge hourly + attachment hourly + data processing per GB | Multi-Region or policy-driven segmentation |
| **Network Firewall (inspection)** | Firewall endpoint hourly + data processing per GB | Inter-segment inspection |
| **Security groups** | Free | Always |
| **VPC Lattice auth policies** | Per-request pricing (included in Lattice data processing) | Application-layer segmentation |

***Key insight:*** *The cheapest segmentation is the strongest: account and VPC isolation cost nothing. Invest in proper account structure first, then add routing-layer segmentation (Cloud WAN/TGW) only where connectivity between segments is required.*

## Identity-based segmentation with VPC Lattice

Traditional network segmentation answers "can network packet X reach network endpoint Y?" Identity-based segmentation answers a different question: "is principal A authorized to invoke service B?" VPC Lattice auth policies provide this application-layer segmentation.

### When network segmentation is not enough

Network segmentation breaks down when:

* Multiple services share the same VPC or subnet (common in containerized environments)
* Services need to communicate across segment boundaries for legitimate business reasons
* You need per-service access control, not per-network access control
* Workloads move between network positions (auto-scaling, container orchestration)

In these cases, identity-based segmentation through VPC Lattice auth policies provides finer-grained control that follows the workload regardless of its network position.

### Zero-trust patterns

VPC Lattice auth policies enable zero-trust networking patterns where access decisions are based on verified identity rather than network location:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111122223333:role/OrderService"
      },
      "Action": "vpc-lattice-svcs:Invoke",
      "Resource": "arn:aws:vpc-lattice:us-east-1:444455556666:service/svc-payments/*",
      "Condition": {
        "StringEquals": {
          "vpc-lattice-svcs:RequestMethod": "POST"
        }
      }
    }
  ]
}
```

This policy says: "Only the OrderService role in account 111122223333 can POST to the payments service" — regardless of which VPC, subnet, or IP address the OrderService runs from. This is segmentation that cannot be bypassed by network misconfiguration.

***Key insight:*** *Network segmentation and identity-based segmentation are complementary, not competing. Use network segmentation to limit blast radius at the infrastructure layer, and identity-based segmentation to enforce least-privilege at the application layer.*

## Service insertion for inter-segment inspection

When segments need to communicate, you may need to inspect that traffic for threats, compliance, or policy enforcement. AWS Cloud WAN service insertion and Transit Gateway routing both support directing inter-segment traffic through inspection VPCs running AWS Network Firewall or third-party appliances.

### Cloud WAN service insertion pattern

Define inspection rules in the Cloud WAN network policy to route traffic between specific segments through an Inspection VPC:

```json
{
  "segment-actions": [
    {
      "action": "send-via",
      "segment": "production",
      "via": {
        "network-function-groups": ["inspection-firewalls"]
      },
      "when-sent-to": {
        "segments": ["hybrid", "shared-services"]
      }
    }
  ]
}
```

This forces all traffic from the `production` segment destined for `hybrid` or `shared-services` through the inspection firewall — enforced at the network policy level, not through manual route table manipulation.

### AWS PrivateLink — segmentation through selective exposure

AWS PrivateLink provides a different segmentation model: instead of connecting networks and then filtering traffic, you expose only specific services across boundaries without any network-level connectivity. The consumer VPC gets an ENI that reaches the provider's service — nothing else in the provider's network is reachable.

This is segmentation by design rather than segmentation by filtering. Use PrivateLink when:

* You want to expose a single service to another account without granting any network-level access
* The provider and consumer should have no IP-level connectivity beyond the specific service
* You need to expose services to third parties or partners without VPC peering

## Best Practices

### Design segmentation top-down

#### Start with account boundaries, then add layers

Design your segmentation hierarchy from the top (accounts) down. The most common mistake is starting with security groups and NACLs while placing everything in a single account and VPC. This inverts the hierarchy — you end up relying on the weakest, most operationally complex controls while ignoring the strongest, cheapest ones.

The correct order:

1. **Accounts** — Separate workloads by trust level, compliance scope, and team ownership
2. **VPCs** — Within accounts, separate by connectivity requirements and lifecycle
3. **Cloud WAN segments / TGW route tables** — Control which VPCs can communicate at the routing layer
4. **Subnets and route tables** — Within VPCs, separate by routing requirements (public/private/isolated)
5. **Security groups** — Per-resource micro-segmentation with reference-based rules
6. **VPC Lattice auth policies** — Per-service identity-based access control

Each layer adds defense in depth. A failure at one layer (for example, a misconfigured security group) is contained by the layers above it (the workload is still in an isolated VPC in a separate account).

#### Align segmentation with compliance requirements

Compliance frameworks (PCI DSS, HIPAA, SOC 2) often mandate network segmentation for regulated workloads. Map compliance scopes to segmentation boundaries:

| Compliance requirement | Segmentation approach |
| --- | --- |
| **PCI DSS CDE isolation** | Dedicated accounts + dedicated VPCs + Cloud WAN segment with mandatory inspection |
| **HIPAA PHI protection** | Dedicated accounts + isolated subnets + security groups restricting access to authorized roles |
| **SOC 2 environment separation** | Separate OUs for production vs. non-production + no cross-OU connectivity without inspection |
| **Data residency** | Region-specific Cloud WAN segments that prevent cross-Region data flow |

***Key insight:*** *Compliance-driven segmentation is easier to audit when it maps to account and OU boundaries. An auditor can verify "all PCI workloads are in the PCI OU" more easily than "all PCI workloads have the correct security group rules."*

### Implement micro-segmentation effectively

#### Use one security group per workload role

Assign a dedicated security group to each logical workload role (web tier, application tier, database tier, monitoring agents). Avoid shared "allow all internal" security groups that negate the purpose of micro-segmentation.

#### Prefer reference-based rules over CIDR-based rules

Reference-based rules (source/destination security group) are more maintainable, automatically handle IPv4/IPv6, and scale without rule updates. Use CIDR-based rules only when referencing external networks (on-premises ranges, partner CIDRs) or when cross-VPC references are not possible.

#### Audit security group rules regularly

Security groups accumulate rules over time. Unused rules expand the attack surface. Use VPC Flow Logs and security group usage analysis to identify rules that no longer carry traffic, then remove them.

### Enforce segmentation centrally

#### Use SCPs to prevent segmentation bypass

Service Control Policies can prevent workload accounts from creating VPC peering connections, Transit Gateway attachments, or other connectivity that bypasses your segmentation design. The networking team controls connectivity; workload teams consume it.

Example SCP denying direct VPC peering (forcing traffic through the centralized network):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyVPCPeering",
      "Effect": "Deny",
      "Action": [
        "ec2:CreateVpcPeeringConnection",
        "ec2:AcceptVpcPeeringConnection"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Centralize network connectivity in a dedicated account

Place Transit Gateways, Cloud WAN core networks, and shared Inspection VPCs in a dedicated networking account within the Infrastructure OU. Share connectivity to workload accounts via AWS RAM. This ensures the networking team maintains control over segmentation enforcement.

### Plan for IPv6 segmentation

#### Apply identical segmentation to both address families

Every segmentation control that applies to IPv4 must also apply to IPv6. This includes:

* Security group rules (separate rules needed for IPv6 CIDRs; reference-based rules cover both automatically)
* Network ACLs (if used — separate IPv6 rules required)
* Route tables (IPv6 routes are separate entries)
* Network Firewall rules (must include IPv6 rule groups)
* Cloud WAN routing (dual-stack support in network policy)

#### Avoid IPv6 as a segmentation bypass

A common vulnerability: workloads have IPv6 addresses assigned but security groups only contain IPv4 rules. This effectively creates an unsegmented IPv6 network. Audit all security groups in dual-stack VPCs to ensure IPv6 rules match the intended segmentation posture.

## Combining segmentation with other services

| Combination | Segmentation provides | Other service provides |
| --- | --- | --- |
| **Segmentation + AWS Network Firewall** | Isolation between segments (routing-layer) | Deep packet inspection, IDS/IPS, domain filtering at segment boundaries |
| **Segmentation + VPC Lattice** | Network-layer blast radius containment | Application-layer identity-based access control independent of network position |
| **Segmentation + AWS PrivateLink** | No network-level connectivity between segments | Selective service exposure across segment boundaries without opening routing |
| **Segmentation + AWS Cloud WAN** | Segment definitions and isolation policies | Global enforcement, automated attachment, service insertion orchestration |
| **Segmentation + AWS Organizations SCPs** | Network-level isolation between accounts | IAM-level prevention of segmentation bypass (deny peering, deny TGW attachment) |
| **Segmentation + VPC Flow Logs** | Enforcement of traffic boundaries | Visibility into what traffic is flowing (or being denied) at segment boundaries |
| **Segmentation + AWS Firewall Manager** | Consistent segmentation intent | Centralized security group policy enforcement across accounts |

## Documentation

<div class="grid cards" markdown>

*   :material-file-document: **VPC security best practices**

    ---

    AWS documentation covering security groups, NACLs, and VPC-level security controls.

    [:octicons-arrow-right-24: VPC security](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

*   :material-file-document: **AWS Cloud WAN segments**

    ---

    Documentation on creating and managing segments in Cloud WAN network policies.

    [:octicons-arrow-right-24: Cloud WAN segments](https://docs.aws.amazon.com/vpc/latest/cloudwan/cloudwan-policy-segments.html)

*   :material-file-document: **Security groups for your VPC**

    ---

    Complete reference for security group rules, limits, and behavior including dual-stack configurations.

    [:octicons-arrow-right-24: Security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)

*   :material-file-document: **Amazon VPC Lattice auth policies**

    ---

    How to configure identity-based access control for services using VPC Lattice auth policies.

    [:octicons-arrow-right-24: Auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html)

*   :material-post: **Building a multi-account network with Cloud WAN**

    ---

    Architecture walkthrough showing segmentation patterns with Cloud WAN in a multi-account environment.

    [:octicons-arrow-right-24: Blog post](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/aws-cloud-wan/)

*   :material-file-document: **AWS Network Firewall deployment models**

    ---

    Reference architectures for deploying Network Firewall for inter-segment inspection.

    [:octicons-arrow-right-24: Deployment models](https://docs.aws.amazon.com/network-firewall/latest/developerguide/architectures.html)

</div>

## Related pages

**Relationship to Foundation topics:**

* **[Amazon VPC](../foundation/vpc.md)**: VPCs are the primary network-level segmentation boundary within an account. This page builds on VPC isolation concepts.
* **[AWS Organizations](../foundation/organizations.md)**: Account and OU structure defines the strongest segmentation boundaries. Organization design is a segmentation decision.
* **[Subnets](../foundation/subnets.md)**: Subnet design and route table configuration implement routing-based segmentation within a VPC.

**Relationship to Connectivity topics:**

* **[Connectivity Within AWS](../connectivity/within-aws.md)**: Cloud WAN segments and Transit Gateway route tables are covered in depth there. This page focuses on their segmentation properties rather than connectivity mechanics.

**Relationship to other Security topics:**

* **[Perimeter Controls](perimeter-inbound.md)**: Perimeter controls protect the network edge; segmentation controls internal traffic flows. Both are required.
* **[Outbound Controls](outbound.md)**: Outbound filtering can be applied per-segment (different egress rules for different segments).
