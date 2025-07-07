# Networking Basics

Fundamental concepts for AWS networking. This section covers core
VPC concepts, IP addressing, routing, security, and connectivity patterns
that form the building blocks for all AWS network architectures.

<div class="grid cards" markdown>

*   :material-school-outline: **AWS Prerequisites**

    ---

    Essential AWS knowledge needed before starting with networking.

    ---

    [:octicons-arrow-right-24: AWS Prerequisites](aws-prerequisites.md)

*   :material-star-plus-outline: **Your first VPC**

    ---

    Setting up your first Virtual Private Cloud (VPC).

    ---

    [:octicons-arrow-right-24: First VPC](first-vpc.md)

</div>

## 1. AWS Regions and Availability Zone considerations

How to distribute resources across AWS Regions, AZs, and LZs for resilience. Fundamental architectural concept that impacts region/subnet design and app availability.

## 2. VPC IP Addressing and CIDR Planning

Choosing IP ranges and avoiding conflicts, CIDR notation and subnet sizing.
Blah

## 3. IPv4 vs. IPv6 in VPCs

Dual-stack networking and protocol-specific considerations. Private vs public vs Elastic IPs. Basics of BYOIP.

## 4. Single VPC vs. Multiple VPCs per Account

When to use one large VPC vs multiple smaller VPCs.

## 5. VPC Sharing

When to use it vs separate VPCs per account. "should we share or separate?

## 6. Subnet Strategies

"how many subnets do I need?" and common patterns (public/private).

## 7. Elastic Network Interfaces (ENIs)

How EC2 instances connect to VPCs and concepts like primary/secondary IPs.

## 8. Route Tables and Traffic Flow

How routing works within VPCs and how traffic decisions are made.

## 9. Gateways

When to use virtual private gateways, internet gateway, NAT gateways, transit gateways, and Direct Connect gateways

## 10. Internet connectivity patterns

Basic internet connectivity patterns and the decision between Centralized vs distributed NAT patterns, high availability.

## 11. Accessing AWS services

When to use IGW/NAT gateway vs gateway/interface endpoints to access AWS services

## 12. VPC DNS Resolution, DHCP Options

Name resolution within VPC

## 13. Security Groups vs. Network ACLs

Difference between these and when to use each approach.

## 14. Network Performance and Sizing

Instance bandwidth considerations, placement groups.

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

![Image title](../assets/basics/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/basics/Example.drawio)
///
