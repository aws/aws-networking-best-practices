# IP Address Planning with CIDR Blocks

!!! tip "Automate with IPAM"
    For multi-account environments, [AWS IPAM](ipam.md) automates the CIDR planning principles described on this page. IPAM prevents overlaps, enforces allocation policies, and provides centralized visibility across your organization.

Proper IP address planning using CIDR (Classless Inter-Domain Routing) notation is critical for building scalable, interconnected AWS network architectures.

``` mermaid
graph TB
    Root["10.0.0.0/8<br/>Entire Organization<br/>16,777,216 addresses"]
    
    Root --> Prod["10.0.0.0/12<br/>Production<br/>1,048,576 addresses"]
    Root --> NonProd["10.16.0.0/12<br/>Non-Production<br/>1,048,576 addresses"]
    
    Prod --> ProdEast["10.0.0.0/16<br/>us-east-1 Production<br/>65,536 addresses"]
    Prod --> ProdWest["10.1.0.0/16<br/>us-west-2 Production<br/>65,536 addresses"]
    Prod --> ProdEU["10.2.0.0/16<br/>eu-west-1 Production<br/>65,536 addresses"]
    
    NonProd --> DevEast["10.16.0.0/16<br/>us-east-1 Development<br/>65,536 addresses"]
    NonProd --> TestEast["10.17.0.0/16<br/>us-east-1 Testing<br/>65,536 addresses"]
    
    ProdEast --> Subnet1["10.0.0.0/24<br/>Public Subnet AZ-A<br/>256 addresses"]
    ProdEast --> Subnet2["10.0.1.0/24<br/>Public Subnet AZ-B<br/>256 addresses"]
    ProdEast --> Subnet3["10.0.10.0/24<br/>Private Subnet AZ-A<br/>256 addresses"]
    
    style Root fill:#2563eb,stroke:#1e40af,color:#fff
    style Prod fill:#7c3aed,stroke:#6d28d9,color:#fff
    style NonProd fill:#ea580c,stroke:#c2410c,color:#fff
    style ProdEast fill:#059669,stroke:#047857,color:#fff
    style ProdWest fill:#059669,stroke:#047857,color:#fff
    style ProdEU fill:#059669,stroke:#047857,color:#fff
    style DevEast fill:#f59e0b,stroke:#d97706,color:#fff
    style TestEast fill:#f59e0b,stroke:#d97706,color:#fff
    style Subnet1 fill:#dbeafe,stroke:#3b82f6,color:#000
    style Subnet2 fill:#dbeafe,stroke:#3b82f6,color:#000
    style Subnet3 fill:#dbeafe,stroke:#3b82f6,color:#000
```

## Understanding CIDR Notation

CIDR notation represents IP address ranges using the format: `IP_ADDRESS/PREFIX_LENGTH`

**Example**: `10.0.0.0/16`

- **IP Address**: `10.0.0.0` (network address)
- **Prefix Length**: `/16` (number of fixed bits in the network portion)
- **Address Range**: `10.0.0.0` to `10.0.255.255` (65,536 addresses)

### Common CIDR Block Sizes

| CIDR | Addresses | Typical Use |
|------|-----------|-------------|
| /16  | 65,536    | Large VPC, enterprise environments |
| /20  | 4,096     | Medium VPC, departmental networks |
| /24  | 256       | Standard subnet, small workloads |
| /28  | 16        | Minimal subnet, specific services |

[Learn more about VPC CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html)

## RFC 1918 Private Address Ranges

Use these private IP ranges for your VPCs:

- **10.0.0.0/8**: 10.0.0.0 - 10.255.255.255 (16,777,216 addresses)
- **172.16.0.0/12**: 172.16.0.0 - 172.31.255.255 (1,048,576 addresses)
- **192.168.0.0/16**: 192.168.0.0 - 192.168.255.255 (65,536 addresses)

**Best Practice**: Use the 10.0.0.0/8 range for large organizations to maximize available address space.

## VPC CIDR Planning Principles

### 1. Avoid Overlapping CIDR Blocks

VPCs with overlapping CIDR blocks cannot be connected via VPC Peering, Transit Gateway, or VPN.

**Example of overlap** (BAD):
- VPC A: `10.0.0.0/16`
- VPC B: `10.0.0.0/24` ← Overlaps with VPC A

**Non-overlapping** (GOOD):
- VPC A: `10.0.0.0/16`
- VPC B: `10.1.0.0/16`
- VPC C: `10.2.0.0/16`

### 2. Plan for Growth

Choose CIDR blocks large enough to accommodate future expansion:

- Start with `/16` for production VPCs unless you have specific constraints
- Reserve address space for future VPCs and accounts
- Consider secondary CIDR blocks if you need to expand later

### 3. Align with Organizational Structure

Create a hierarchical IP addressing scheme:

**Example**:
- **10.0.0.0/12**: Production (10.0.0.0 - 10.15.255.255)
  - 10.0.0.0/16: us-east-1 production
  - 10.1.0.0/16: us-west-2 production
  - 10.2.0.0/16: eu-west-1 production
- **10.16.0.0/12**: Non-Production (10.16.0.0 - 10.31.255.255)
  - 10.16.0.0/16: us-east-1 development
  - 10.17.0.0/16: us-east-1 testing

### 4. Consider Hybrid Connectivity

If connecting to on-premises networks:

- Document existing on-premises IP ranges
- Ensure AWS CIDR blocks don't overlap with on-premises networks
- Reserve address space for future on-premises expansion
- Coordinate with network teams before creating VPCs

## Subnet CIDR Planning

Within a VPC, divide the address space into subnets:

**Example VPC**: `10.0.0.0/16`

- **10.0.0.0/24**: Public subnet AZ-A (256 addresses)
- **10.0.1.0/24**: Public subnet AZ-B
- **10.0.2.0/24**: Public subnet AZ-C
- **10.0.10.0/24**: Private subnet AZ-A
- **10.0.11.0/24**: Private subnet AZ-B
- **10.0.12.0/24**: Private subnet AZ-C
- **10.0.20.0/24**: Database subnet AZ-A
- **10.0.21.0/24**: Database subnet AZ-B
- **10.0.22.0/24**: Database subnet AZ-C

**Note**: AWS reserves 5 IP addresses in each subnet (first 4 and last 1).

## Tools and Resources

- **CIDR Calculator**: Use online tools to calculate address ranges and subnet divisions
- **AWS VPC Console**: Provides CIDR validation when creating VPCs
- **AWS IPAM**: Automates CIDR allocation and prevents overlaps (see IPAM section)

## AWS Documentation

- [VPC CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html)
- [Subnet CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html#subnet-sizing)
- [RFC 1918 - Address Allocation for Private Internets](https://datatracker.ietf.org/doc/html/rfc1918)
- [Subnet CIDR reservations](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html)

## Additional Resources

- [Building Scalable and Secure Multi-VPC Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html) - Whitepaper on IP address planning at scale
- [Designing hyperscale Amazon VPC networks](https://aws.amazon.com/blogs/networking-and-content-delivery/designing-hyperscale-amazon-vpc-networks/) - Blog post on large-scale CIDR planning
