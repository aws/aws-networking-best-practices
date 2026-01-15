# IP Address Management (IPAM)

!!! info "Related Topic: CIDR Planning"
    IPAM automates the IP address planning principles covered in [CIDR Planning](cidr.md). Review CIDR planning concepts first to understand the addressing strategies that IPAM helps you implement and enforce at scale.

AWS IPAM (IP Address Management) helps you plan, track, and monitor IP addresses across your AWS organization, preventing overlaps and simplifying address allocation at scale.

``` mermaid
graph TB
    IPAM["AWS IPAM<br/>Centralized IP Management"]
    
    IPAM --> TopPool["Top-Level Pool<br/>10.0.0.0/8<br/>Private Scope"]
    
    TopPool --> RegionEast["Regional Pool<br/>10.0.0.0/12<br/>us-east-1"]
    TopPool --> RegionWest["Regional Pool<br/>10.16.0.0/12<br/>us-west-2"]
    TopPool --> RegionEU["Regional Pool<br/>10.32.0.0/12<br/>eu-west-1"]
    
    RegionEast --> ProdEast["Production Pool<br/>10.0.0.0/13<br/>us-east-1"]
    RegionEast --> NonProdEast["Non-Production Pool<br/>10.8.0.0/13<br/>us-east-1"]
    
    ProdEast --> VPC1["VPC: 10.0.0.0/16<br/>Account: prod-app-1<br/>Auto-allocated"]
    ProdEast --> VPC2["VPC: 10.1.0.0/16<br/>Account: prod-app-2<br/>Auto-allocated"]
    
    NonProdEast --> VPC3["VPC: 10.8.0.0/16<br/>Account: dev-app-1<br/>Auto-allocated"]
    NonProdEast --> VPC4["VPC: 10.9.0.0/16<br/>Account: test-app-1<br/>Auto-allocated"]
    
    style IPAM fill:#2563eb,stroke:#1e40af,color:#fff
    style TopPool fill:#7c3aed,stroke:#6d28d9,color:#fff
    style RegionEast fill:#059669,stroke:#047857,color:#fff
    style RegionWest fill:#059669,stroke:#047857,color:#fff
    style RegionEU fill:#059669,stroke:#047857,color:#fff
    style ProdEast fill:#f59e0b,stroke:#d97706,color:#fff
    style NonProdEast fill:#ea580c,stroke:#c2410c,color:#fff
    style VPC1 fill:#dbeafe,stroke:#3b82f6,color:#000
    style VPC2 fill:#dbeafe,stroke:#3b82f6,color:#000
    style VPC3 fill:#fef3c7,stroke:#f59e0b,color:#000
    style VPC4 fill:#fef3c7,stroke:#f59e0b,color:#000
```

## What is AWS IPAM?

AWS IPAM is a service that makes it easier to manage IP addresses across multiple AWS accounts and Regions. It provides centralized IP address planning, automated allocation, and continuous monitoring.

**Key benefits**:

- Automated CIDR allocation prevents overlapping address spaces
- Centralized visibility across all accounts and Regions
- Policy-based IP address assignment
- Historical tracking and compliance reporting
- Integration with AWS Organizations

[Learn more about AWS IPAM](https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html)

## Core IPAM Concepts

### IPAM Pools

IPAM pools are collections of CIDR blocks that you can allocate to VPCs. Pools can be organized hierarchically:

**Top-level pool**: Your entire private IP address space (e.g., `10.0.0.0/8`)

**Regional pools**: Subdivisions for specific Regions
- us-east-1 pool: `10.0.0.0/12`
- us-west-2 pool: `10.16.0.0/12`
- eu-west-1 pool: `10.32.0.0/12`

**Environment pools**: Further subdivisions by environment
- Production: `10.0.0.0/13`
- Non-production: `10.8.0.0/13`

### Allocation Rules

Define policies that control how CIDR blocks are allocated:

- Minimum and maximum CIDR block sizes
- Allowed CIDR ranges
- Required tags
- Locale restrictions (Region, AZ)

