# Network to Network

* AWS Direct Connect
AWS Direct Connect is a dedicated network connectivity service that establishes a private, high-bandwidth link between your on-premises infrastructure and AWS Cloud, bypassing the public internet. AWS Direct Connect provides a foundation for reliable, secure, and high-performance hybrid cloud architectures, making it an essential service for organizations requiring consistent network performance for latency-sensitive applications and high-performance hybrid connectivity from on-premises to AWS Cloud.

Benefits:

* Security: Traffic doesn't traverse the public internet
* Reliability: up to 99.99% SLA available with redundant connections
* Lower Latency: Consistent network performance for latency-sensitive applications
* Scalability: Easily increase bandwidth as needed
* Cost Efficiency: Reduced data transfer costs for high-volume workloads

Common Use Cases:

* Enterprise hybrid cloud deployments
* Large-scale data migration to AWS
* Real-time data replication and backup
* Media content distribution
* High-performance computing and big data analytics

* AWS Site-to-Site VPN

AWS Site-to-Site VPN provides a secure and accessible way to extend your on-premises network to AWS cloud, making it an essential service for organizations implementing hybrid cloud architectures. It allows customers to create an encrypted connection between your on-premises networks and your AWS Virtual Private Cloud (VPC), allowing secure communication over the internet.

Benefits:

* Cost-Effective: No dedicated hardware required, pay-as-you-go pricing
* Quick Setup: Can be established in minutes through the AWS console
* Secure: Encrypted traffic using IPsec protocols
* Flexible: Works with most standard VPN equipment and software
* Scalable: Can handle growing bandwidth needs with accelerated VPN and multiple VPN connection configurations

Common Use Cases:

* Connecting on-premises data centers to AWS Cloud
* Establishing secure connections for remote/branch offices and sites
* Creating backup connectivity for AWS Direct Connect
* Building hybrid cloud environments
* Enabling secure remote access for employees from Head or Branch offices and remote sites

* SD-WAN

SD-WAN connectivity to AWS represents a hybrid connectivity approach that enables organizations to extend their SD-WAN overlay networks from on-premises headquarters and branch offices directly to AWS cloud resources. This solution allows remote sites to leverage the intelligent routing, policy enforcement, and performance optimization capabilities of SD-WAN when accessing AWS workloads and services, providing a consistent network experience across the hybrid infrastructure while maintaining centralized control and visibility over all traffic flows between distributed locations and the cloud.

Benefits:

• **Application-Aware Routing**: Intelligently steers traffic based on application requirements and real-time network performance
• **Dynamic Path Selection**: Automatically chooses optimal connections (broadband, MPLS, LTE) based on cost, performance, and availability
• **Centralized Policy Management**: Unified control plane for managing security, QoS, and routing policies across hybrid infrastructure
• **Zero-Touch Provisioning**: Simplified deployment of new sites with automatic configuration and cloud connectivity
• **Enhanced Security**: Built-in encryption, segmentation, and threat protection across all network connections
• **Cost Reduction**: Reduces dependency on expensive MPLS circuits by leveraging multiple transport options

Common Use Cases:

• **Branch office modernization** with direct cloud access and reduced backhauling through data centers
• **Multi-cloud connectivity** enabling seamless access to AWS and other cloud providers from any location
• **Application migration** with maintained performance and security during cloud transformation
• **Retail and distributed enterprises** requiring consistent connectivity and policies across hundreds of locations
• **Remote workforce enablement** with optimized access to cloud applications and resources
• **Disaster recovery** with intelligent failover between on-premises and cloud-based resources

![Image title](../assets/hybrid-connectivity/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/hybrid-connectivity/Example.drawio)
///
