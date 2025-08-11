# Internal Traffic Monitoring

See VPC Flow Logs, Athena analysis, CloudWatch, and other tools to understand what network activity inside AWS is going on.

There are several ways to monitor traffic inside AWS.

## Flow Logs

Flow Logs are comma-separated files that provide a record of traffic that goes through whatever is producing the flow logs. Today, there are two sources: [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) and [AWS Transit Gateway Flow Logs](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html). Both produce the same format file, although with different fields. You can also create flow logs [for network interfaces AWS services create for you](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-basics.html), such as NAT gateways and Transit Gateways.

Flow Logs can be expensive to leave running full-time for everything, so it is recommended to either select only certain resources to monitor, or create automation that only collects them at certain times or events. A good practice is to enable VPC Flow Logs everywhere with a filter to only log REJECT actions. Any entries that show up in the resulting log is traffic that is blocked for some reason ([security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html), [NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html), or [VPC Block Public Access](https://docs.aws.amazon.com/vpc/latest/userguide/security-vpc-bpa.html). These entries could be indicators of unauthorized activity.

With VPC Flow Logs, by default, only [version 2](https://docs.aws.amazon.com/vpc/latest/userguide/flow-log-records.html#flow-logs-fields) fields are recorded. While needed for consistency, AWS is currently up to version 8, with many additional fields now available. The most helpful will depend on your specific use case, but frequently are:

* `vpc-id`, `subnet-id`, especially when storing the flow logs in a unified location, like a common S3 bucket. Storing all your flow logs in a common place enable consolidated querying. Having these fields present as fields to query, sort, and filter against make working in a consolidated deployment easier.
* `instance-id` to more easily identify the instance in question - AWS tools such as [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html), [AWS Config](https://aws.amazon.com/config/), and [AWS Backup](https://aws.amazon.com/backup/ focus on instance ID. EC2 instances can be [configured](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/hostname-types.html) (and default to, for IPv6) to have a hostname of their resource ID (i.e. `i-0123456789abcdef.us-west-2.compute.internal`), and thus their logs may use that identifier as well. 
* `pkt-srcaddr` and `pkt-dstaddr` especially for EKS pods
* `az-id` is helpful in cases when you want to determine what traffic is going cross-AZ
* `pkt-src-aws-service` and `pkt-dst-aws-service` to get AWS to provide an indication this is to or from AWS. However, keep in mind, many AWS services overlap each other, so only one will show. This field is generally most useful to identify if traffic is going to *any* AWS service.
* `traffic-path` to give an easy filter to filter on for traffic leaving the VPC and by what method. A common use case is to verify if traffic going to S3 (filtering on `pkt-dst-aws-service` equal to "S3") is going via a local gateway endpoint (resulting in a value of 2 or 7 here), or is using a NAT gateway (a value of 6) which is more expensive. 
* `reject-reason` is very useful with the [VPC Block Public Access](https://docs.aws.amazon.com/vpc/latest/userguide/security-vpc-bpa.html) feature to see what traffic is getting blocked by it.

Overall, if you are starting fresh, it is recommended to use Custom Fields and get the specific data you want, instead of just accepting the default fields.

### Tools for analyzing flow logs

Flow Logs can produce a lot of data. AWS provides several tools to help analyze these.

#### CloudWatch Contributor Insights

[CloudWatch Contributor Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContributorInsights.html) can provide quick reports for the most commonly asked for questions from VPC flow logs - top talks, traffic by source, and so on. One often-missed piece of information is that Contributor Insights [integrates with PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-cloudwatch-metrics.html#privatelink-contributor-insights) and provides you reporting which endpoints are the heaviest users of your [PrivateLink Endpoint Service](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-share-your-services.html).

#### Athena Queries

One frequently-missed tool is under the Actions dropdown in Flow Logs.
![Generate Athena Integration dropdown](../assets/monitoring-observability/athena-generate.png)

There is an option Generate Athena Integration. This will provide you with a CloudFormation template that you can then deploy that sets up Athena to query your VPC Flow Logs using SQL syntax or with the pre-built reports:

![Example Athena Reports](../assets/monitoring-observability/athena-reports.png)

## Network Synthetic Monitors

Available in CloudWatch, under Network Monitoring, [Synthetic Monitors](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/what-is-network-monitor.html) deploy AWS-managed ICMP or TCP probes in your VPC, with a list of target IP addresses you provide. These then report on observed packet loss and round trip time. These can be outside of your VPC, or outside of AWS - you can use these to measure the time between your VPC and something on-premises for example. It works by deploying a network interface inside your VPC, sending out the test traffic, and reporting it back to CloudWatch. If your VPC is isolated (no direct Internet access), you can use [PrivateLink Endpoints](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch-and-interface-VPC.html#cloudwatch-network-monitoring-interface-VPC-availability) to establish the connectivity needed for Synthetic Monitors to report back to CloudWatch.

## Network Flow Monitors

[Network Flow Monitor](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-NetworkFlowMonitor.html) involve installing agents onto your workloads. These agents monitor statistics from TCP connections (not the payloads), and sends it to a backend service for reporting. These reports can be combined to see information about cross-AZ, cross-VPC, or for specific flows. There is a good [AWS Blog Post](https://aws.amazon.com/blogs/networking-and-content-delivery/visualizing-network-performance-of-your-aws-cloud-workloads-with-network-flow-monitor/) that goes through setting it up and use cases for it. As with Synthetic Monitors, if your VPC is isolated (no direct Internet access), you can use [PrivateLink Endpoints](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch-and-interface-VPC.html#cloudwatch-network-monitoring-interface-VPC-availability) to establish the connectivity needed for Network Flow Monitors to report back to CloudWatch.
