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

EC2 instance networking capabilities can vary based on instance family, size, and placement decisions. A common myth may that "bigger instances always mean better network performance" or that placement groups are only relevant for [High Performance Computing (HPC)](https://aws.amazon.com/hpc/workloads). In reality, network performance scaling is nuanced, with considerations around burst vs. sustained performance, cross-AZ traffic patterns, and the interplay between compute, storage, and network resources.

**Understanding Burst vs. Sustained Performance**

Many customers select instance types based on CPU and memory requirements while treating network performance as secondary. This leads to compute-optimized instances handling network-intensive workloads, or memory-optimized instances being oversized when network throughput may create the bottleneck.

Network performance scales non-linearly within instance families. For example, an EC2 c5.large instance provides [750 Mbps baseline with up to 10 Gbps](https://docs.aws.amazon.com/ec2/latest/instancetypes/co.html#co_network) burst, while a c5.xlarge instance offers the same 10 Gbps burst but delivers better sustained performance at 1.25 Gbps baseline. Mismatched ratios waste resources—you pay for unused compute while network performance constrains you, or you have abundant network capacity but insufficient compute resources to use it effectively.

EC2 instance network specifications list burst capabilities that aren’t sustained. [Certain EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) use baseline bandwidth with network I/O credits to burst beyond baseline on a best-effort basis. Applications exceeding baseline throughput during peak hours face performance degradation when burst credits exhaust. This can affect for e.g., batch processing workloads, database migrations, and backup operations requiring sustained high throughput.

**Key Guidelines:**

* [Monitor baseline and burst network performance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) for your specific EC2 instance type
* Instance bandwidth apply to inbound and outbound traffic, depending on destination and traffic flow patterns [(single flow vs multi-flow)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) 
* All [Nitro-based instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#instance-hypervisor-type) use [Elastic Network Adapter (ENA) Express](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ena-express.html) for enhanced networking, powered by AWS Scalable Reliable Datagram (SRD) technology that uses dynamic routing to increase throughput and minimize latency
* Non-Nitro instance types use [Enhanced Networking](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html) with Single Root I/O Virtualization (SR-IOV) for high-performance networking on supported instance types.
* Calculate sustained network throughput requirements separately from peak burst needs. For workloads requiring sustained high throughput, choose instance types where your required throughput stays at or below baseline performance. For periodic high-throughput workloads, schedule them during low-traffic periods to leverage burst capacity recovery. Consider multiple smaller instances instead of fewer larger ones to achieve better sustained aggregate throughput. Some instance types support [configurable bandwidth](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configure-bandwidth-weighting.html) weighting between network processing and Elastic Block Store (EBS) operations. Default baseline bandwidth settings are determined by instance type.
* The ENA driver publishes [network performance metrics](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html) from enabled instances. Use these metrics to troubleshoot performance issues, choose appropriate instance sizes for workloads, plan scaling activities proactively, and benchmark applications to determine whether they maximize available instance performance.

**Use Placement Groups for performance-critical workloads**

A [placement group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) (optional) is a logical grouping of instances within an Availability Zone that helps you to influence the placement of individual EC2 instances to meet specific requirements for performance, latency, or compliance. Placement groups are often treated as an all-or-nothing decision, with entire applications placed in cluster placement groups or none at all. In practice, the most effective approach involves selective use of different placement group types ([Cluster](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-cluster), [Partition](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-partition) or [Spread](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-spread)) for different tiers of your architecture. Cluster placement groups can significantly reduce latency between instances for the same AZ communication, but they concentrate failure risk. Spread placement groups reduce failure correlation but may increase latency. Partition placement groups offer a middle ground but are frequently overlooked for database sharding or distributed system deployments.

[Reduce the number of network hops](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ena-improve-network-latency-linux.html) for data packets. Use cluster placement groups selectively for tightly coupled components like database primary-replica pairs or application servers that perform frequent inter-node communication. Reserve spread placement groups for independent application instances behind load balancers. Leverage partition placement groups for distributed databases like Cassandra or MongoDB where you need both performance and failure isolation. Never place your entire infrastructure in a single cluster placement group—instead, create multiple smaller groups aligned with your application's communication patterns.

Placement groups can't span regions but can span AZs (except cluster type). When launching instances into an existing placement group, always use the same instance type and launch them simultaneously when possible to avoid capacity issues. If you receive placement group capacity errors, try launching in a different AZ within the same region, or temporarily launch smaller instance types and resize later.

**Cross-AZ communication patterns**

Many customers focus on high availability by spreading resources across AZs without considering the cumulative cost impact of cross-AZ data transfer. This can represent a significant portion of the total infrastructure costs for data-intensive applications.

Cross-AZ data transfer costs [$0.01-0.02 per GB](https://aws.amazon.com/ec2/pricing/on-demand/) depending on the AWS Region, which accumulates quickly for applications with chatty microservices or frequent database replication. More critically, cross-AZ latency is typically ~1-2ms higher than intra-AZ communication, which can compound in applications making hundreds of service calls per request.

Implement AZ affinity in your application architecture where feasible. Use Application Load Balancer (ALB)/Network Load Balancer (NLB) [target group attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-target-group-attributes.html#disable-cross-zone) to enable cross-zone load balancing only when necessary—disable it for applications that can tolerate some imbalance to reduce cross-AZ traffic. For database architectures, consider read replicas in the same AZ as your primary application servers for read-heavy workloads. Design your microservices communication patterns to minimize cross-AZ calls—consider using message queues or event-driven architectures to reduce synchronous cross-AZ communication.

Use [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) with cost allocation tags to identify your highest cross-AZ traffic patterns. Many applications generate surprising amounts of cross-AZ traffic through health checks, monitoring agents, or chatty service meshes. Consider using [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/) for applications requiring ultra-low latency to specific geographic areas, as they can reduce both latency and data transfer costs compared to cross-AZ communication.

**Implement Network Performance Monitoring and alerting**

Network performance issues are often discovered reactively through user complaints or application timeouts rather than proactive monitoring. Many monitoring setups focus on CPU and memory utilization while overlooking network metrics that can predict performance bottlenecks. Network performance degradation often appears gradually and can be masked by application-level retries or gray failures. By the time users notice problems, the issue may have been developing for days or weeks, making root cause analysis more difficult. Set up Amazon CloudWatch [network perfromance monitoring alerts](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html).

Use VPC Flow Logs with [Amazon CloudWatch Insights](https://repost.aws/knowledge-center/vpc-flow-logs-and-cloudwatch-logs-insights) to analyze traffic patterns and identify optimization opportunities. Network performance issues often correlate with other infrastructure changes, so maintain good change management practices and baseline your network performance before and after deployments. Consider using AWS X-Ray for distributed tracing to identify network bottlenecks in microservices architectures.

**Relevant Resources:**
1. [Amazon EC2 Instance Types Guide](https://aws.amazon.com/ec2/instance-types/) 
2. [Placement Groups Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html) 
3. [Enhanced Networking on Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html)
4. [EC2 Nitro networking under the hood](https://youtu.be/_hiNXKQZc0M) 

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