### Scopes

IPAM operates at two scopes:

- **Private scope**: For RFC 1918 private IP addresses
- **Public scope**: For public IPv4 addresses (requires BYOIP)

## How IPAM Works

1. **Create an IPAM**: Set up IPAM in your networking account
2. **Define pools**: Create a hierarchy of IP address pools
3. **Set allocation rules**: Define policies for CIDR allocation
4. **Share pools**: Use AWS RAM to share pools with other accounts
5. **Allocate CIDRs**: Accounts request CIDR blocks from shared pools
6. **Monitor usage**: Track IP address utilization and compliance

[Learn how IPAM works](https://docs.aws.amazon.com/vpc/latest/ipam/how-ipam-works.html)

## Use Cases

### Multi-Account Organizations

IPAM is essential for organizations with multiple AWS accounts:

- Centralized IP address planning across all accounts
- Automated allocation prevents manual coordination
- Consistent addressing scheme across the organization
- Visibility into IP usage across accounts

### Preventing CIDR Overlaps

IPAM automatically prevents overlapping CIDR allocations:

- Validates new VPC CIDR blocks against existing allocations
- Blocks creation of VPCs with overlapping addresses
- Ensures all VPCs can be interconnected if needed

### Compliance and Auditing

Track IP address usage for compliance:

- Historical records of all CIDR allocations
- Identify unused or underutilized address space
- Generate reports for auditing purposes
- Monitor adherence to IP addressing policies

### Hybrid Cloud Integration

Coordinate IP addressing between AWS and on-premises:

- Import on-premises CIDR blocks into IPAM
- Ensure AWS allocations don't overlap with on-premises networks
- Maintain a single source of truth for all IP addresses

## Getting Started with IPAM

### Prerequisites

- AWS Organizations enabled
- Delegated administrator account for IPAM (typically your networking account)
- Planned IP address hierarchy

### Basic Setup

1. Create an IPAM in your networking account
2. Create a top-level pool with your entire address space
3. Create regional or environment-specific sub-pools
4. Define allocation rules for each pool
5. Share pools with other accounts using AWS RAM
6. Begin allocating VPC CIDR blocks from pools

[Create an IPAM tutorial](https://docs.aws.amazon.com/vpc/latest/ipam/create-ipam.html)

## IPAM Best Practices

1. **Implement early**: Set up IPAM before creating many VPCs
2. **Use hierarchical pools**: Organize pools by Region, environment, or business unit
3. **Define allocation rules**: Enforce consistent CIDR sizing and tagging
4. **Share pools strategically**: Use AWS RAM to share pools with appropriate accounts
5. **Monitor regularly**: Review IPAM dashboards to track utilization
6. **Document your hierarchy**: Maintain clear documentation of your pool structure

## IPAM Pricing

IPAM charges are based on:

- Active IPAM instances
- Number of CIDR blocks monitored
- API calls

[View IPAM pricing](https://aws.amazon.com/vpc/pricing/)

## AWS Documentation

- [What is IPAM?](https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html)
- [How IPAM works](https://docs.aws.amazon.com/vpc/latest/ipam/how-ipam-works.html)
- [Create an IPAM](https://docs.aws.amazon.com/vpc/latest/ipam/create-ipam.html)
- [IPAM tutorials](https://docs.aws.amazon.com/vpc/latest/ipam/ipam-tutorials.html)
- [IPAM with AWS Organizations](https://docs.aws.amazon.com/vpc/latest/ipam/choose-single-user-or-orgs-ipam.html)
- [Bring your own IP addresses (BYOIP) with IPAM](https://docs.aws.amazon.com/vpc/latest/ipam/tutorials-byoip-ipam.html)

## Additional Resources

- [Network address management and auditing at scale with Amazon VPC IPAM](https://aws.amazon.com/blogs/aws/network-address-management-and-auditing-at-scale-with-amazon-vpc-ip-address-manager/) - AWS blog post announcing IPAM
