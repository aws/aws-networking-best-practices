# AWS Organizations and Account Structure

AWS Organizations enables centralized management and governance of multiple AWS accounts, providing the foundation for scalable, secure network architectures.

``` mermaid
graph LR
    Root["Root<br/>Organization"]
    
    Root --> Security["Security OU"]
    Root --> Network["Network OU"]
    Root --> Prod["Production OU"]
    Root --> NonProd["Non-Prod OU"]
    
    Security --> SecAccount["Security<br/>Account"]
    Network --> NetAccount["Networking<br/>Account"]
    Prod --> ProdApp["Production<br/>Accounts"]
    NonProd --> DevAccount["Dev/Test<br/>Accounts"]
    
    style Root fill:#2563eb,stroke:#1e40af,color:#fff,font-size:16px
    style Security fill:#059669,stroke:#047857,color:#fff,font-size:14px
    style Network fill:#dc2626,stroke:#b91c1c,color:#fff,font-size:14px
    style Prod fill:#7c3aed,stroke:#6d28d9,color:#fff,font-size:14px
    style NonProd fill:#ea580c,stroke:#c2410c,color:#fff,font-size:14px
    style SecAccount fill:#d1fae5,stroke:#059669,color:#000,font-size:13px
    style NetAccount fill:#fef3c7,stroke:#f59e0b,color:#000,font-size:13px
    style ProdApp fill:#e9d5ff,stroke:#7c3aed,color:#000,font-size:13px
    style DevAccount fill:#fed7aa,stroke:#ea580c,color:#000,font-size:13px
```

## Why Organizations Matter for Networking

A well-structured multi-account strategy isolates workloads, simplifies billing, and enables centralized network management. For networking specifically, Organizations allows you to:

- Centralize shared networking resources (Transit Gateway, Direct Connect, Route 53 Resolver)
- Enforce network security policies across all accounts
- Simplify cross-account connectivity and resource sharing
- Implement network segmentation aligned with organizational boundaries

## Core Concepts

### Organizational Units (OUs)

OUs are logical groupings of accounts that reflect your business structure. Common networking-focused OU patterns include:

- **Network/Infrastructure OU**: Centralized networking account(s)
- **Production OU**: Production workload accounts
- **Non-Production OU**: Development, testing, staging accounts
- **Security OU**: Security tooling and logging accounts

[Learn more about Organizational Units](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html)

### Service Control Policies (SCPs)

SCPs define maximum available permissions across accounts and OUs. For networking, use SCPs to:

- Prevent unauthorized VPC creation or deletion
- Restrict regions where network resources can be deployed
- Enforce tagging requirements for network resources
- Block public IP assignment or internet gateway creation in sensitive accounts

[Learn more about Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)

### Centralized Networking Account

A dedicated networking account hosts shared connectivity infrastructure:

- AWS Transit Gateway for inter-VPC and hybrid connectivity
- AWS Direct Connect connections and gateways
- Route 53 Resolver endpoints for DNS resolution
- Network monitoring and flow log aggregation

**Best Practice**: Establish this account early and use AWS Resource Access Manager (RAM) to share resources with other accounts.

**Additional resources**:

- [AWS Resource Access Manager (RAM)](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) - Share network resources across accounts
- [Building Scalable and Secure Multi-VPC Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html) - Whitepaper on centralized networking patterns
- [Creating a single internet exit point using Transit Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/creating-a-single-internet-exit-point-from-multiple-vpcs-using-aws-transit-gateway/) - Blog post on centralized egress
- [AWS Control Tower networking guide](https://docs.aws.amazon.com/controltower/latest/userguide/networking.html) - Networking in landing zones

## Account Structure Best Practices

1. **Separate networking from workloads**: Keep shared network infrastructure in a dedicated account
2. **Align with organizational structure**: Mirror your business units and environments in your OU design
3. **Plan for scale**: Design your structure to accommodate future growth
4. **Use consistent naming**: Apply naming conventions across accounts and OUs
5. **Implement least privilege**: Use SCPs to enforce network security boundaries

**Additional resources**:

- [Building landing zones on AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html) - Multi-account environment setup
- [AWS VPC Connectivity Options](https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/welcome.html) - Whitepaper on network connectivity patterns

## AWS Documentation

- [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html)
- [Organizing Your AWS Environment](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html)
- [Best Practices for Organizational Units](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html)
