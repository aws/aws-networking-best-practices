# Networking Basics

Fundamental concepts for AWS networking. This section covers core
VPC concepts, IP addressing, routing, security, and connectivity patterns
that form the building blocks for all AWS network architectures.

<div class="grid cards" markdown>

*   :material-school-outline: **AWS Prerequisites**

    ---

    Essential AWS knowledge needed before starting with networking.

    ---

    [:octicons-arrow-right-24: AWS Prerequisites](aws-prerequisites.md)

*   :material-star-plus-outline: **Your first VPC**

    ---

    Setting up your first Virtual Private Cloud (VPC).

    ---

    [:octicons-arrow-right-24: First VPC](first-vpc.md)

</div>

## 1. AWS Regions and Availability Zone considerations

[AWS Regions are geographic locations](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) that contain multiple data centers. Availability Zones (AZs) are isolated facilities within a Region, each equipped with independent power, cooling, and networking infrastructure. [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/) are extensions of AWS Regions that are positioned closer to population centers, providing low-latency compute, storage, and database services. Together, these components form AWS's global infrastructure, enabling high availability, fault tolerance, and reduced latency for applications.

### Design Around Workload Communication Patterns

Structure your subnets to match application tiers (web, app, db) within each Availability Zone. For e.g., web tier: `10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b), 10.0.3.0/24 (AZ-c)`, app tier: `10.0.11.0/24 (AZ-a), 10.0.12.0/24 (AZ-b), 10.0.13.0/24 (AZ-c)` and db tier: `10.0.21.0/24 (AZ-a), 10.0.22.0/24 (AZ-b), 10.0.23.0/24 (AZ-c)`. This creates a pattern where anyone on your team can instantly identify the tier and AZ by looking at the subnet CIDR. Cross-Availability Zone (AZ) data transfer charges can add up when applications generate high-volume inter-tier communication. Additionally, subnet placement affects your ability to implement granular security controls and optimize routing paths. Before designing subnets, map your application's communication patterns. Create dedicated subnet ranges for each tier (web, application, and database) within each AZ. For example, when using a `10.0.0.0/16` VPC, allocate: `10.0.1.0/24` for the `web tier` in AZ-a, `10.0.11.0/24` for the `application tier` in AZ-a, `10.0.21.0/24` for the `database tier` in AZ-a. Repeat this pattern with incremental ranges for other AZs. This approach enables tier-specific routing policies and security group rules while providing clear network boundaries for troubleshooting. Plan for future growth by reserving an appropriate portion of your VPC CIDR space based on your anticipated expansion needs. When planning IPv6 deployments, allocate your IPv6 CIDR block early and align your dual-stack strategy with your subnet boundaries to avoid complex renumbering later.

### Implement Balanced Cross-AZ Load Distribution

Applications deployed across multiple Availability Zones (AZs) can experience uneven load distribution due to client-side caching, DNS resolution patterns, or sticky session configurations. Uneven load distribution creates hot spots that can trigger cascading failures. When an overloaded AZ experiences issues, the sudden traffic shift to remaining AZs can overwhelm the resources if they haven't been tested under full load. This pattern can lead to service interruption rather than graceful degradation.

