# Network to Network

## AWS Direct Connect

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

**SD-WAN**

SD-WAN connectivity to AWS represents a hybrid connectivity approach that enables organizations to extend their SD-WAN overlay networks from on-premises headquarters and branch offices directly to AWS cloud resources. This solution allows remote sites to leverage the intelligent routing, policy enforcement, and performance optimization capabilities of SD-WAN when accessing AWS workloads and services, providing a consistent network experience across the hybrid infrastructure while maintaining centralized control and visibility over all traffic flows between distributed locations and the cloud.

Benefits:

• **Intelligent Routing**: Automatically selects the best path for AWS traffic based on application needs and network conditions
• **Cost Optimization**: Reduces expensive MPLS dependency by using multiple transport types (broadband, LTE, MPLS)
• **Centralized Management**: Single console to manage policies and connectivity across all sites and AWS
• **Enhanced Performance**: Application-aware traffic steering and WAN optimization for cloud applications
• **Built-in Security**: Encrypted tunnels and integrated security policies across the entire network
• **Simplified Deployment**: Zero-touch provisioning for new sites with automatic AWS connectivity

Common Use Cases:

• Multi-branch connectivity to AWS with optimized routing and consistent policies
• Direct cloud access from branch offices without back-hauling through headquarters
• Hybrid application deployment with seamless connectivity between on-premises and AWS workloads
• Retail and distributed organizations requiring reliable AWS access from hundreds of locations
• Backup connectivity for AWS Direct Connect with automatic failover capabilities

![Image title](../assets/hybrid-connectivity/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/hybrid-connectivity/Example.drawio)
///
