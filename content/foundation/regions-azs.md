# Regions and Availability Zones

AWS infrastructure is organized into Regions and Availability Zones (AZs), providing geographic distribution, fault isolation, and low-latency connectivity for your applications.

``` mermaid
graph LR
    subgraph AWS["AWS Cloud"]
        subgraph Region["AWS Region: us-west-2"]
            AZ1["Availability Zone A<br/>us-west-2a<br/><br/>Subnet: 10.0.1.0/24"]
            AZ2["Availability Zone B<br/>us-west-2b<br/><br/>Subnet: 10.0.2.0/24"]
            AZ3["Availability Zone C<br/>us-west-2c<br/><br/>Subnet: 10.0.3.0/24"]
        end
    end
    
    AZ1 <-."Low-latency<br/>private network".-> AZ2
    AZ2 <-."Low-latency<br/>private network".-> AZ3
    AZ1 <-."Low-latency<br/>private network".-> AZ3
    
    style AWS fill:none,stroke:#ff9900,stroke-width:2px,stroke-dasharray:5 5,color:#ff9900
    style Region fill:none,stroke:#64748b,stroke-width:2px,stroke-dasharray:5 5,color:#64748b,font-size:16px
    style AZ1 fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#000,font-size:14px
    style AZ2 fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#000,font-size:14px
    style AZ3 fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#000,font-size:14px
```

## AWS Regions

An AWS Region is a physical location around the world where AWS clusters data centers. Each Region is completely independent and isolated from other Regions.

**Key characteristics**:

- Geographically separated (e.g., us-east-1, eu-west-1, ap-southeast-1)
- Fully independent infrastructure
- Data does not leave a Region unless you explicitly transfer it
- Each Region has multiple Availability Zones

**Choosing a Region**:

- **Latency**: Select Regions close to your users
- **Compliance**: Data residency and regulatory requirements
- **Service availability**: Not all AWS services are available in all Regions
- **Cost**: Pricing varies by Region

[View all AWS Regions](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/)

## Availability Zones (AZs)

An Availability Zone is one or more discrete data centers with redundant power, networking, and connectivity within a Region. Each Region has a minimum of 3 AZs.

**Key characteristics**:

- Physically separated within a Region (different buildings, flood plains, power grids)
- Connected via low-latency, high-throughput private fiber networks
- Isolated from failures in other AZs
- Identified by Region code + letter (e.g., us-east-1a, us-east-1b)

**Important**: AZ identifiers (like us-east-1a) are mapped to physical zones differently for each AWS account. Use AZ IDs (like use1-az1) for consistent identification across accounts.

## Network Implications

### Subnets and AZs

- Each subnet must reside entirely within a single AZ
- Resources in a subnet are deployed to that AZ
- Distribute subnets across multiple AZs for high availability

### Cross-AZ Traffic

- Traffic between AZs in the same Region incurs data transfer charges
- Cross-AZ traffic uses AWS private network (low latency, high bandwidth)
- Design applications to minimize unnecessary cross-AZ traffic

### High Availability Design

Deploy resources across multiple AZs to protect against:

- Data center failures
- Power outages
- Network disruptions
- Planned maintenance events

**Best Practice**: Always deploy production workloads across at least 2 AZs, preferably 3.

## Local Zones and Wavelength Zones

**AWS Local Zones**: Extensions of Regions that place compute, storage, and database services closer to end users for single-digit millisecond latency.

**AWS Wavelength**: Embeds AWS compute and storage within telecommunications providers' 5G networks for ultra-low latency mobile applications.

[Learn more about Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/)

## AWS Documentation

- [Regions and Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)
- [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
- [Availability Zone IDs](https://docs.aws.amazon.com/ram/latest/userguide/working-with-az-ids.html)
- [AWS Local Zones features](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/)

## Additional Resources

- [High Availability and Scalability on AWS](https://docs.aws.amazon.com/whitepapers/latest/real-time-communication-on-aws/high-availability-and-scalability-on-aws.html) - Whitepaper on designing for high availability
