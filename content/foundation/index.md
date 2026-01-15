# Foundation

This section covers the fundamental building blocks of AWS networking. Understanding these core concepts is essential before implementing connectivity, application networking, security, or observability solutions.

Fundamental concepts for AWS networking. This section covers core VPC concepts, IP addressing, and organizational structure that form the building blocks for all AWS network architectures.

## 1. AWS Organizations and Account Structure

**AWS Organizations** enables you to centrally manage and govern multiple AWS accounts. For networking, this is critical for establishing a structured approach to network architecture across your organization.

**Key Concepts:**

*   **Organizational Units (OUs):** Logical groupings of accounts (e.g., Production, Development, Shared Services)
*   **Service Control Policies (SCPs):** Enforce governance and compliance across accounts
*   **Centralized Networking Account:** Dedicated account for managing shared networking resources like Transit Gateway and Direct Connect

***Best Practice:*** *Establish a dedicated networking account early to centralize connectivity and simplify management as you scale.*

## 2. The Isolated Foundation: Amazon VPC

**Amazon Virtual Private Cloud (VPC)** is your own private, secure network space within AWS. It is logically isolated from all other networks in the AWS cloud.

**What you control:** You define the IP address range (CIDR block) and configure all elements inside it, including subnets, route tables, and network gateways.

***Analogy:*** *Think of your VPC as your private, high-security building within the vast AWS campus.*

## 3. Regions and Availability Zones

**AWS Regions** are separate geographic areas (e.g., us-east-1, eu-west-1). Each Region contains multiple **Availability Zones (AZs)**, which are isolated data centers with independent power, cooling, and networking.

**Why it matters:** Distributing resources across AZs protects your applications from data center failures and provides high availability.

**Planning consideration:** Every subnet must reside entirely within a single AZ, so plan your subnet strategy with AZ distribution in mind.

## 4. IP Address Planning with CIDR Blocks

**CIDR (Classless Inter-Domain Routing)** notation defines IP address ranges for your VPC and subnets.

**Common ranges:**

*   VPC: `/16` (65,536 addresses) for large environments, `/20` (4,096 addresses) for smaller workloads
*   Subnets: `/24` (256 addresses) is common, but size based on actual needs

**Critical planning rule:** VPCs cannot have overlapping CIDR blocks if you plan to connect them. Plan your IP address hierarchy before creating your first VPC.

***Example:*** *Use `10.0.0.0/16` for us-east-1 production, `10.1.0.0/16` for us-west-2 production, ensuring no overlap.*

## 5. Subnets: Segmentation Within Your VPC

A **Subnet** is a subdivision of your VPC's IP address range where you launch resources like EC2 instances.

**Key characteristics:**

*   Each subnet exists in exactly one Availability Zone
*   Subnets enable you to organize resources by tier (web, application, database) and access requirements
*   AWS reserves 5 IP addresses in each subnet for internal use

**Public vs. Private subnets:** This distinction is determined by routing configuration (covered in the Connectivity section), not by the subnet itself.

## 6. IP Address Management (IPAM)

**AWS IPAM** helps you plan, track, and monitor IP addresses across your AWS organization.

**Use IPAM to:**

*   Automatically allocate non-overlapping CIDR blocks
*   Track IP address utilization across accounts and regions
*   Enforce IP address allocation policies
*   Maintain compliance with your addressing standards

***Best Practice:*** *Implement IPAM early, especially in multi-account environments, to prevent addressing conflicts as you scale.*

---

## Explore Foundation Topics

<div class="grid cards" markdown>

-   :material-book-open-outline: **Before You Start**

    ---

    Essential AWS knowledge for networking

    [:octicons-arrow-right-24: Learn more](aws-prerequisites.md)

-   :material-office-building-outline: **AWS Organizations**

    ---

    Centralized management and governance for multi-account networking

    [:octicons-arrow-right-24: Learn more](organizations.md)

-   :material-cloud-outline: **Amazon VPC**

    ---

    Your isolated virtual network within AWS

    [:octicons-arrow-right-24: Learn more](vpc.md)

-   :material-earth: **Regions and Availability Zones**

    ---

    Geographic distribution and fault isolation

    [:octicons-arrow-right-24: Learn more](regions-azs.md)

-   :material-ip-network: **CIDR Planning**

    ---

    IP address planning for scalable architectures

    [:octicons-arrow-right-24: Learn more](cidr.md)

-   :material-network: **Subnets**

    ---

    Network segmentation within your VPC

    [:octicons-arrow-right-24: Learn more](subnets.md)

-   :material-ip: **IPAM**

    ---

    Centralized IP address management at scale

    [:octicons-arrow-right-24: Learn more](ipam.md)

</div>
