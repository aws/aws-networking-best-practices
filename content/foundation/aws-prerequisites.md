# Before You Start

Before implementing AWS networking solutions, ensure you have foundational AWS knowledge. This page covers non-networking prerequisites essential for working with AWS network architectures.

## Identity and Access Management (IAM)

Understanding IAM is critical for managing network resource permissions and cross-account access.

**Key concepts**:

- **Users, Groups, and Roles**: Authentication and authorization for network resources
- **Policies**: Permission management for VPC, subnet, and gateway operations
- **Cross-account access**: Sharing Transit Gateways, Route 53 Resolver endpoints, and other network resources
- **Service-linked roles**: Automatic roles created by networking services

**Why it matters for networking**: You'll need IAM permissions to create VPCs, configure routing, share resources via AWS RAM, and implement network security controls.

[AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)

## AWS CLI and Console

Familiarity with AWS interfaces is essential for implementing and troubleshooting network configurations.

**You should be comfortable with**:

- Navigating the AWS Console
- Using AWS CLI for automation and scripting
- Understanding AWS CloudFormation or Terraform (for infrastructure as code)

## Service Quotas

AWS imposes limits on networking resources. Understanding and managing these quotas prevents deployment issues.

**Common networking quotas**:

- VPCs per Region (default: 5)
- Subnets per VPC (default: 200)
- Route table entries (default: 50)
- VPC peering connections per VPC (default: 50)

**Best Practice**: Review quotas before designing your architecture and request increases proactively.

[View and manage service quotas](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html)

## Tagging Strategy

Consistent resource tagging is essential for cost allocation, automation, and network resource management.

**Recommended tags for network resources**:

- `Environment` (Production, Development, Testing)
- `Owner` (Team or individual responsible)
- `CostCenter` (For billing allocation)
- `Name` (Descriptive resource name)

## AWS Well-Architected Framework

Familiarize yourself with AWS architectural best practices, particularly the Security and Reliability pillars.

- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
- [Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html)

## Learning Resources

If you're new to AWS, start with these resources:

- [AWS Getting Started Guide](https://aws.amazon.com/getting-started/)
- [AWS Cloud Practitioner Essentials](https://aws.amazon.com/training/course-descriptions/cloud-practitioner-essentials/)
- [AWS Technical Essentials](https://aws.amazon.com/training/course-descriptions/essentials/)

## Next Steps

Once you're comfortable with these prerequisites, explore the Foundation topics:

- [AWS Organizations](organizations.md) - Multi-account structure for networking
- [Amazon VPC](vpc.md) - Your isolated virtual network
- [Regions and Availability Zones](regions-azs.md) - Geographic distribution
- [CIDR Planning](cidr.md) - IP address planning
- [Subnets](subnets.md) - Network segmentation
- [IPAM](ipam.md) - IP address management at scale
