# Multi-Environment Connectivity

Connect your AWS infrastructure with on-premises data centers, other cloud
providers, and remote users. This section covers architectural patterns and
best practices for building secure, reliable hybrid and multi-cloud network
connections.
## (Proposed)

## VPC IP Addressing and CIDR Planning
Choosing IP ranges and avoiding conflicts, CIDR notation and subnet sizing,

## IPv4 vs. IPv6 in VPCs
Dual-stack networking and protocol-specific considerations. 

## Single AZ and Multi-AZ considerations
How to distribute resources across AZs for resilience. Fundamental architectural concept that impacts subnet design and app availability.

## Single VPC vs. Multiple VPCs per Account
When to use one large VPC vs multiple smaller VPCs.

## VPC Sharing
When to use it vs separate VPCs per account. "should we share or separate?

## Subnet Strategies
"how many subnets do I need?" and common patterns (public/private).

## ENIs
How EC2 instances connect to VPCs and concepts like primary/secondary IPs.

## Route Tables and Traffic Flow
How routing works within VPCs and how traffic decisions are made.

## IGW/EIGW and NAT GWs
Basic internet connectivity patterns and the decision between Centralized vs distributed NAT patterns, high availability.

## VPC DNS Resolution, DHCP Options
Name resolution within VPC

## Security Groups vs. Network ACLs
Difference between these and when to use each approach.
## Network Performance and Sizing
Instance bandwidth considerations, placement groups. 
## IPAM Basics
IP allocation strategies and avoiding address exhaustion.



## Additional resources to get started?

[skills builder]: https://aws.amazon.com/training/learn-about/advanced-networking/

If you're new to AWS networking, it's important to get a solid foundation
before diving into deployment design. We recommend starting with some basic
AWS networking concepts, which are covered in this section.

For a more structured learning path, check out the official AWS training on
[skills builder].

[AWS Stash]: https://awsstash.com/
[AWS networking foundations]: https://www.youtube.com/watch?v=8nNurTFy-h4
[Networking foundations]: https://www.youtube.com/watch?v=4QoFt8so9hI

Additionally, [AWS Stash] is a great resource for finding a wide variety of
AWS content, including YouTube videos, blogs, and podcasts. You can search
for specific topics, like networking, and find useful resources.

A great place to start is by watching `Networking Fundamentals` sessions from
past AWS re:Invent events. Here are a couple of examples:

* [AWS networking foundations] from re:Invent 2023

* [Networking foundations] from re:Invent 2021
