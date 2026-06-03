# Observability

This section covers how to gain visibility into your AWS network — what traffic is flowing, whether the services carrying that traffic are healthy, and how to get notified when something goes wrong. Network observability is not a single dashboard; it is a layered approach where each data source answers different questions, and the combination gives you the full picture.

Observability operates on top of the connectivity, application networking, and security layers. It consumes the logs, metrics, and events those layers produce and turns them into actionable insight. Without observability, you're operating blind: unable to troubleshoot connectivity failures, unable to detect security incidents, unable to attribute costs, and unable to validate that your architecture is performing as designed.

## 1. Internal Traffic Monitoring

**Internal traffic monitoring** provides visibility into traffic flows between resources within your AWS environment — VPC-to-VPC, subnet-to-subnet, ENI-to-ENI. This is the foundation of network security analysis, cost attribution, and connectivity troubleshooting.

**Key data sources:**

*   **VPC Flow Logs** — Packet-level metadata at VPC, subnet, or ENI level with 40+ custom format fields
*   **Transit Gateway Flow Logs** — Centralized cross-VPC and cross-account traffic visibility from a single configuration
*   **VPC Lattice Access Logs** — Per-request service-to-service detail with identity, latency, and auth decisions
*   **Network Firewall Logs** — Stateful inspection decisions (allowed, denied, alerted) with rule attribution
*   **Amazon Athena** — SQL-based querying of Flow Logs stored in S3 for large-scale analysis

***Key insight:*** *VPC Flow Logs are not optional in production. They are the network equivalent of application logging — without them, you cannot investigate security incidents, troubleshoot connectivity issues, or understand your actual traffic patterns.*

## 2. External Traffic Monitoring

**External traffic monitoring** covers visibility into traffic crossing the boundary between your AWS environment and the public internet — both ingress from clients and egress to external services. Each layer captures what the others cannot see.

**Key data sources:**

*   **CloudFront access logs / real-time logs** — Edge-level client experience (latency, cache status, protocol, geographic distribution)
*   **ALB / NLB access logs** — Per-request or per-connection detail (target latency, response codes, TLS metadata)
*   **AWS WAF logs** — Security evaluation results (rule matches, allow/block decisions, request attributes)
*   **NAT gateway CloudWatch metrics** — Egress volume, connection counts, port exhaustion, packet drops
*   **Route 53 query logs** — DNS query patterns for public hosted zones

***Key insight:*** *ALB access logs are free to generate, cost pennies to store, and are irreplaceable during incident investigation. There is no valid reason to leave them disabled on a production ALB.*

## 3. AWS Services Monitoring

**AWS services monitoring** focuses on the operational health of the networking services themselves — not the traffic flowing through them, but whether the infrastructure carrying that traffic is healthy. A Transit Gateway with blackhole drops, a NAT gateway exhausting its port allocation, or a Direct Connect connection flapping are service-level failures that traffic monitoring alone won't catch.

**Key patterns:**

*   **Critical metrics per service** — The specific CloudWatch metrics that signal real operational problems for Transit Gateway, NAT gateway, Direct Connect, VPN, ALB, NLB, Network Firewall, and VPC Lattice
*   **Composite alarms** — Combine multiple signals to confirm real problems before paging (reduce alert fatigue)
*   **Anomaly detection** — ML-based alerting that adapts to traffic patterns without manual threshold tuning
*   **Quota monitoring** — Alarm at 80% utilization before hitting service limits
*   **Centralized dashboards** — Cross-account, cross-Region visibility for the networking team

***Key insight:*** *CloudWatch metrics tell you the service is healthy. Synthetic health checks tell you the path works end-to-end. You need both — a healthy service with broken routing still means an outage.*

## 4. Notifications

**Notifications** bridge the gap between detecting a problem and getting the right person to act on it. The number one operational failure in monitoring is alert fatigue — teams ignoring alerts because too many are false positives or low-priority noise.

**Key services:**

*   **CloudWatch Alarms** — Metric-based alerting with thresholds, anomaly detection, and composite alarms
*   **Amazon EventBridge** — Event-driven notifications for state changes (VPN tunnel down, Direct Connect flap, BGP session lost)
*   **Amazon SNS** — Fan-out delivery to email, PagerDuty, Lambda, SQS
*   **AWS Health Dashboard** — Proactive awareness of AWS service events affecting your resources
*   **AWS Chatbot** — Deliver alarms to Slack and Microsoft Teams with interactive actions

***Key insight:*** *If your team routinely ignores alarms, you don't have a monitoring problem — you have an alarm design problem. Every alarm must have a clear owner and a defined response action.*

---

## Explore Observability Topics

<div class="grid cards" markdown>

*   :material-lan: **Internal Traffic Monitoring**

    ---

    VPC Flow Logs, Transit Gateway Flow Logs, VPC Lattice access logs, Athena integration, and cost-effective log analysis.

    [:octicons-arrow-right-24: Internal Traffic Monitoring](internal-traffic.md)

*   :material-web-check: **External Traffic Monitoring**

    ---

    CloudFront logs, ALB/NLB access logs, AWS WAF logs, NAT gateway metrics, and client experience monitoring.

    [:octicons-arrow-right-24: External Traffic Monitoring](external-traffic.md)

*   :material-monitor-dashboard: **AWS Services Monitoring**

    ---

    Critical metrics per service, composite alarms, anomaly detection, centralized dashboards, and automated remediation.

    [:octicons-arrow-right-24: AWS Services Monitoring](service-monitoring.md)

*   :material-bell-alert: **Notifications**

    ---

    Alarm design, severity tiers, composite alarms, EventBridge state-change routing, and cross-account event forwarding.

    [:octicons-arrow-right-24: Notifications](notifications.md)

</div>