When using [Elastic Load Balancers](https://aws.amazon.com/elasticloadbalancing/), the recommended approach is to keep traffic zonal by default rather than enabling cross-zone load balancing. Maintaining zonal traffic provides benefits beyond cost savings, including reduced latency, simplified troubleshooting, and easier zone evacuation. With a fully zonal architecture, if issues arise when accessing resources in a specific AZ, you can quickly identify and evacuate that AZ while investigating the root cause. Cross-zone load balancing should primarily be considered when you lack sufficient capacity in each AZ to handle the load independently. If you do enable cross-zone load balancing, understand the associated data transfer costs. Deploy sufficient capacity in each AZ and regularly test failover scenarios under realistic load conditions. Implement circuit breaker patterns in your application code to prevent retry storms when an AZ becomes unavailable. Consider using [Application Recovery Controller (ARC) zonal shift](https://docs.aws.amazon.com/r53recovery/latest/dg/arc-zonal-shift.html) to redirect traffic from impaired AZs. Monitor the ELB `HealthyHostCount` [CloudWatch metric](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html) and set up alerts for distribution deviations. For consistent performance across geographic regions, consider [AWS Global Accelerator](https://aws.amazon.com/global-accelerator/).

### Optimize Cross-Region Connectivity for Cost and Performance

Cross-region data transfer can generate variable costs in multi-region deployments. Architect your applications so that services that communicate frequently are in the same region, especially for high-volume data transfers and low latency. For workloads requiring multi-region communication, consider either [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/) or [AWS Cloud WAN](https://aws.amazon.com/cloud-wan/). For simple point-to-point connections between specific VPCs in different regions, use VPC Peering. Cross-region traffic stay on the AWS global private network with predictable performance.

Use regional [AWS PrivateLink](https://aws.amazon.com/privatelink/) endpoints in each region rather than native cross-region connectivity to connect to VPC endpoint services hosted in other AWS Regions. At the application layer, implement data compression and deduplication before initiating cross-region transfers. When appropriate, consider using [AWS DataSync](https://aws.amazon.com/datasync/) or [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) for bulk data movement instead of application-level replication.

### Use Local Zones for Ultra-Low Latency Requirements

[AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/) enable you to use select AWS services, such as compute and storage services, in locations closer to end users, providing low-latency access to locally running applications. Local Zones are connected to their parent Region through Amazon's redundant, high-bandwidth private network, ensuring that applications running in Local Zones have fast, secure, and seamless access to other AWS services.

Deploy Local Zones for workload components that require low latency for end users, including real-time gaming servers, financial trading applications. While latency-sensitive components should be deployed in Local Zones, maintain core application logic and data stores in standard Availability Zones (AZs). Establish clear network paths between Local Zones and your main AZs, typically by using subnets within the same VPC. Since Local Zones have smaller resource pools compared to standard AZs, monitor their capacity constraints more carefully. Design your application architecture to handle Local Zone unavailability gracefully by implementing fail back mechanisms to standard AZ resources.

### Design Data Residency and Compliance-Aware Network Boundaries

While compliance requirements often determine region selection, consider their implications for data residency when designing network architecture. Network design can influence data flow patterns, and seemingly harmless configurations, such as CloudWatch log destinations or AWS Config snapshots, can unintentionally transfer data across regional boundaries. This complexity is further amplified in multi-region deployments where compliance requirements may vary between regions. To ensure compliance: Map all data flows within their architecture, including AWS service integrations, logging, monitoring, and backup destinations, Configure region-specific AWS service endpoints, Understand the AWS services that support in the context of centralization, for e.g, [Amazon CloudWatch Logs data centralization](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs_Centralization.html), multi-Region [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-multi-region-trails.html), [AWS Config Multi-Region Data Aggregation](https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html).

Additionally, use [AWS Organizations Service Control Policies (SCP)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) to restrict resource creation to the desired regions, Implement AWS PrivateLink endpoints for all AWS services to maintain data within VPC boundaries, Conduct regular audits of CloudTrail logs to identify any API calls that might indicate cross-region data movement.

### Implement Predictable Network Performance Across AZs

For latency-sensitive workloads network performance consistency is an important requirement. In these scenarios, establish baseline network performance metrics between Availability Zones (AZs) in your deployment regions. Use enhanced networking features such as [Elastic Fabric Adapter (EFA)](https://aws.amazon.com/hpc/efa/), [Scalable Reliable Datagram (SRD)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ena-express.html), and [placement groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) where appropriate for performance-critical workloads. Design your application architecture by implementing timeout and retry policies that account for network variability.

Monitor inter-AZ network latency using [Infrastructure Performance in AWS Network Manager](https://docs.aws.amazon.com/network-manager/latest/infrastructure-performance/what-is-nmip.html) and configure alerts for performance degradation. With AWS services such as [OpsCenter](https://docs.aws.amazon.com/systems-manager/latest/userguide/OpsCenter.html), a capability of AWS Systems Manager; [AWS X-Ray](https://aws.amazon.com/xray/); and [Amazon Athena](https://aws.amazon.com/athena/), you can [unify observability](https://aws.amazon.com/blogs/networking-and-content-delivery/network-observability-for-modern-applications/) across your entire environment. For applications requiring consistent low latency, consider using [cluster placement groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) within single AZs for critical components while maintaining cross-AZ deployment for resilience. While, instances are not isolated to a single rack in a cluster placement group, understand the [rules and limitations](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html) of placement groups and high availabilti tradeoffs in case of an AZ impact. Implement application-level metrics that correlate network performance with business outcomes.

### Operational Considerations

Effective day-2 operations for multi-AZ and multi-region architectures require monitoring and automation strategies. Integrate [AWS Health Aware notifications](https://aws.amazon.com/blogs/mt/aws-health-aware-customize-aws-health-alerts-for-organizational-and-personal-aws-accounts/) into incident management systems to correlate application issues with infrastructure events. Establish runbooks that define expected behavior during AZ impairments and document for responding to zone-specific issues. Review [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) reports filtered by Availability Zone and usage type to understand where cross-AZ charges accumulate. Conducting tests using [AWS Fault Injection Service](https://aws.amazon.com/fis/) in chaos engineering can help to validate system resilience.

### Relevant Resources

* [AWS Regions and Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)
* [Reliability Pillar - AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html)
* [AWS re:Invent 2024 - Anatomy of an AWS Region](https://youtu.be/PAr1DY82ymE)
* [AWS re:Invent 2022 - Dive deep on AWS networking infrastructure](https://youtu.be/HJNR_dX8g8c)
* [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
* [Disaster Recovery of Workloads on AWS](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-workloads-on-aws.html)
* [Amazon Application Recovery Controller](https://aws.amazon.com/application-recovery-controller/)

## 2. VPC IP Addressing and CIDR Planning

Choosing IP ranges and avoiding conflicts, CIDR notation and subnet sizing.

## 3. IPv4 vs. IPv6 in VPCs

Dual-stack networking and protocol-specific considerations. Private vs public vs Elastic IPs. Basics of BYOIP.

## 4. Single VPC vs. Multiple VPCs per Account

When to use one large VPC vs multiple smaller VPCs.

## 5. VPC Sharing

When to use it vs separate VPCs per account. "should we share or separate?

## 6. Subnet Strategies

"how many subnets do I need?" and common patterns (public/private).

## 7. Elastic Network Interfaces (ENIs)

An [Elastic Network Interface (ENI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) is a logical networking component in a VPC that represents a virtual network card. You can create and configure network interfaces and attach them to instances within the same Availability Zone. ENIs are one of AWS's most fundamental networking components. While EC2 instances automatically receive a primary ENI upon launch, the real value lies in understanding how to architect multi-ENI solutions that provide network-level resilience, security isolation, and operational flexibility. Many users treat ENIs merely as simple network adapters, missing critical opportunities to build robust, scalable architectures.

A common misconception is that ENIs must be tightly coupled to EC2 instances. This misunderstanding often leads to architectures that cannot gracefully handle instance failures, perform zero-downtime network maintenance, or implement advanced traffic management patterns. Users typically discover these limitations during their first major incident or scaling event, which frequently results in extended outages and costly architectural rework.

### Understand the Primary vs. Secondary ENI Distinction

Most teams focus exclusively on primary ENIs and only discover secondary ENI capabilities when facing network requirements that seem impossible to solve with basic EC2 networking.

[Understanding](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#eni-basics) the distinction between primary and secondary ENIs is crucial for implementing network-level high availability, security segmentation, and operational flexibility. Each instance has a default primary ENI that cannot be detached while the instance is running. However, you can create and attach secondary ENIs that can be moved between instances, providing the basis for advanced networking patterns. The [maximum number of network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AvailableIpPerENI.html) varies by instance type.

Design your architecture with clear ENI roles from the beginning. Understand the [considerations](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/network-interface-attachments.html) and use primary ENIs for management traffic and instance-specific communication, while leveraging secondary ENIs for application traffic, database connections, or specialized network functions. When planning multi-ENI architectures, always verify that your chosen instance types support the required number of ENIs, as this [varies](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AvailableIpPerENI.html) significantly across instance families and sizes.

Secondary ENIs retain their MAC addresses when moved between instances, making them ideal for licensing scenarios that depend on MAC address consistency. Additionally, consider using secondary ENIs for blue-green deployments where you need to maintain consistent IP addresses while switching between underlying instances.

### Implement meaningful Secondary IP Address Management

Users often overlook secondary IP addresses or implement them reactively when facing IP exhaustion, rather than including them in their initial architectural planning. Secondary IP addresses on Elastic Network Interfaces (ENIs) provide a powerful mechanism for implementing high availability without requiring Elastic Load Balancers, supporting container workloads, and enabling advanced routing scenarios. However, poor secondary IP management can lead to IP conflicts, connectivity issues, and operational complexity.

It is essential to establish clear IP address allocation strategies before deployment. Reserve IP ranges within your subnets specifically for secondary addresses, and maintain a centralized [IP Address Manager](https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html) to track all assignments. When implementing failover scenarios, ensure that your application can properly bind to secondary IPs and that your monitoring systems track all assigned addresses, not just primary ones.

While secondary IP addresses automatically receive corresponding private DNS names in Route 53 private hosted zones, these names aren't always intuitive. Consider implementing custom DNS records for your secondary IPs to improve operational visibility. Additionally, remember that secondary IPs don't automatically receive public IP addresses—you must explicitly associate [Elastic IPs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) when external connectivity is required.

### Plan ENI Placement for Optimal Performance and Resilience

Elastic Network Interface placement decisions are often made without considering network performance characteristics, Availability Zone (AZ) constraints, or failure domain isolation, which can lead to suboptimal architectures. Since ENIs are AZ-specific resources, their placement directly impacts both performance and availability. Poor placement can create unexpected failure modes, performance bottlenecks, and increased cross-AZ data transfer costs. It is essential to map your ENI placement to your application's failure domain requirements. For high-availability applications, critical secondary ENIs should never be placed in the same AZ as their primary instances. Implement [automated ENI attachment logic](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/scenarios-enis.html#create-a-low-budget-high-availability-solution) that considers AZ affinity and can gracefully handle AZ-level failures. Additionally, it is important to monitor cross-AZ traffic patterns to optimize placement and minimize data transfer costs.

### Implement Security Group Strategies for Multi-ENI Environments

[Security group](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) management can become complex in multi-ENI environments, often resulting in overly permissive rules or operational overhead that teams don't anticipate. Each ENI can have its own security group associations, enabling fine-grained network security but also creating opportunities for misconfiguration. Poor security group architecture can lead to unintended connectivity, compliance violations, or operational complexity during troubleshooting. Note: Each instance type supports a [maximum number of network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AvailableIpPerENI.html), based on the instance type and size.

To address these challenges, develop a clear security group taxonomy that aligns with your ENI roles. Create purpose-specific security groups for different ENI functions (such as management, application, and database) rather than using generic, overly broad rules. Implement infrastructure-as-code practices for security group management (or [AWS Firewall Manager](https://aws.amazon.com/firewall-manager/), but beware of the associated [costs](https://aws.amazon.com/firewall-manager/pricing/)) to ensure consistency and enable audit trails. Note that ENIs themselves do not incur direct charges - the costs are primarily related to data transfer and associated resources.

Remember that security group rules are stateful, while [Network Access Control lists (ACLs)](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html) are stateless and apply to all ENIs in a subnet. When troubleshooting connectivity issues in multi-ENI environments, verify both security group and NACL configurations. Use [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) to validate that your security group rules are working as intended, especially for secondary ENIs that may have non-obvious traffic patterns. Beware of the VPC Flow logs associated [costs](https://aws.amazon.com/cloudwatch/pricing/).

### Implement ENI Lifecycle Management and Automation

While organizations often postpone automating ENI lifecycle management, this manual approach becomes unsustainable as networks expand to hundreds of ENIs across complex environments. Without proper lifecycle management, ENI operations become error-prone and time-consuming. Orphaned ENIs generate unnecessary costs, IP address space becomes fragmented, and incident response times increase significantly. To address these issues:

* Build automation around ENI lifecycle events, including creation, attachment, detachment, and cleanup
* Implement tagging strategies that enable automated lifecycle management and cost allocation
* Create runbooks for common ENI operations
* Consider using [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-automation.html) for standardized ENI management procedures (while being mindful of associated [costs](https://aws.amazon.com/systems-manager/pricing/))
* Always verify attachment status before proceeding with dependent operations
* Monitor ENI attachment and detachment success rates as key operational metrics

### Design for IPv6 and Dual-Stack Scenarios

Most teams initially implement IPv4-only ENI configurations and later struggle to add [IPv6](https://aws.amazon.com/vpc/ipv6) support when business requirements or compliance needs arise. IPv6 adoption is accelerating, driven by mobile applications, IoT workloads, and regulatory requirements. Retrofitting IPv6 support into existing ENI architectures often requires significant rework and may cause service disruptions.

Design your ENI architecture with dual-stack capabilities from the start, even if you don't plan to use IPv6 immediately. Ensure your subnet configurations support both IPv4 and IPv6, and verify that your security group rules accommodate both IP versions. Test your applications' IPv6 compatibility early in the development cycle.

Unlike IPv4 private addresses, IPv6 addresses on ENIs are always publicly routable by default. However, this does not automatically mean they are accessible from the internet - they still require proper routing and security group configurations. This creates security implications that teams often overlook. Furthermore, IPv6 egress traffic from VPCs requires either an [internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html) or an [egress-only internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html), depending on your connectivity requirements.

### Use Cross-VPC Communication via ENI Attachments for Shared Resources

[Multi-VPC ENI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/scenarios-enis.html#creating-dual-homed-instances-with-workloads-roles-on-distinct-vpcs) attachments enable instances to connect across separate VPCs through primary and secondary ENIs. This allows teams to maintain network segregation while permitting specific workloads, such as virtual routers, firewalls, and databases, to communicate between VPCs. This is particularly valuable for use cases requiring logical separation of control and data plane traffic while maintaining connectivity for shared resources.

Use dual-homed instances across VPCs for the following:

* Overcome CIDR overlaps between two VPCs that can’t be peered together: You can use a secondary CIDR in a VPC and allow an instance to communicate across two non-overlapping IP ranges.
* Connect multiple VPCs within a single account: Enable communication between individual resources that would normally be separated by VPC boundaries.

### Operational Considerations

Effective ENI operations require proactive monitoring and clear troubleshooting procedures that extend beyond basic EC2 instance monitoring. Organizations should implement Amazon CloudWatch custom metrics to track ENI attachment states (via AWS Lambda and PutMetricData custom metrics), IP address utilization, and security group rule compliance. VPC Flow Logs should be used to monitor traffic patterns across all ENIs, not just primary interfaces, and to establish baseline metrics for network performance. Create operational dashboards that provide visibility into ENI lifecycle events, attachment/detachment success rates, and cross-Availability Zone traffic patterns. For troubleshooting, develop standardized procedures for common ENI issues, including attachment failures, IP address conflicts, and connectivity problems that span multiple ENIs. Note that custom [CloudWatch metrics](https://aws.amazon.com/cloudwatch/pricing/) and [Lambda](https://aws.amazon.com/lambda/pricing/) will incur additional cost respectively.

From a cost optimization perspective, regularly audit ENI inventory for orphaned or underutilized interfaces, since each ENI incurs charges regardless of usage. It's important to monitor cross-AZ data transfer costs that may result from suboptimal ENI placement and to consider consolidating ENIs when possible to reduce complexity without sacrificing functionality. Integration with other AWS services requires careful consideration, as services like [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/), [Container Network Interface (CNI)](https://github.com/containernetworking/cni) plugins, and third-party networking tools all interact with ENIs in ways that can affect your architecture. Always validate service integrations in non-production environments before implementing changes that affect ENI configurations.

## 8. Route Tables and Traffic Flow

How routing works within VPCs and how traffic decisions are made.

## 9. Gateways

Gateway selection represents an important architectural decision in AWS networking, yet it's often treated as an afterthought. Customers choice of gateway strategies can result in unnecessary costs. The challenge is to balance immediate connectivity needs against future scalability, cost optimization, and operational complexity. Customers frequently may assume that "connectivity is connectivity" and make decisions based solely on initial setup simplicity or documentation examples. In reality, each gateway type serves distinct use cases with dramatically different performance characteristics, cost structures, and operational implications.

### Map Gateway Selection to Traffic Patterns and Business Requirements First

Many customers select gateways based on immediate technical needs or familiarity, without analyzing actual traffic patterns, growth projections, or compliance requirements. Some customers may deploy Internet Gateways (IGW) for workloads that never actually need bidirectional internet access, or choose Virtual Private Gateways (VGW) for hybrid connectivity when Transit Gateway would provide better long-term scalability. Gateway selection impacts every aspect of your network architecture—cost, performance, security posture, and operational complexity. Wrong choices compound over time, creating technical debt that requires expensive migrations.

Start with traffic flow analysis before selecting any gateway. Document whether traffic is primarily inbound, outbound or bidirectional. Identify whether you need internet access, hybrid connectivity, or [VPC-to-VPC](https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/amazon-vpc-to-amazon-vpc-connectivity-options.html) communication. For internet access, Internet Gateways enable bidirectional traffic while NAT Gateways provide secure outbound-only connectivity. For hybrid scenarios, Direct Connect (Direct Connect Gateway) offers dedicated bandwidth while Virtual Private Gateway, Transit Gateway and Cloud WAN provides encrypted VPN connectivity. Transit Gateway serves as the strategic choice when you need to connect multiple VPCs or plan for complex routing scenarios.

Always plan for dual-stack (IPv4/IPv6) requirements early. AWS Transit Gateway, Direct Connect (Direct Connect Gateway) supports both IPv4 and IPv6 natively. NAT Gateway support NAT64 natively for IPv6-only subnets (along with DNS64), and IPv6 resources can use egress-only internet gateway (EIGW) for outbound-only internet IPv6 traffic only. Refer to [Services that support IPv6](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ipv6-support.html#ipv6-service-support). Consider compliance requirements—some industries mandate dedicated connections (Direct Connect) while others require encryption-in-transit.

### Design for High Availability Based on Gateway-Specific Modes

Each gateway type has different availability characteristics and failure modes that customers often overlook until experiencing outages. Customers may assume that NAT Gateways provides cross-AZ redundancy automatically. Gateway failures directly impact application availability and can cascade across your entire infrastructure. Understanding each gateway's availability model is crucial for designing resilient architectures. Internet Gateway, Egress-only internet gateway are horizontally scaled, redundant, and highly available VPC component. Similarly, AWS Transit Gateway, AWS CloudWAN and Direct Connect Gateways are highly available by design. However, NAT Gateways are AZ-specific resources.

Deploy NAT Gateways in multiple Availability Zones with corresponding route table configurations to ensure outbound internet access survives AZ failures. For Virtual Private Gateway deployments, configure multiple VPN tunnels and implement dynamic routing (BGP) to enable automatic failover. With Transit Gateway, design route tables with multiple path options and implement route propagation. Always test failure scenarios in non-production environments to validate your high availability design. NAT Gateway deployed in single AZ and then access by apps in other AZs can incur cross-AZ data transfer charges, that can add up—design your subnets and routing to minimize cross-AZ traffic while maintaining availability by deploying NAT Gateways in multiple-AZs.. For Direct Connect, always implement backup connectivity through VPN connections or a Secondary Direct Connect connection for [resiliency](https://aws.amazon.com/directconnect/resiliency-recommendation/).

### Understand Gateway Performance

Understand each gateway’s scaling and performance data to know where and when to use them. Both IGW and EIGW are horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. They don’t not cause availability risks or bandwidth constraints on your network traffic. Similarly, AWS Transit Gateways are highly available by design. Direct Connect Gateway is a globally available resource and has high availability inherently built into its design.  Know the performance quotas for: [AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html), [AWS Direct Connect](https://docs.aws.amazon.com/directconnect/latest/UserGuide/limits.html), [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html), [AWS Virtual Private Gateway](https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html).

### Knowing the Cost Implications of Usage-Based Gateway Selection

Many customers don't analyze [cost implications](https://aws.amazon.com/blogs/networking-and-content-delivery/estimate-aws-networking-costs-with-a-self-hosted-calculator/) during gateway selection. Un-necessary [NAT Gateway charges](https://repost.aws/knowledge-center/vpc-reduce-nat-gateway-transfer-costs) or Transit Gateway attachment fees for unused connections may consume significant budget without providing business value. Different gateway types have vastly different cost structures. NAT Gateway charges hourly plus data processing fees. Transit Gateway charges for attachments and data processing. Understanding these cost models enables informed architectural decisions that balance functionality with budget constraints.

Analyze actual bandwidth requirements before selecting for example NAT Gateway over NAT instances for cost-sensitive workloads with lower throughput needs. Evaluate Transit Gateway attachment consolidation opportunities—connecting multiple VPCs through shared Transit Gateway can reduce overall attachment costs compared to individual Virtual Private Gateway deployments. For seasonal or variable workloads, consider whether Lambda-based NAT solutions or scheduled gateway deployments could reduce costs. Implement detailed cost allocation tagging to understand per-gateway expenses and optimization opportunities.

NAT Gateway cross-AZ data transfer charges are separate from data processing charges—design subnet architecture to minimize these costs. Transit Gateway supports resource sharing across accounts, enabling cost distribution in multi-account environments. Direct Connect provides predictable costs through private connections, which can be more economical than internet-based transfer charges for high-volume workloads. [Transit Gateway cross-AZ data transfer](https://aws.amazon.com/about-aws/whats-new/2022/04/aws-data-transfer-price-reduction-privatelink-transit-gateway-client-vpn-services/) within the same AWS Region is free of charge.

### Plan Multi-Region and Hybrid Connectivity Architecture Strategically

Most customers approach multi-region and hybrid connectivity reactively, adding gateways as needs arise without considering the broader architectural implications. This results in complex, hard-to-manage topologies with suboptimal routing and unnecessary costs. For example, consolidating dozens of individual VPN connections that could have been simplified through Transit Gateway. Hybrid and multi-region connectivity decisions create long-term architectural commitments that are expensive and complex to change. Poor initial design leads to routing complexity, security challenges, and operational overhead that compounds over time. Strategic planning enables centralized management, optimized routing, and simplified operations.

Use Transit Gateway inter-region peering or AWS CloudWAN for multi-region VPC connectivity instead of individual cross-region VPC peering connections. Implement Direct Connect Gateway for centralized hybrid connectivity that can serve multiple regions and VPCs. Design hub-and-spoke topologies with Transit Gateway or AWS Cloud WAN as the central hub to simplify routing and security policy management. Plan IP address space carefully to avoid conflicts across regions and on-premises environments. Direct Connect Gateway can connect to Transit Gateways in multiple regions through a single Direct Connect location. Consider [AWS Global Accelerator](https://aws.amazon.com/global-accelerator/) for improved performance across regions when using Internet-based applications.

### Implement Security Controls Specific to Each Gateway Type

Security controls are often applied generically across gateway types without considering each gateway's specific attack surfaces and security models. Customers frequently misconfigure security groups and NACLs, creating either security gaps or overly restrictive policies that impact functionality. Each gateway type presents different security considerations and capabilities. Internet Gateways enable bidirectional traffic that requires careful access controls. NAT Gateways provide inherent outbound-only security but still require proper configuration. Transit Gateway route tables act as security boundaries that can be misconfigured to allow unwanted cross-VPC access.

Implement least-privilege security group rules specific to each gateway's traffic patterns. For Internet Gateway deployments, never allow `0.0.0.0/0` inbound access without specific justification and additional controls. Configure Transit Gateway route tables with explicit propagation and association rules rather than allowing automatic propagation. Implement VPC Flow Logs on all gateway-connected subnets to maintain visibility into traffic patterns and potential security issues. Use AWS Config rules to monitor gateway security configurations for compliance. Beware of [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-pricing) and AWS Config [costs](https://aws.amazon.com/config/pricing/).

You can't associate a security group with a NAT gateway. You can associate security groups with your instances to control inbound and outbound traffic. Transit Gateway supports security group referencing across VPCs, enabling centralized security policy management.

### Establish Monitoring and Observability

Gateway monitoring is often limited to basic CloudWatch metrics without comprehensive observability into performance, costs, and health indicators. Customers discover performance issues or cost overruns too late to take corrective action. Proactive monitoring enables early identification of performance issues, cost optimization opportunities, and capacity planning needs. Each gateway type provides different metrics and requires different monitoring approaches. Without proper observability, you're operating blind to potential issues that could impact application performance or costs.

Configure CloudWatch alarms for gateway-specific metrics— for example NAT Gateway `PacketsDropCount`, Transit Gateway [packet drops](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-cloudwatch-metrics.html#transit-gateway-metrics), and Direct Connect connection [state changes](https://docs.aws.amazon.com/directconnect/latest/UserGuide/monitoring-cloudwatch.html). Implement VPC Flow Logs analysis to understand traffic patterns and identify optimization opportunities. Use [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) and [billing alerts](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html) to monitor gateway-related costs and trends. Create custom dashboards that correlate gateway metrics with application performance metrics to understand impact relationships.

NAT Gateway `ErrorPortAllocation` errors indicate Source NAT port exhaustion—monitor this metric to identify when additional NAT Gateways are needed. Transit Gateway route analysis through [Reachability Analyzer](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html) can help identify routing issues before they impact production. Direct Connect CloudWatch metrics include connection state and virtual interface utilization—[monitor](https://docs.aws.amazon.com/directconnect/latest/UserGuide/monitoring-cloudwatch.html) these for hybrid connectivity health.

### Key Considerations

* Understanding Gateway Sprawl: Look for multiple individual VPN connections or Virtual Private Gateways serving similar connectivity needs. Warning signs include complex routing tables with numerous static routes, inconsistent security policies across similar VPCs, and operational teams struggling to troubleshoot connectivity issues. Cost analysis showing high VPN connection charges relative to data transfer can also indicate this anti pattern.

Implement Transit Gateway as a centralized hub and migrate VPC attachments gradually. Start with non-production VPCs to validate routing and security policies. Use Transit Gateway route tables to implement segmentation and security policies centrally. Plan migration windows carefully to avoid service disruption, and implement testing to validate connectivity before cut over.

* Using the "Wrong Tool for the Job": Internet Gateways deployed for workloads that never require inbound internet access. Security group rules with broad inbound access ranges. High operational overhead from managing bidirectional security policies for unidirectional traffic needs. Network security incidents involving unexpected inbound access to internal resources.

Analyze actual traffic patterns using VPC Flow Logs to confirm traffic direction requirements. Replace Internet Gateway with NAT Gateway for outbound-only workloads. Implement new route tables that direct outbound traffic through NAT Gateway while removing inbound routes. Update security groups to remove unnecessary inbound rules.

### Operational Considerations

From a day-2 operations perspective, each gateway type requires different monitoring approaches and maintenance considerations. NAT Gateways require monitoring for Source NAT port exhaustion and bandwidth utilization, while Transit Gateway deployments need route table validation and attachment health monitoring. Implement automated monitoring through CloudWatch alarms and AWS Config rules to detect configuration drift and performance issues proactively. VPC Flow Logs provide crucial visibility into traffic patterns and can help identify optimization opportunities or security concerns.

Cost optimization opportunities vary significantly by gateway type and usage patterns. NAT Gateway costs can be reduced through rightsizing based on actual bandwidth utilization or considering NAT instances for non-production workloads. Transit Gateway costs benefit from attachment consolidation and careful route table design to minimize data processing charges. Monitor detailed billing reports to understand per-gateway costs and identify optimization opportunities.

### Relevant Resources

* [Amazon VPC Connectivity Options](https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/introduction.html)
* [AWS Direct Connect Resiliency Recommendations](https://aws.amazon.com/directconnect/resiliency-recommendation/)
* [Dual Stack and IPv6-only Amazon VPC Reference Architectures](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/IPv6-reference-architectures-for-AWS-and-hybrid-networks-ra.pdf)
* [AWS services that support IPv6](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ipv6-support.html)

## 10. Internet connectivity patterns

Basic internet connectivity patterns and the decision between Centralized vs distributed NAT patterns, high availability.

## 11. Accessing AWS services

How users and resources access AWS services impacts network design, costs, and security. Rushed deployment decisions often result in unnecessary complexity and expenses. Many overspend on [NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) or face connectivity issues due to confusion between VPC interface/gateway endpoints and [Internet Gateway (IGW)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html) or [Egress-only Internet Gateway (EIGW)](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html) options. A key misconception is assuming private resources always need NAT gateways for AWS services. Customers often choose NAT gateways by default or implement [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html) ([powered by AWS PrivateLink](https://aws.amazon.com/privatelink/)) incorrectly, without considering long-term scalability and operational costs.

### Use VPC Gateway Endpoints for Amazon S3 and Amazon DynamoDB Access

Many customers default to using NAT gateways for private resource access to [Amazon S3](https://aws.amazon.com/s3/) or [Amazon DynamoDB](https://aws.amazon.com/dynamodb/), unaware that VPC gateway endpoints offer a more cost-effective solution. [NAT gateway pricing](https://aws.amazon.com/vpc/pricing/) includes hourly charges plus data processing fees per gigabyte, regardless of traffic direction. [VPC gateway endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html), however, are free. This can lead to substantial cost savings, especially for workloads with high S3 or DynamoDB traffic volumes. Note that VPC gateway endpoints do not use AWS PrivateLink, unlike other types of VPC endpoints.

To implement VPC gateway endpoints, associate them with your private subnet route tables. These endpoints leverage [AWS-managed prefix lists](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-aws-managed-prefix-lists.html) that update automatically. For S3 access, consider implementing [endpoint policies](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html) to restrict access to specific buckets, enhancing security. While S3 and DynamoDB also support interface endpoints, these are primarily recommended for access from out side the VPC, for e.g., [hybrid architectures](https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html#updating-on-premises-dns-config). The following comparison summarize the differences. Regardless of the type used, the network traffic remains on the AWS network.

* [Types of VPC endpoints for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html#types-of-vpc-endpoints-for-s3)
* [Types of Amazon VPC endpoints for Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/privatelink-interface-endpoints.html#types-of-vpc-endpoints-for-ddb)

VPC gateway endpoints operate at the route table level - resources in subnets without the endpoint route will continue using internet routes, enabling segmented access patterns. Note that VPC gateway endpoints don't support transitive routing through [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html), [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/), [AWS Cloud WAN](https://aws.amazon.com/cloud-wan/), [AWS VPN](https://aws.amazon.com/vpn/), or [AWS Direct Connect](https://aws.amazon.com/directconnect/).

### Use Interface Endpoints Efficiently Based on Traffic Patterns

Use VPC Interface endpoints when your applications need private access to [AWS services](https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html). While it's common to deploy endpoints for all AWS services, this practice can lead to unnecessary costs and complexity. Remember that [VPC interface endpoints incur](https://aws.amazon.com/privatelink/pricing/) both hourly charges per Availability Zone (AZ) and data processing charge.

* Deploy them in dedicated `/28` "endpoint subnets" separate from application subnets for better security and management
* Enable private DNS to allow applications to use the endpoint without code modifications
* Deploy across multiple AZs for [high availability](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html#aws-service-subnets-zones). Note that [beginning April 1, 2022](https://aws.amazon.com/about-aws/whats-new/2022/04/aws-data-transfer-price-reduction-privatelink-transit-gateway-client-vpn-services/), the inter-Availability Zone (AZ) data transfer within the same AWS Region for *AWS PrivateLink* (along with AWS Transit Gateway, and AWS Client VPN) is free of charge.
* Consider centralizing endpoints in shared services architectures using AWS Transit Gateway or AWS CloudWAN  for optimized costs
* Know the VPC endpoint [quotas](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-limits-endpoints.html) including bandwidth scaling
* Enable [Private DNS](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html#interface-endpoint-private-dns), and know the [DNS hostnames](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html#interface-endpoint-dns-hostnames) and [DNS Resolution](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html#interface-endpoint-dns-resolution). Use Regional endpoint DNS name that round robin between the endpoint IP addresses. But if you need to keep the latency low, use Zonal endpoint DNS name

Use interface endpoints for AWS services that require access from:

* Across the VPCs connected via VPC peering, AWS Transit Gateway, AWS CloudWAN, AWS VPN or AWS Direct Connect)
* Hybrid environments (AWS Transit Gateway, AWS CloudWAN, AWS VPN or AWS Direct Connect)

Additionally, you can also [share your own services](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-share-your-services.html) through VPC interface endpoints using AWS PrivateLink, which supports overlapping IP CIDRs.

### Minimize NAT Gateways Where Possible Through Service-Specific Analysis

Many architectures include NAT gateways "just in case," without documenting what actually needs internet access. These become expensive legacy components that customer may be afraid to remove.

Audit your internet-bound traffic using [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) to identify what services your resources actually access. Most internal applications only need access to AWS services, which can be provided through VPC endpoints. Create a matrix mapping each private resource to its external dependencies, then systematically replace NAT gateway usage with appropriate endpoints. Beware of the VPC Flow logs [costs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-pricing).

If your [AWS Lambda](https://aws.amazon.com/lambda/) only accesses AWS services, VPC endpoints eliminate the need for NAT gateways entirely. For container workloads, consider using VPC endpoints for [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) to avoid pulling images through NAT gateways—this alone can save significant costs for image-heavy deployments.

### Design Endpoint Subnet Architecture for Scalability and Security

Customers often place interface endpoints in their application subnets or create endpoints in every subnet, leading to management complexity and unexpected network behavior. Poor endpoint placement makes network troubleshooting difficult and can impact application performance. It also makes it harder to implement consistent security policies and complicates subnet CIDR planning.

Create dedicated endpoint subnets (`/28`) in each AZ where you need interface endpoints. Size these subnets appropriately—each interface endpoint consumes one IP address per AZ, so keep room for growth. Associate these subnets with route tables that don't have NAT gateway routes, forcing traffic through endpoints. Apply security groups that allow inbound access from your application subnets on the required ports (typically `443` for HTTPS).

Use separate endpoint subnets for different security zones or compliance requirements. For example, create separate endpoint subnets for production vs development environments, even within the same VPC. This pattern also simplifies DNS resolution troubleshooting—you can easily identify whether traffic is using endpoints or internet routes based on the destination IP address range.

### Implement Conditional Routing Based on Workload Requirements

Many implementations use a one-size-fits-all approach to service access, either routing everything through NAT gateways or trying to endpoint everything, rather than optimizing based on specific workload needs. Different workloads have different access patterns, security requirements, and cost sensitivities. A data processing job that occasionally uploads to S3 has different needs than a real-time application making constant API calls to multiple AWS services.

Create different subnet categories with different routing strategies. For example, use "compute subnets" with gateway endpoints only for S3/DynamoDB access, "integration subnets" with interface endpoints for frequently used services, and "egress subnets" with NAT gateways for workloads that genuinely need internet access. Move workloads between subnet types as their requirements evolve.

### Plan for IPv6 and Dual-Stack Considerations

Many customers ignore IPv6 when designing service access patterns, but AWS is moving toward IPv6-first for many services, and some customers require IPv6 for compliance or architectural reasons. For IPv6-only subnets, use [DNS64](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html#nat-gateway-dns64-what-is) with [NAT64](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html#nat-gateway-nat64-what-is) that help translate IPv6-only resources to communicate with IP4 and vice versa. NAT Gateway, natively support NAT64 without the need for any extra configuration setup. Enable DNS64 for IPv6-only subnet along with NAT64 to allow this communication. Understand the [requirements to enable IPv6 for an interface endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html#aws-service-ip-address-type).

Use egress-only internet gateways for outbound IPv6 internet access. Interface endpoints support both IPv4 and IPv6, but you need to plan your security group rules for both protocols. Consider using dual-stack subnets where you need both protocols during transition periods.

While IPv6 addresses are publicly routable by default, within VPC they cannot communicate without IGW or EIGW, so be extra careful with security group configurations. Many customers assume IPv6 works like IPv4 with private addresses, leading to security exposures. Test your endpoint configurations with both IPv4 and IPv6 traffic to ensure consistent behavior.

### Optimize Cross-Region Access Patterns

Interface endpoints support native [cross-region connectivity](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-share-your-services.html#endpoint-service-cross-region) but only for services that are shared via AWS PrivateLink using Network Load Balancers. As a service consumer, you can privately connect to VPC endpoint services in other AWS Regions without the need to setup cross-region peering or exposing your data over the public internet. Cross-region enabled VPC endpoint services can be accessed through Interface endpoints using private IP address in your VPC, enabling simpler and more secure inter-region connectivity. Note that access to AWS services via interface endpoints are still regional. Even though you can use cross-region connectivity patterns such as VPC peering, AWS Transit Gateway or AWS Cloud WAN, beware of the associated charges that can add up, and this also creates a region dependency, which is an anti-pattern.

### Key Considerations

* **The "NAT Gateway for Everything" Architecture**: Look for VPC Flow Logs showing traffic to AWS service IP ranges going through NAT gateway instances, or Amazon CloudWatch metrics showing consistent outbound traffic to AWS API endpoints. Review your route tables—if every private subnet has a default route to a NAT gateway, you likely may have this anti-pattern.

Start by implementing Amazon S3 and Amazon DynamoDB gateway endpoints, which are free. Then analyze your remaining internet-bound traffic using VPC Flow Logs to identify which services you're actually accessing. Replace NAT gateway usage service-by-service with appropriate interface endpoints. Finally, remove NAT gateways from subnets that no longer need internet access, keeping them only where genuine internet connectivity is required.

* **Interface Endpoint Sprawl Without Governance**: The opposite extreme is deploying interface endpoints for every possible AWS service without considering usage patterns or costs. Check your monthly bill for VPC endpoint charges that seem disproportionate to your usage, or count the number of interface endpoints in your VPC. If you have more endpoints than you have applications, you likely have this problem.

Audit your actual service usage through [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) and application logs to identify which endpoints are actually used. Remove unused endpoints —you can always recreate them later if needed. For lightly-used services, consider whether occasional internet access through a shared NAT gateway might be more cost-effective than dedicated endpoints. Evaluate if [centralizing the interface endpoints](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/centralized-access-to-vpc-private-endpoints.html) may be more applicable to your architecture instead of dedicated endpoints in every VPC, subnet.

* **Inconsistent Endpoint Policies and Security Groups**: Many customers deploy VPC endpoints with overly permissive policies or inconsistent security group configurations, creating security vulnerabilities and operational complexity.

Review your VPC endpoint policies—if they allow `*` for resources or principals, or if your endpoint security groups allow `0.0.0.0/0` access, you may have this anti-pattern. Also check if different endpoints have wildly different policy configurations without clear reasoning. Implement least-privilege endpoint policies that restrict access to specific resources and principals. Standardize your security group configurations across endpoints, using consistent naming and documentation. Consider using AWS Config rules to detect and alert on overly permissive endpoint configurations. Beware of the AWS Config [cost](https://aws.amazon.com/config/pricing/).

### Operational Considerations

Monitoring your service access patterns should be part of your regular cost optimization reviews. VPC Flow Logs provide excellent visibility into your traffic patterns, but they require analysis tools to be useful. Know the [billing codes](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-billing-usage-reports.html#vpce-billing-usage-reports) for VPC endpoints. Beware of VPC Flow logs [cost](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-pricing).

Use [Predefined Amazon CloudWatch queries](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-run-athena-query.html) using Amazon Athena to get the common usage patterns, though beware of Athena [cost](https://aws.amazon.com/athena/pricing/). [CloudWatch metrics](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-cloudwatch-metrics.html) for VPC endpoints show utilization patterns that can guide your scaling and optimization decisions. Set up [billing alerts](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html) for your networking components and review them monthly. Many customers save on networking costs by systematically replacing NAT gateways with appropriate endpoints. Use [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) to track networking cost trends and identify optimization opportunities as your usage patterns evolve.

### Relevant Resources

* [AWS re:Invent: VPC endpoints & PrivateLink: Optimize for security, cost & operations](https://youtu.be/LNf8jjBt72Y)
* [How do I find the top contributors to NAT gateway traffic in my Amazon VPC?](https://repost.aws/knowledge-center/vpc-find-traffic-sources-nat-gateway)
* [How do I reduce data transfer charges for my NAT gateway in Amazon VPC?](https://repost.aws/knowledge-center/vpc-reduce-nat-gateway-transfer-costs)
* [Reduce Cost and Increase Security with Amazon VPC Endpoints](https://aws.amazon.com/blogs/architecture/reduce-cost-and-increase-security-with-amazon-vpc-endpoints/)
* [Securely Access Services Over AWS PrivateLink](https://docs.aws.amazon.com/whitepapers/latest/aws-privatelink/aws-privatelink.html)

## 12. VPC DNS Resolution, DHCP Options

The [Domain Name System (DNS)](https://en.wikipedia.org/wiki/Domain_Name_System) is a standard protocol that resolves internet names to their corresponding IP addresses. A DNS hostname is a unique and absolute name for a computer, consisting of a hostname and a domain name. DNS servers translate these DNS hostnames into their corresponding IP addresses. Workloads consistently require reliable, high-performing internal name resolution (DNS) for service discovery, database connections, and inter-service communication. As an AWS architect or administrator, one of the fundamental networking components you'll work with is the `Amazon DNS server`, or `AmazonProvidedDNS` also known as the Route 53 Resolver. This DNS resolver service is natively integrated into each Availability Zone within your AWS Region, providing a reliable and scalable solution for domain name resolution within your Virtual Private Cloud (VPC).

The Route 53 Resolver is located at `169.254.169.253` (IPv4), `fd00:ec2::253` (IPv6), and at the primary private IPV4 CIDR range provisioned to your VPC plus two. For example, if you have a VPC with an IPv4 CIDR of `10.0.0.0/16` and an IPv6 CIDR of `2001:db8::/32`, you can reach the Route 53 Resolver at `169.254.169.253` (IPv4), `fd00:ec2::253` (IPv6), or `10.0.0.2` (IPv4). Resources within a VPC use a [link local address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#link-local-addresses) for DNS queries. These queries are transported to the Route 53 Resolver privately and are not visible on the network. In an IPv6-only subnet, the IPv4 link-local address (169.254.169.253) is still reachable as long as Route 53 Resolver is the name server in the DHCP option set. Note that the base VPC CIDR + 2 address is only available in addition to the link-local addresses when `enableDnsSupport` is true.

### Configure VPC DNS using default settings

[Understand](https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#vpc-dns-support) and enable both `enableDnsHostnames` and `enableDnsSupport` in your VPC as these attributes determine the DNS support provided for your VPC. Understand the Rules and considerations

* `enableDnsHostnames`: Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses.. The default for this attribute is false unless the VPC is a default VPC
* `enableDnsSupport`: Determines whether the VPC supports DNS resolution through the Amazon provided DNS server. If this attribute is true, queries to the Amazon provided DNS server succeed.

Note the [Rules and considerations](https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#vpc-dns-support) for these above attributes, as they directly impact the [DNS hostnames for EC2 instances](https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#vpc-dns-hostnames) and how they are resolved.

### Understand DHCP option sets for your VPC

A [Dynamic Host Configuration Protocol (DHCP)](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) option set is a group of network settings used by resources in your VPC, such as EC2 instances, to communicate over your virtual network. It plays a critical role in managing network settings for your EC2 instances and other resources within your VPC. [DHCP](https://docs.aws.amazon.com/vpc/latest/userguide/DHCPOptionSetConcepts.html) options control which DNS servers your EC2 instances use and what domain suffix they append to unqualified hostnames. Incorrect DHCP configuration can cause instances to query external DNS servers for internal resources, create security vulnerabilities, or fail to resolve critical services during network issues.

Each Region has a default DHCP option set. Each VPC uses the default DHCP option set for its Region unless you either create and associate a custom DHCP option set with the VPC or configure the VPC with no DHCP option set. You can associate a DHCP option set with multiple VPCs, but each VPC can have only one associated DHCP option set. Note that after you create a DHCP option set, you cannot modify it (immutable). To update the DHCP options for your VPC, you must create a new DHCP option set and then associate it with your VPC.

You can use either the Default or Custom DHCP option set, as they allow you to customize network settings like domain names, DNS servers, and more. For the Default DHCP option set, `AmazonProvidedDNS` is used.

If your VPC has no DHCP option set configured:

* For [EC2 instances built on the Nitro System](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#instance-hypervisor-type), AWS configures `169.254.169.253` as the default domain name server.
* For [EC2 instances built on Xen](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#instance-hypervisor-type), no domain name servers are configured and, because instances in the VPC have no access to a DNS server, they can't access the internet.

Key considerations include:

* Consistent Configuration: Ensure DHCP settings are consistent with your network architecture.
* Regular Reviews: Periodically review and update your DHCP configurations to align with changing network requirements.

### Use Private Hosted Zones for Service Discovery Patterns

Many teams rely on Elastic Load Balancer (ELB) DNS names or hardcoded service endpoints instead of implementing proper service discovery through Route 53 private hosted zones. This creates fragile architectures that can break during service migrations or infrastructure changes. Without proper DNS-based service discovery, applications become tightly coupled to specific infrastructure components. When teams need to migrate databases, replace load balancers, or implement blue-green deployments, hardcoded endpoints require application code changes rather than simple DNS updates.

To access resources in your VPC using custom DNS domain names (such as `example.com`) instead of private IPv4 addresses or AWS-provided private DNS hostnames, you can create a private hosted zone (PHZ) in Route 53. Private hosted zones support both IPv4 and IPv6 records – you should configure both A and AAAA records for future-proofing, even if you're not currently using IPv6. It's recommended to use short TTL values (60-300 seconds) for records that might need rapid updates during deployments or failover events.

To use a private hosted zone, both `enableDnsHostnames` and `enableDnsSupport` must be set to true in your VPC configuration. It's important to understand all [considerations](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-considerations.html) when working with private hosted zones. Use [Route 53 Profiles](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/profiles.html), centrally apply and manage DNS-related Route 53 configurations across many VPCs and in different AWS accounts. Note that Private Hosted Zones can be associated with multiple VPCs, but the VPCs must be in the same AWS Region or connected via VPC peering. Also that there are [quotas](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html#limits-api-entities-hosted-zones) to the number of private hosted zones per AWS account.

### Optimize DNS query performance

Many teams rarely monitor or optimize DNS query performance, assuming default resolver behavior is sufficient. This oversight often leads to application latency issues that are difficult to diagnose because DNS queries aren't included in typical application performance monitoring. Excessive DNS queries can significantly impact application response times, especially in microservices architectures where services make frequent cross-service calls. Poor DNS caching strategies can amplify this impact, causing cascading performance issues during high-traffic periods.

Configure appropriate [Time to live (TTL)](https://en.wikipedia.org/wiki/Time_to_live) values for your DNS records based on change frequency – use [longer TTLs](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-basic.html#rrsets-values-basic-ttl) (3600+ seconds) for stable infrastructure records and shorter TTLs (60-300 seconds) for records that might change during deployments. Implement [DNS caching](https://repost.aws/knowledge-center/dns-resolution-failures-ec2-linux) at the application level for frequently queried hostnames.

While the `Route 53 Resolver` resolver caches queries, applications often make repeated queries due to short-lived connections or poor caching implementations. To reduce query volume, implement connection pooling and use DNS caching libraries in your applications. Use Route 53 Resolver endpoints, as they provide [higher DNS queries per second (QPS)](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html).

Use [Amazon CloudWatch Contributor Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContributorInsights-CreateRule.html) rules for DNS query analysis. You can use built-in sample rules when you create a rule or you can create your own rule from scratch. Be mindful of the cost implications of query logging, as you incur [Amazon CloudWatch charges](https://aws.amazon.com/cloudwatch/pricing/).

### Use DNS monitoring and logging

There is a [1024 packet per second (PPS) limit](https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#vpc-dns-limits) to services that use [link-local](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#link-local-addresses) addresses including `Route 53 Resolver`. This limit includes the aggregate of Route 53 Resolver DNS queries. If you reach the quota, the Route 53 Resolver [rejects traffic](https://repost.aws/knowledge-center/vpc-find-cause-of-failed-dns-queries).

Monitor [`linklocal_allowance_exceeded`](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html) instance level network performance metric, which is available on both Windows and Linux instances using Elastic Network Adapter (ENA). This metric indicates the number of packets dropped due to PPS rate allowance exceeded for local services such as Route 53 DNS Resolver, Instance Metadata Service, Amazon Time Sync Service. Dropped packets often indicate suboptimal design choices or misconfiguration. Note that this allowance remains constant across all instance types.

Enable [Route 53 Resolver query logging](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html) for all VPCs and send logs to Amazon CloudWatch or Amazon S3 for analysis. Implement automated monitoring for unusual DNS query patterns, such as queries to suspicious domains, high-frequency queries to single domains, or queries with unusual characteristics (extremely long domain names, unusual character patterns). Use AWS Security Hub and GuardDuty to detect DNS-based threats automatically.

DNS query logs can generate significant volume – implement lifecycle policies to manage storage costs while retaining data for sufficient time for security analysis. Consider using Amazon Kinesis Data Firehose to stream DNS logs to your SIEM solution for real-time threat detection.

To monitor DNS activity, enable Route 53 Resolver query logging for all VPCs and direct logs to [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) or [Amazon S3](https://aws.amazon.com/s3/) for analysis. Implement automated monitoring to detect unusual DNS query patterns, including:

* Queries to suspicious domains
* High-frequency queries to single domains
* Queries with unusual characteristics (such as extremely long domain names or unusual character patterns)
* Additionally, use [AWS Security Hub](https://aws.amazon.com/security-hub/) and [Amazon GuardDuty](https://aws.amazon.com/guardduty/) for automatic detection of DNS-based threats.

Since DNS query logs can generate significant volume, implement lifecycle policies to manage storage costs while retaining data long enough for security analysis. Consider using [Amazon Data Firehose](https://aws.amazon.com/firehose/) to stream DNS logs to your [Security Information and Event Management (SIEM)](https://en.wikipedia.org/wiki/Security_information_and_event_management) solution for real-time threat detection.

### Use DNS64 for IPv6-only VPC Subnets

DNS64, paired with NAT64, allow IPv6-only workloads in the VPC communicate with IPv4-only services outside your subnet. This is particularly useful during the transition from IPv4 to IPv6, as it allows your IPv6 services to access IPv4 resources. [DNS64](https://en.wikipedia.org/wiki/IPv6_transition_mechanism) is a mechanism that synthesizes [AAAA records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/ResourceRecordTypes.html#AAAAFormat) from [A records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/ResourceRecordTypes.html#AFormat) to enable communication between IPv6-only clients and IPv4-only servers.

IPv6-only workloads running in VPCs can only send and receive IPv6 network packets. Without DNS64, a DNS query for an IPv4-only service will return an IPv4 destination address in response, making it impossible for your IPv6-only service to communicate with it. To bridge this communication gap, [enable DNS64](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html#nat-gateway-nat64-dns64-walkthrough) for IPv6-only subnets, and it will apply to all AWS resources within that subnet. You will need to use [NAT64](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html#nat-gateway-nat64-what-is) in your VPC with DNS64 either through Amazon Route 53 Resolver or by implementing your own DNS64 server. Regular NAT Gateway [charges](https://aws.amazon.com/vpc/pricing/) may apply.

A few caveats to keep in mind:

* The source IPv6 address isn’t preserved when using NAT64, which means no source-IP filtering.
* DNS64 is inherently asymmetric. It provides IPv6-only clients with synthetic AAAA records to reach IPv4-only destinations, but it cannot help IPv4-only clients reach IPv6-only services. If a domain operates in an IPv6-only environment without associated A records, IPv4-only and dual-stack clients cannot connect.
* [Domain Name System Security Extensions (`DNSSEC`)](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec.html) doesn’t work with DNS64. Since `DNSSEC` relies on cryptographic signatures of DNS records, the dynamic synthesis of AAAA records by DNS64 resolvers can cause validation failures. To address this, admins must understand and potentially deploy DNS64-aware `DNSSEC` validation, such as using the [CD (Checking Disabled)](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions).
* DNS64 and NAT64 introduce additional steps in the resolution and transport process. The DNS64 resolver must perform two lookups—first for an AAAA record and then an A record if the AAAA does not exist.

### Operational Considerations

DNS operations in production require proactive monitoring and troubleshooting capabilities that extend beyond basic connectivity testing. Implement comprehensive logging to capture DNS query volumes, response times, and failure rates across your entire DNS infrastructure. Use Amazon CloudWatch metrics to monitor Route 53 Resolver query volumes and establish alarms for unusual patterns that might indicate service issues or security threats. Create runbooks for common DNS troubleshooting scenarios, including tools and techniques for diagnosing resolution failures at different layers of your DNS hierarchy. Consider the operational impact of DNS changes—even simple updates to DHCP option sets require instance reboots or network interface refreshes to take effect—and plan changes during maintenance windows.

Monitor your query patterns and optimize application-level DNS caching to reduce unnecessary queries. When integrating with other AWS services, remember that services like [Amazon EKS](https://aws.amazon.com/eks/) and [Amazon ECS](https://aws.amazon.com/ecs/) have their own DNS requirements and integration patterns that can affect your overall VPC DNS design. Plan for service discovery patterns that align with your chosen container orchestration platform, and ensure your DNS architecture supports the dynamic nature of containerized workloads without creating performance bottlenecks or security vulnerabilities.

### Relevant Resources

* [DNS best practices for Amazon Route 53](https://aws.amazon.com/blogs/networking-and-content-delivery/dns-best-practices-for-amazon-route-53/)
* [How to optimize DNS for dual-stack networks](https://aws.amazon.com/blogs/networking-and-content-delivery/how-to-optimize-dns-for-dual-stack-networks/)
* [How do I determine whether my DNS queries to the Amazon DNS server fail because of VPC DNS throttling?](https://repost.aws/knowledge-center/vpc-find-cause-of-failed-dns-queries)
* [How does DNS work, and how do I troubleshoot partial or intermittent DNS failures?](https://repost.aws/knowledge-center/partial-dns-failures)

## 13. Security Groups vs. Network Access Control Lists (NACLs)

The choice between the two security layers, VPC [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) and [Network Access Control Lists (NACLs)](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html), often determines whether you'll have a maintainable, scalable network architecture or a complex set of rules that becomes increasingly difficult to manage as your infrastructure grows. The most common misconception is treating Security Groups and NACLs as interchangeable tools. Customers often default to what they know from traditional networking—implementing subnet-level controls with NACLs because "that's how we've always done firewalls." This approach frequently leads to over-engineered solutions that are difficult to troubleshoot and maintain. Conversely, some customers rely solely on Security Groups without understanding when network-level controls provide superior security or operational benefits.

### Start with Security Groups, use NACLs for Specific Use Cases

Most customers jump straight to implementing both Security Groups and NACLs simultaneously, creating unnecessary complexity from day one. In an Amazon VPC, Network ACLs are optional for subnet-level traffic filtering, while Security Groups are mandatory for instance-level protection.

Security Groups provide 90% of what most applications need for network security. Adding NACLs without a clear use case creates operational overhead, increases troubleshooting complexity, and often introduces subtle connectivity issues that are difficult to diagnose. Customers may spend considerable time debugging connectivity problems that stem from conflicting NACL rules they forgot they implemented.

Begin every VPC design with Security Groups as your primary security control. Only implement NACLs when you have specific requirements such as:

* Compliance mandates requiring  subnet-level controls
* Defense-in-depth requirements for  highly sensitive workloads
* Network-level logging for  forensics or compliance
* Blocking traffic between subnets  in the same VPC
* Implementing coarse-grained deny  rules for entire subnet ranges

Document your NACL implementation rationale clearly. Create a decision matrix that explains why NACLs are necessary for each subnet. This prevents future team members from removing "seemingly redundant" rules that serve critical security functions. Also, remember that NACLs evaluate rules in order—always place your most specific deny rules at the top, followed by broader allow rules.

### Use Security Group Referencing for Dynamic Architectures

Customers often hard-code IP addresses or CIDR blocks in Security Group rules, creating configurations that break when infrastructure scales or changes.

[Security Group referencing](https://repost.aws/articles/ARY9viGjzLTSS_4UYNudZl9Q/how-to-check-security-group-references-within-and-across-vpcs) allows you to create dynamic, self-maintaining security policies that automatically adapt as your infrastructure scales. Without this approach, you'll spend significant operational time updating security rules every time you add new instances, change IP ranges, or implement auto-scaling.

Design Security Groups to reference other Security Groups rather than IP addresses wherever possible. Create logical groupings like "web-tier-sg," "app-tier-sg," and "database-tier-sg," then allow traffic between these groups by referencing the source Security Group ID. This creates a logical security model that remains valid regardless of the actual IP addresses assigned to instances.

For multi-VPC architectures, you can reference Security Groups across VPCs that are connected via VPC peering, AWS Transit Gateway, or VPC sharing. This enables consistent security policies across your entire AWS infrastructure without maintaining separate rule sets.

Use descriptive Security Group names and descriptions that clearly indicate their purpose. Customers often use generic names like "sg-12345" that become challenging to manage at scale. Also, consider creating "service" Security Groups that define what ports and protocols a service needs, separate from "client" Security Groups that define what can access those services.

### Understand the Stateful vs. Stateless Implications for Application Architecture

Customer often don't understand how the stateful nature of Security Groups vs the stateless nature of NACLs affects their application design, leading to connectivity issues that are difficult to troubleshoot.

The stateful nature of Security Groups means return traffic is automatically allowed, while NACLs require explicit rules for both inbound and outbound traffic. This fundamental difference affects how you design applications, especially those that use [ephemeral ports](https://en.wikipedia.org/wiki/Ephemeral_port), establish database connections, or implement health checks.

For Security Groups, you typically only need to define inbound rules for services—the outbound return traffic is automatically allowed. However, you should still implement explicit outbound rules following the principle of least privilege. For example, allow your web servers to reach only specific database ports rather than leaving outbound rules completely open.

With NACLs, you must account for both directions of traffic flow. This includes ephemeral port ranges (typically `32768-65535` for Linux, `49152-65535` for Windows Server 2008+) for return traffic. Consider the operational complexity this creates—every new service or application may require updates to both inbound and outbound NACL rules.

When using NACLs with load balancers, remember that health checks originate from the load balancer's IP range and require explicit rules. For Application Load Balancers (ALB), the source IP will be the ALB's private IP addresses. For Network Load Balancers (NLB), the source IP could be the client's IP (in IP target mode) or the NLB's IP (in instance target mode).

### Design for IPv6 and Dual-Stack from the Beginning

Many customers implement IPv4-only security rules initially, then struggle to retrofit IPv6 support when business requirements or compliance mandates drive adoption.

IPv6 adoption is accelerating due to IoT growth, mobile applications, and compliance requirements. Retrofitting IPv6 support into existing Security Group and NACL configurations is error-prone and often requires significant architectural changes. Customer may spend months reworking their security policies when they could have designed for dual-stack from the beginning.

When creating Security Groups and NACLs, consider whether you need IPv6 support now or in the future. If there's any possibility of IPv6 adoption, implement dual-stack rules from the beginning. This means creating parallel rule sets for both IPv4 and IPv6 address families.

For Security Groups, create separate rules for IPv4 (using CIDR blocks such as `10.0.0.0/8`) and IPv6 (using CIDR blocks such as `2001:db8::/32`). For NACLs, you'll need separate rule numbers for IPv4 and IPv6 traffic, as they're evaluated independently.

IPv6 security considerations differ from IPv4. IPv6 addresses are globally routable by default, though you still need an [IGW](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html) or [EIGW](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html) in your VPC, so your security policies must account for this. Also, IPv6 doesn't use NAT in the traditional sense, which changes how you think about outbound internet access. Consider using egress-only internet gateways for IPv6 outbound traffic that shouldn't accept inbound connections from the internet.

### Implement Layered Security with Clear Boundaries and Responsibilities

Customers often implement overlapping security controls without clear boundaries, creating confusion about which layer handles which security concerns.

Unclear security boundaries lead to gaps in coverage, conflicts between rules, and operational confusion during incident response. When security layers overlap without clear ownership, critical updates might be missed, or conflicting changes might be made simultaneously. Define clear responsibilities for each security layer. A common pattern is:

* NACLs: Coarse-grained network controls, compliance requirements, and subnet-level isolation
* Security Groups: Fine-grained application controls, service-to-service communication, and dynamic scaling scenarios

For example, use NACLs to block entire countries or IP ranges for compliance, deny traffic between development and production subnets, or implement broad protocol restrictions. Use Security Groups for application-specific rules like allowing web servers to access specific database ports or enabling communication between microservices.

Document your security model clearly and train your team on when to use each layer. Create standard templates for common scenarios. Also, consider using AWS Config rules to monitor for configuration drift and ensure your security policies remain consistent over time. Beware of AWS Config [cost](https://aws.amazon.com/config/pricing/).

### Plan for Multi-Account and Cross-VPC Communication Patterns

Many customers start with single-VPC designs but eventually need to support multi-VPC or multi-account architectures, often requiring significant security policy rework.

Cross-VPC communication through AWS Transit Gateway, VPC peering, or inter-region connectivity requires careful planning of Security Group and NACL strategies. Poorly planned cross-VPC security can create bottlenecks, security gaps, or overly permissive rules that violate compliance requirements.

When designing security policies, consider your future multi-VPC needs. Security Groups can reference other Security Groups across VPC peers and AWS Transit Gateway attachments, enabling consistent security policies across your infrastructure. NACLs, however, work only at the subnet level within individual VPCs.

For [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/) environments, consider creating centralized Security Groups that can be referenced across multiple VPCs. This enables consistent security policies while maintaining the flexibility to customize rules for specific environments or applications.

Use [AWS Resource Access Manager (RAM)](https://aws.amazon.com/ram/) to share AWS Transit Gateways and other networking resources across accounts while maintaining security boundaries. Also, consider using VPC endpoints for AWS services to avoid routing traffic through your security layers unnecessarily, which can simplify your rule sets and improve performance.

### Optimize for Scale and Performance Characteristics

Customers often don't consider the scale and performance implications of their Security Group and NACL designs until they encounter limits or performance issues in production.

Security Groups and NACLs have different scale characteristics and performance implications. Understand the [service quotas](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html) for both Security Groups and NACLs. Each Security Group can have up to `60` inbound and `60` outbound rules, and each network interface can be associated with up to `5` Security Groups (giving you effectively `300` inbound and `300` outbound rules per interface). NACLs can have up to `20` rules each for inbound and outbound traffic per NACL.

Plan your rule consolidation strategy early. Instead of creating many specific rules, use CIDR aggregation where possible. For example, instead of creating separate rules for `10.0.1.0/24`, `10.0.2.0/24`, and `10.0.3.0/24`, use a single rule for `10.0.0.0/22` if the security requirements are identical.

Monitor your Security Group and NACL rule counts using [AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html). Beware of the AWS Config [cost](https://aws.amazon.com/config/pricing/).

### Key Considerations

**Treating NACLs Like Traditional Firewalls**: Customers may implement complex NACL rule sets trying to replicate their on-premises firewall configurations. They create dozens of specific rules for individual applications, protocols, and port ranges, often resulting in NACLs with many rules that are difficult to understand and maintain.

Look for NACLs with many specific rules, especially those that seem to duplicate functionality available in Security Groups. Another sign is when teams modify NACLs frequently as part of application deployments—this suggests they're using NACLs for dynamic, application-level controls that would be better handled by Security Groups.

Audit your existing NACL rules and categorize them into network-level controls (keep in NACLs) vs application-level controls (migrate to Security Groups). Start by removing NACL rules that duplicate Security Group functionality. For complex rule sets, create a migration plan that moves rules to Security Groups in phases, testing connectivity after each phase. Use VPC Flow Logs during the migration to verify that legitimate traffic isn't being blocked.

**Creating Overly Permissive Security Groups to Avoid NACL Complexity**: Customers implementing both Security Groups and NACLs sometimes create overly broad Security Group rules (like allowing all traffic on all ports) because they assume the NACLs will provide the necessary restrictions. This creates a false sense of security while actually reducing your overall security posture.

Look for Security Groups with rules like `0.0.0.0/0` on all ports, or Security Groups that allow broad port ranges without clear justification. Another indicator is when Security Group rules haven't been updated in months while NACL rules are frequently modified—this suggests the Security Groups aren't being used as intended.

Implement proper Security Group rules first, then evaluate whether your NACLs are actually necessary. Use AWS Config rules to identify overly permissive Security Groups and create remediation plans. The key is to make each layer do what it does best rather than relying on one to compensate for weaknesses in the other.

**Ignoring Ephemeral Port Requirements in NACL Design**: Customers implement restrictive outbound NACL rules without accounting for ephemeral ports used by return traffic, causing intermittent connectivity issues that are difficult to troubleshoot. Applications work sometimes but fail others, especially during high-traffic periods when different ephemeral ports are used.

Look for applications that experience intermittent connectivity issues, especially for outbound connections to databases, APIs, or external services. VPC Flow Logs showing `REJECT` entries for high port numbers (typically above `32768`) often indicate this problem. Another sign is when applications work from some subnets but not others, despite having identical Security Group rules.

Review all outbound NACL rules and ensure they account for return traffic on ephemeral ports. This typically means allowing outbound traffic on ports `32768-65535` for Linux instances or `49152-65535` for Windows instances. If security requirements prevent opening these ranges broadly, consider redesigning your application architecture to use specific port ranges that you can control, or evaluate whether the NACL restrictions are truly necessary for your security model.

### Operational Considerations

Managing Security Groups and NACLs effectively requires ongoing attention to monitoring, troubleshooting, and optimization. [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) is the primary tool for understanding traffic patterns and diagnosing connectivity issues. Enable Flow Logs at the VPC level and configure them to capture both accepted and rejected traffic. Use [Amazon CloudWatch Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html) or [Amazon Athena](https://aws.amazon.com/athena/) to query Flow Logs efficiently—Create saved queries for common troubleshooting scenarios like identifying blocked traffic or analyzing traffic patterns between security groups. Beware of [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/pricing/) and [Amazon Athena](https://aws.amazon.com/athena/pricing/) costs.

For cost optimization, remember that VPC Flow Logs incur storage and analysis costs that can become significant at scale. Consider using sampling or filtering to reduce costs while maintaining visibility into your traffic patterns. AWS Config provides continuous monitoring of Security Group and NACL configurations, helping you identify configuration drift and ensure compliance with your security standards. Set up Config rules to alert on overly permissive rules, unused Security Groups, or changes to critical NACL configurations.

Integration with other AWS services requires careful consideration of how Security Groups and NACLs affect service functionality. AWS services like Application Load Balancers, RDS, and Lambda have specific networking requirements that must be accounted for in your security policies. For example, RDS instances in private subnets require appropriate Security Group rules for database access, while Lambda functions need outbound internet access for API calls unless you're using VPC endpoints. Understanding these service-specific requirements helps you design security policies that enhance rather than hinder your application architecture. AWS provides extensive documentation on networking requirements for each service, and the [AWS Well-Architected Framework - Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/protecting-networks.html) includes guidance on implementing defense-in-depth networking strategies that leverage both Security Groups and NACLs effectively.

### Relevant Resources

* [VPC Security best practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

## 14. Network Performance and Sizing

EC2 instance networking capabilities can vary based on instance family, size, and placement decisions. A common myth may that "bigger instances always mean better network performance" or that placement groups are only relevant for [High Performance Computing (HPC)](https://aws.amazon.com/hpc). In reality, network performance scaling is nuanced, with considerations around burst vs. sustained performance, cross-AZ traffic patterns, and the interplay between compute, storage, and network resources.

### Understanding Burst vs. Sustained Performance**

Many customers select instance types based on CPU and memory requirements while treating network performance as secondary. This leads to compute-optimized instances handling network-intensive workloads, or memory-optimized instances being oversized when network throughput may create the bottleneck.

Network performance scales non-linearly within instance families. For example, an EC2 c5.large instance provides [750 Mbps baseline with up to 10 Gbps](https://docs.aws.amazon.com/ec2/latest/instancetypes/co.html#co_network) burst, while a c5.xlarge instance offers the same 10 Gbps burst but delivers better sustained performance at 1.25 Gbps baseline. Mismatched ratios waste resources—you pay for unused compute while network performance constrains you, or you have abundant network capacity but insufficient compute resources to use it effectively.

EC2 instance network specifications list burst capabilities that aren’t sustained. [Certain EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) use baseline bandwidth with network I/O credits to burst beyond baseline on a best-effort basis. Applications exceeding baseline throughput during peak hours face performance degradation when burst credits exhaust. This can affect for e.g., batch processing workloads, database migrations, and backup operations requiring sustained high throughput.

### Key Guidelines

* [Monitor baseline and burst network performance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) for your specific EC2 instance type
* Instance bandwidth apply to inbound and outbound traffic, depending on destination and traffic flow patterns [(single flow vs multi-flow)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html)
* All [Nitro-based instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#instance-hypervisor-type) use [Elastic Network Adapter (ENA) Express](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ena-express.html) for enhanced networking, powered by AWS Scalable Reliable Datagram (SRD) technology that uses dynamic routing to increase throughput and minimize latency
* Non-Nitro instance types use [Enhanced Networking](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html) with Single Root I/O Virtualization (SR-IOV) for high-performance networking on supported instance types.
* Calculate sustained network throughput requirements separately from peak burst needs. For workloads requiring sustained high throughput, choose instance types where your required throughput stays at or below baseline performance. For periodic high-throughput workloads, schedule them during low-traffic periods to leverage burst capacity recovery. Consider multiple smaller instances instead of fewer larger ones to achieve better sustained aggregate throughput. Some instance types support [configurable bandwidth](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configure-bandwidth-weighting.html) weighting between network processing and Elastic Block Store (EBS) operations. Default baseline bandwidth settings are determined by instance type.
* The ENA driver publishes [network performance metrics](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html) from enabled instances. Use these metrics to troubleshoot performance issues, choose appropriate instance sizes for workloads, plan scaling activities proactively, and benchmark applications to determine whether they maximize available instance performance.

### Use Placement Groups for performance-critical workloads

A [placement group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) (optional) is a logical grouping of instances within an Availability Zone that helps you to influence the placement of individual EC2 instances to meet specific requirements for performance, latency, or compliance. Placement groups are often treated as an all-or-nothing decision, with entire applications placed in cluster placement groups or none at all. In practice, the most effective approach involves selective use of different placement group types ([Cluster](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-cluster), [Partition](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-partition) or [Spread](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-spread)) for different tiers of your architecture. Cluster placement groups can significantly reduce latency between instances for the same AZ communication, but they concentrate failure risk. Spread placement groups reduce failure correlation but may increase latency. Partition placement groups offer a middle ground but are frequently overlooked for database sharding or distributed system deployments.

[Reduce the number of network hops](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ena-improve-network-latency-linux.html) for data packets. Use cluster placement groups selectively for tightly coupled components like database primary-replica pairs or application servers that perform frequent inter-node communication. Reserve spread placement groups for independent application instances behind load balancers. Leverage partition placement groups for distributed databases like Cassandra or MongoDB where you need both performance and failure isolation. Never place your entire infrastructure in a single cluster placement group—instead, create multiple smaller groups aligned with your application's communication patterns.

Placement groups can't span regions but can span AZs (except cluster type). When launching instances into an existing placement group, always use the same instance type and launch them simultaneously when possible to avoid capacity issues. If you receive placement group capacity errors, try launching in a different AZ within the same region, or temporarily launch smaller instance types and resize later.

### Cross-AZ communication patterns

Many customers focus on high availability by spreading resources across AZs without considering the cumulative cost impact of cross-AZ data transfer. This can represent a significant portion of the total infrastructure costs for data-intensive applications.

Cross-AZ data transfer costs [$0.01-0.02 per GB](https://aws.amazon.com/ec2/pricing/on-demand/) depending on the AWS Region, which accumulates quickly for applications with chatty microservices or frequent database replication. More critically, cross-AZ latency is typically ~1-2ms higher than intra-AZ communication, which can compound in applications making hundreds of service calls per request.

Implement AZ affinity in your application architecture where feasible. Use Application Load Balancer (ALB)/Network Load Balancer (NLB) [target group attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-target-group-attributes.html#disable-cross-zone) to enable cross-zone load balancing only when necessary—disable it for applications that can tolerate some imbalance to reduce cross-AZ traffic. For database architectures, consider read replicas in the same AZ as your primary application servers for read-heavy workloads. Design your microservices communication patterns to minimize cross-AZ calls—consider using message queues or event-driven architectures to reduce synchronous cross-AZ communication.

Use [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) with cost allocation tags to identify your highest cross-AZ traffic patterns. Many applications generate surprising amounts of cross-AZ traffic through health checks, monitoring agents, or chatty service meshes. Consider using [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/) for applications requiring ultra-low latency to specific geographic areas, as they can reduce both latency and data transfer costs compared to cross-AZ communication.

### Implement Network Performance Monitoring and alerting

Network performance issues are often discovered reactively through user complaints or application timeouts rather than proactive monitoring. Many monitoring setups focus on CPU and memory utilization while overlooking network metrics that can predict performance bottlenecks. Network performance degradation often appears gradually and can be masked by application-level retries or gray failures. By the time users notice problems, the issue may have been developing for days or weeks, making root cause analysis more difficult. Set up Amazon CloudWatch [network performance monitoring alerts](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html).

Use VPC Flow Logs with [Amazon CloudWatch Insights](https://repost.aws/knowledge-center/vpc-flow-logs-and-cloudwatch-logs-insights) to analyze traffic patterns and identify optimization opportunities. Network performance issues often correlate with other infrastructure changes, so maintain good change management practices and baseline your network performance before and after deployments. Consider using AWS X-Ray for distributed tracing to identify network bottlenecks in microservices architectures.

### Relevant Resources

1. [Amazon EC2 Instance Types Guide](https://aws.amazon.com/ec2/instance-types/)
2. [Placement Groups Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)
3. [Enhanced Networking on Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html)
4. [EC2 Nitro networking under the hood](https://youtu.be/_hiNXKQZc0M)

## 15. IP Address Management (IPAM) Basics

IP Address Management (IPAM) has evolved from a simple spreadsheet exercise to a critical foundation of modern AWS architectures. As customers embrace multi-account strategies, hybrid connectivity, and global expansion, the complexity of managing IP address space has grown exponentially. What once seemed like an infinite pool of [RFC 1918](https://www.rfc-editor.org/rfc/rfc1918.html) addresses quickly becomes a constraint when connecting dozens of VPCs across regions, establishing site-to-site VPN connections, and planning for future acquisitions.

The most common anti-pattern is treating IP planning as an afterthought—something to figure out "when we get there." By doing so, customers run the risk of painting themselves into corners with overlapping CIDR blocks, requiring complex re-architecting efforts that could have been avoided with proper planning. The shift toward IPv6 and dual-stack configurations adds another layer of complexity that many teams underestimate.

### Plan Your IP Address Hierarchy Before Your First VPC

Most customers typically start with a single VPC using a typical [RFC 1918](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html#vpc-sizing-ipv4) address space of `172.16.0.0/16` and gradually expand without an overall addressing plan. By the time they have more than 20 VPCs across multiple accounts and regions, they find themselves dealing with overlapping IP ranges and costly re-architecting.

Address conflicts prevent [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html), [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/) attachments, and hybrid connectivity. Customers often spend months re-subnetting production workloads because they cannot connect to an acquired company's network due to overlapping usage of the `10.0.0.0/8` address space.

To prevent these issues, establish a hierarchical IP plan that allocates address space by region, account type, and environment. For example, use the `10.0.0.0/16` range with the second octet designating the region (`10.1.0.0/16` for `us-east-1`, `10.2.0.0/16` for `us-west-2`), the third octet for account type (production, development, shared services), and the fourth octet for availability zones. Reserve large blocks for future expansion—if you think you need a `/20` (which provides 4,096 IP addresses), allocate a `/16` instead.

Consider using [Amazon VPC IP Address Manager (IPAM)](https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html) to automatically enforce your hierarchy. Always try to reserve 25-50% of your allocated space for unexpected growth patterns. However, be mindful of the associated [IPAM costs](https://docs.aws.amazon.com/vpc/latest/ipam/pricing-ipam.html).

### Implement Predictable VPC Sizing Based on Workload Patterns

Customers often default to `/16` VPCs because that's what the default VPCs provide, without considering their actual requirements. This approach leads to either wasted address space in small environments or insufficient space for large-scale deployments.

The proper sizing of VPC CIDRs impacts your ability to scale, influences subnet design, and affects cross-VPC connectivity options. Oversized VPCs waste address space that might be needed elsewhere, while undersized VPCs force complex subnet restructuring exercises later.

It's important to develop VPC sizing templates based on workload types. For microservices platforms expecting hundreds of services, start with a `/16` CIDR block. For simple web applications, a `/20` CIDR block often suffices. Consider subnet design requirements—you'll need at least one subnet per Availability Zone, plus separate subnets for different tiers (web, application, and data).

Use [VPC IPAM's](https://docs.aws.amazon.com/vpc/latest/ipam/create-top-ipam.html) allocation minimum and maximum settings to enforce consistent sizing and monitor actual IP usage with IPAM history. Remember that you can add secondary CIDR blocks to existing VPCs if you plan for it in your addressing hierarchy.

### Design Subnet Architecture for Growth and Operational Requirements

Many customers create subnets on an as-needed basis, resulting in inconsistent sizing and inefficient address utilization. These environments often contain a mixture of `/24`, `/25`, and various other subnet sizes, making troubleshooting and automation challenging.

Inconsistent subnet design complicates network automation, hinders capacity planning, and can cause premature address exhaustion in specific Availability Zones (AZs). It also impairs the implementation of consistent security group and Network Access Control List (NACL) strategies.

To address these issues, establish subnet sizing standards based on function and expected capacity. Use consistent bit boundaries—if your largest subnet requires a `/22`, designate all subnets in that tier as `/22`, even if they currently require less space. Reserve the initial subnets in each VPC for infrastructure components (such as load balancers and NAT gateways), followed by application tiers and databases. Always maintain at least one subnet per AZ for future expansion.

Utilize [AWS Subnet Calculator](https://v2.awssubnetcalculator.com/) tools and plan subnets on bit boundaries that align with your monitoring and automation tools. Consider implementing separate subnets for different workload types, even within the same tier, as this enables more granular network policies and simplifies troubleshooting.

### Establish IPv6 Strategy Early in Your Architecture

Most customers ignore [IPv6](https://aws.amazon.com/vpc/ipv6) until they encounter IPv4 exhaustion or face specific compliance requirements. When they finally need IPv6, they discover that implementing dual-stack configurations requires significant architectural changes. Note that there is no migration path from IPv4-only subnets to IPv6-only subnets. Additionally, Amazon provides a [fixed IPv6 CIDR block size of /56](https://docs.aws.amazon.com/vpc/latest/userguide/create-vpc.html).

IPv6 provides virtually unlimited address space and eliminates the need for Network Address Translation (NAT) in internet-bound traffic, thereby reducing costs and complexity. Delaying IPv6 implementation until it becomes necessary often results in having to re-architect existing applications and infrastructure.

Customers should enable IPv6 in all new VPCs and establish dual-stack configurations as their standard practice. For simplicity, use AWS-provided IPv6 blocks unless specific addressing requirements exist. From the outset, plan your application architecture to be IP version-agnostic by using DNS names instead of IP addresses in configurations.

Take advantage of [IPv6-only subnets](https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-ipv6-only-subnets-and-ec2-instances/) for workloads that don't require IPv4, such as internal microservices or batch processing jobs. This approach can significantly reduce NAT Gateway costs. However, be aware that some AWS services and third-party tools may have [limited IPv6 support](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ipv6-support.html), so maintaining an IPv4 path for compatibility is advisable.

### Implement Automated IP Address Allocation and Tracking

Tracking IP allocations in spreadsheets or basic documentation quickly becomes outdated. This leads to duplicate allocations, unknown address usage, and difficult troubleshooting.

Manual IP tracking doesn't scale and creates operational risks. Without proper visibility into address utilization, you cannot make informed decisions about capacity planning or identify security incidents involving specific IP ranges.
Use VPC IPAM across all accounts and regions to centralize IP address management. Configure [IPAM pools](https://docs.aws.amazon.com/vpc/latest/ipam/planning-examples-ipam.html) that align with your addressing hierarchy and set appropriate allocation rules. Integrate IPAM with your [Infrastructure as Code](https://docs.aws.amazon.com/whitepapers/latest/introduction-devops-aws/infrastructure-as-code.html) pipelines to automate address allocation for new VPCs and subnets.

Monitor CIDR usage by resource along with [IPAM history](https://docs.aws.amazon.com/vpc/latest/ipam/view-history-cidr-ipam.html) to track your CIDR compliance and detect unauthorized address allocations. Set up CloudWatch alarms for address pool utilization thresholds (typically `70%` - `85%`). [Enforce IPAM use](https://docs.aws.amazon.com/vpc/latest/ipam/scp-ipam.html) for VPC creation with [IAM Service Control Policies (SCP)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html).

### Plan Cross-VPC Connectivity Before Address Allocation

Many customers often design VPCs in isolation and discover later that they can't connect them due to overlapping address spaces. This is particularly common when connecting to on-premises networks or acquired company infrastructure.

Address conflicts prevent the use of VPC Peering, AWS Transit Gateway, and hybrid connectivity options. Resolving these conflicts often requires expensive re-subnetting or complex NAT configurations that add latency and operational complexity.

Before allocating address space, map out all potential connectivity requirements. This includes current cross-VPC needs, planned hybrid connections, potential acquisition targets, and customer network requirements. Reserve non-overlapping address blocks for each connectivity domain. Consider using [AWS PrivateLink](https://aws.amazon.com/privatelink/) endpoints to avoid IP connectivity overlap requirements for AWS services.

### Operational Considerations

Managing IP addresses effectively requires ongoing operational attention beyond initial planning. Implement regular audits of your address space utilization using [Custom AWS Config rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_develop-rules.html) with [AWS Lambda](https://aws.amazon.com/lambda/) or VPC IPAM. Monitor not only current usage but also growth trends to predict future needs. Elastic IP addresses (EIPs) continue to incur charges when they are allocated but not associated with resources. To optimize costs and maintain good resource management, customers should implement automated processes to identify and release unused Elastic IPs. This can be accomplished through AWS Lambda functions or scripts that periodically scan for unattached EIPs and either release them or notify administrators. Such automation helps prevent unnecessary expenses and ensures efficient resource management by removing EIPs that no longer serve any purpose in your infrastructure. Additionally, IPv6-only subnets can eliminate NAT Gateway costs for workloads that don't require IPv4 connectivity. Beware of [AWS Config](https://aws.amazon.com/config/pricing/) and [AWS Lambda](https://aws.amazon.com/lambda/pricing/) costs.

Integration with other AWS services significantly impacts your IP strategy. VPC Endpoints reduce the need for NAT Gateway capacity, while AWS Global Accelerator can optimize traffic routing without requiring additional IP space. When implementing container platforms like Amazon EKS, factor in the IP requirements for pod networking, as each pod consumes an IP address from your subnet space. The [AWS VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html) also offers efficient IP address management. This feature helps reduce the number of secondary IP addresses needed per elastic network interface. Consider using AWS VPC CNI prefix delegation to optimize IP utilization in container environments and integrate your IPAM strategy with AWS Organizations SCPs to enforce governance across accounts automatically.

### Relevant Resources

* [Manage your IP addresses at scale on AWS](https://youtu.be/xtLJgJfhPLg)
* [AWS Prescriptive Guidance - IPAM](https://docs.aws.amazon.com/prescriptive-guidance/latest/robust-network-design-control-tower/ipam.html)
* [VPC IPAM Best Practices](https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-vpc-ip-address-manager-best-practices/)
* [Connecting Networks with Overlapping IP Ranges](https://aws.amazon.com/blogs/networking-and-content-delivery/connecting-networks-with-overlapping-ip-ranges/)

## Additional resources to get started?

[skills builder]: https://aws.amazon.com/training/learn-about/advanced-networking/

If you're new to AWS networking, it's important to get a solid foundation
before diving into deployment design. We recommend starting with some basic
AWS networking concepts, which are covered in this section.

For a more structured learning path, check out the official AWS training on
[skills builder].

[AWS Stash]: https://awsstash.com/
[AWS networking foundations]: https://www.youtube.com/watch?v=8nNurTFy-h4
[Networking foundations]: https://www.youtube.com/watch?v=4QoFt8so9hI

Additionally, [AWS Stash] is a great resource for finding a wide variety of
AWS content, including YouTube videos, blogs, and podcasts. You can search
for specific topics, like networking, and find useful resources.

A great place to start is by watching `Networking Fundamentals` sessions from
past AWS re:Invent events. Here are a couple of examples:

* [AWS networking foundations] from re:Invent 2023

* [Networking foundations] from re:Invent 2021

![Image title](../assets/basics/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/basics/Example.drawio)
///
