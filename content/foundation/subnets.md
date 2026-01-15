# Subnets

Subnets are subdivisions of your VPC's IP address range where you launch AWS resources. They provide network segmentation, organize resources by tier and function, and enable high availability through multi-AZ deployment.

``` mermaid
graph TB
    subgraph AWS["AWS Cloud"]
        subgraph VPC["VPC: 10.0.0.0/16 - IPv6: 2001:db8::/56"]
            subgraph AZA["Availability Zone A"]
                PubA["Public Subnet<br/>10.0.0.0/24<br/>2001:db8:0:1::/64<br/>Web Tier"]
                PrivA["Private Subnet<br/>10.0.10.0/24<br/>2001:db8:0:a::/64<br/>App Tier"]
                DataA["Data Subnet<br/>10.0.20.0/24<br/>2001:db8:0:14::/64<br/>Database Tier"]
                PubA ~~~ PrivA ~~~ DataA
            end
            
            subgraph AZB["Availability Zone B"]
                PubB["Public Subnet<br/>10.0.1.0/24<br/>2001:db8:0:2::/64<br/>Web Tier"]
                PrivB["Private Subnet<br/>10.0.11.0/24<br/>2001:db8:0:b::/64<br/>App Tier"]
                DataB["Data Subnet<br/>10.0.21.0/24<br/>2001:db8:0:15::/64<br/>Database Tier"]
            end
            
            subgraph AZC["Availability Zone C"]
                PubC["Public Subnet<br/>10.0.2.0/24<br/>2001:db8:0:3::/64<br/>Web Tier"]
                PrivC["Private Subnet<br/>10.0.12.0/24<br/>2001:db8:0:c::/64<br/>App Tier"]
                DataC["Data Subnet<br/>10.0.22.0/24<br/>2001:db8:0:16::/64<br/>Database Tier"]
            end
        end
    end
    
    style AWS fill:none,stroke:#232f3e,stroke-width:2px,stroke-dasharray:5 5,color:#232f3e
    style VPC fill:#2563eb,stroke:#1e40af,stroke-width:3px,color:#fff
    style AZA fill:#f3f4f6,stroke:#9ca3af,stroke-width:2px,color:#000
    style AZB fill:#f3f4f6,stroke:#9ca3af,stroke-width:2px,color:#000
    style AZC fill:#f3f4f6,stroke:#9ca3af,stroke-width:2px,color:#000
    style PubA fill:#dcfce7,stroke:#16a34a,color:#000
    style PubB fill:#dcfce7,stroke:#16a34a,color:#000
    style PubC fill:#dcfce7,stroke:#16a34a,color:#000
    style PrivA fill:#fef3c7,stroke:#f59e0b,color:#000
    style PrivB fill:#fef3c7,stroke:#f59e0b,color:#000
    style PrivC fill:#fef3c7,stroke:#f59e0b,color:#000
    style DataA fill:#fecaca,stroke:#dc2626,color:#000
    style DataB fill:#fecaca,stroke:#dc2626,color:#000
    style DataC fill:#fecaca,stroke:#dc2626,color:#000
```

## What is a Subnet?

A subnet is a range of IP addresses within your VPC. Each subnet:

- Resides entirely within a single Availability Zone
- Has its own CIDR block (subset of the VPC CIDR)
- Contains resources like EC2 instances, RDS databases, and Lambda functions
- Has associated route tables and network ACLs

[Learn more about subnets](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

## Subnet Characteristics

### Single Availability Zone

Each subnet exists in exactly one AZ. To achieve high availability, create subnets in multiple AZs.

**Example**:
- Subnet A: `10.0.1.0/24` in us-east-1a
- Subnet B: `10.0.2.0/24` in us-east-1b
- Subnet C: `10.0.3.0/24` in us-east-1c

### Reserved IP Addresses

AWS reserves 5 IP addresses in every subnet:

- **First address** (10.0.0.0): Network address
- **Second address** (10.0.0.1): VPC router
- **Third address** (10.0.0.2): DNS server
- **Fourth address** (10.0.0.3): Reserved for future use
- **Last address** (10.0.0.255): Network broadcast address

**Example**: A `/24` subnet (256 addresses) has only 251 usable IP addresses.

### Subnet Sizing

Choose subnet sizes based on the number of resources you'll deploy:

| CIDR | Total IPs | Usable IPs | Typical Use |
|------|-----------|------------|-------------|
| /28  | 16        | 11         | Small, specific services |
| /26  | 64        | 59         | Small workloads |
| /24  | 256       | 251        | Standard subnet size |
| /22  | 1,024     | 1,019      | Large workloads |
| /20  | 4,096     | 4,091      | Very large workloads |

**Best Practice**: Start with `/24` subnets unless you have specific requirements for larger or smaller sizes.

## Subnet Design Patterns

### Multi-Tier Architecture

Organize subnets by application tier:

**Public Tier** (Internet-facing):
- Load balancers
- Bastion hosts
- NAT gateways

**Private Tier** (Application):
- Application servers
- Container workloads
- Internal services

**Data Tier** (Databases):
- RDS databases
- ElastiCache clusters
- Redshift clusters

### Multi-AZ Deployment

Create subnet sets across multiple AZs for high availability:

```
VPC: 10.0.0.0/16

AZ-A (us-east-1a):
  - Public:  10.0.0.0/24
  - Private: 10.0.10.0/24
  - Data:    10.0.20.0/24

AZ-B (us-east-1b):
  - Public:  10.0.1.0/24
  - Private: 10.0.11.0/24
  - Data:    10.0.21.0/24

AZ-C (us-east-1c):
  - Public:  10.0.2.0/24
  - Private: 10.0.12.0/24
  - Data:    10.0.22.0/24
```

## Public vs. Private Subnets

The distinction between "public" and "private" subnets is determined by routing configuration, not an inherent property of the subnet itself.

**Public Subnet**:
- Route table includes a route to an Internet Gateway
- Resources can have public IP addresses
- Can communicate directly with the internet

**Private Subnet**:
- No direct route to an Internet Gateway
- Resources use private IP addresses only
- Internet access via NAT Gateway (if needed)

**Note**: Routing and internet connectivity are covered in the Connectivity section.

## Subnet Best Practices

1. **Plan for multiple AZs**: Create subnets in at least 2 AZs for high availability
2. **Use consistent sizing**: Standardize on `/24` subnets unless you have specific needs
3. **Organize by tier**: Group subnets by function (public, private, data)
4. **Leave room for growth**: Don't allocate all VPC address space immediately
5. **Use descriptive names**: Tag subnets clearly (e.g., "prod-web-public-us-east-1a")
6. **Document your design**: Maintain an IP address management spreadsheet or use AWS IPAM

## Subnet Limits

- Default limit: 200 subnets per VPC (can be increased)
- Subnet CIDR block size: `/28` to `/16`
- Cannot modify subnet CIDR block after creation (must delete and recreate)

## AWS Documentation

- [Subnets for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)
- [Subnet sizing](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html#subnet-sizing)
- [VPC and subnet basics](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-subnets-commands-example.html)
- [Subnet CIDR reservations](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html)

## Additional Resources

- [VPC sharing: A new approach to multiple accounts](https://aws.amazon.com/blogs/networking-and-content-delivery/vpc-sharing-a-new-approach-to-multiple-accounts-and-vpc-management/) - Blog post on shared subnets across accounts
