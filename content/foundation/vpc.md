# Amazon VPC

Amazon Virtual Private Cloud (VPC) is your logically isolated network within AWS. It provides complete control over your virtual networking environment, including IP address ranges, subnets, route tables, and network gateways.

``` mermaid
graph TB
    subgraph AWS["AWS Region: us-east-1"]
        subgraph VPC["VPC: 10.0.0.0/16 - IPv6: 2001:db8::/56"]
            subgraph AZ1["Availability Zone A"]
                Subnet1["Subnet: 10.0.1.0/24<br/>IPv6: 2001:db8:0:1::/64"]
            end
            subgraph AZ2["Availability Zone B"]
                Subnet2["Subnet: 10.0.2.0/24<br/>IPv6: 2001:db8:0:2::/64"]
            end
            subgraph AZ3["Availability Zone C"]
                Subnet3["Subnet: 10.0.3.0/24<br/>IPv6: 2001:db8:0:3::/64"]
            end
        end
    end
    
    Subnet1 ~~~ Subnet2 ~~~ Subnet3
    
    style AWS fill:none,stroke:#ff9900,stroke-width:2px,stroke-dasharray:5 5,color:#ff9900
    style VPC fill:#2563eb,stroke:#1e40af,stroke-width:3px,color:#fff
    style AZ1 fill:#dbeafe,stroke:#3b82f6,color:#000
    style AZ2 fill:#dbeafe,stroke:#3b82f6,color:#000
    style AZ3 fill:#dbeafe,stroke:#3b82f6,color:#000
    style Subnet1 fill:#fef3c7,stroke:#f59e0b,color:#000
    style Subnet2 fill:#fef3c7,stroke:#f59e0b,color:#000
    style Subnet3 fill:#fef3c7,stroke:#f59e0b,color:#000
```

## What is a VPC?

A VPC is a virtual network dedicated to your AWS account. It is logically isolated from other virtual networks in the AWS Cloud, providing a secure foundation for your AWS resources.

**Key characteristics**:

- Spans all Availability Zones in a Region
- Defined by an IPv4 CIDR block (and optionally IPv6)
- Contains subnets, route tables, and network gateways
- Provides network isolation and security boundaries

## VPC Components

### Primary CIDR Block

Every VPC requires a primary IPv4 CIDR block between `/16` (65,536 addresses) and `/28` (16 addresses). This defines the total IP address space available within your VPC.

### Secondary CIDR Blocks

You can add up to 4 secondary CIDR blocks to expand your VPC's address space. Useful when:

- Initial CIDR block is exhausted
- You need non-contiguous address ranges
- Migrating workloads with existing IP schemes

[Learn more about VPC CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html)

### IPv6 Support

VPCs can be dual-stack (IPv4 and IPv6). AWS assigns a `/56` IPv6 CIDR block from Amazon's pool of IPv6 addresses.

## Default vs. Custom VPCs

**Default VPC**:

- Created automatically in each Region
- Pre-configured with subnets, internet gateway, and route table
- Suitable for getting started quickly
- CIDR block: `172.31.0.0/16`

**Custom VPC**:

- You define all configuration
- Recommended for production workloads
- Provides complete control over network design

**Best Practice**: Use custom VPCs for production environments to maintain full control over network architecture.

## VPC Limits and Quotas

- Default limit: 5 VPCs per Region (can be increased)
- Maximum CIDR blocks per VPC: 5 (1 primary + 4 secondary)
- VPC CIDR block size: `/16` to `/28` for IPv4

[View all VPC quotas](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html)

## Planning Your VPC

Before creating a VPC, consider:

1. **IP address range**: Choose a CIDR block that won't overlap with other networks
2. **Region selection**: VPCs are Region-specific; plan for multi-region if needed
3. **Subnet strategy**: How will you divide the address space across AZs and tiers?
4. **Connectivity requirements**: Will this VPC connect to other VPCs, on-premises networks, or the internet?
5. **Growth**: Size your CIDR block to accommodate future expansion

## AWS Documentation

- [What is Amazon VPC?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [VPC CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html)
- [Configure your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html)
- [Default VPC and default subnets](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html)
- [Extend your VPC resources](https://docs.aws.amazon.com/vpc/latest/userguide/extend-intro.html)
- [Migrate to IPv6](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-migrate-ipv6.html)

## Additional Resources

- [Designing hyperscale Amazon VPC networks](https://aws.amazon.com/blogs/networking-and-content-delivery/designing-hyperscale-amazon-vpc-networks/) - Blog post on large-scale VPC design
- [VPC sharing: A new approach to multiple accounts](https://aws.amazon.com/blogs/networking-and-content-delivery/vpc-sharing-a-new-approach-to-multiple-accounts-and-vpc-management/) - Blog post on shared VPCs
