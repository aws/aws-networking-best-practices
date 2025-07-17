# AWS Services Monitoring

Guidance about the important metrics to monitor and alarm on, listed by service.

For the metrics, the following symbols are used:

| Symbol | Meaning |
| :----: | -------------- |
| :material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." } | These statistics should always be monitored, and may be alarmed depending on specific use case. |
| :material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." } | These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. |
| :material-alarm-light:{ title="Alarm any time the condition exists." } | Alarm any time the condition exists. |

For quotas:

| Symbol | Meaning |
| :-: | --- |
| :material-image-auto-adjust:{ title="Soft quota - Adjustable by customer." } | Soft quota - Adjustable by customer. |
| :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } | Medium quota - Contact AWS to discuss these and possible alternative architectures. |
| :octicons-stop-16:{ title="Hard quota – Cannot be adjusted." } | Hard quota – Cannot be adjusted. |

!!! info "Remember"
    Always validate the quotas below against the official AWS documentation - in case of differences, the official quotas should be used. Not all quotas are repeated here - only the most critical ones to keep an eye on.

## Application Load Balancer

![Application Load Balancer](../assets/monitoring-observability/Service-ALB.png)

/// caption
Application Load Balancer - [Drawio Source](../assets/monitoring-observability/Services.drawio)
///

!!! metrics "Metrics to Monitor"

| Number | Notes |
| :---: | --- |
| 1 | AWS CloudWatch "AWS/ApplicationELB" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ title="Alarm any time the condition exists." } </td><td>RejectedConnectionCount</td><td>Going up more than 2/min</td></tr><tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>UnhealthyHostCount</td><td>Higher than 0 for longer than required for scaling<tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>ELBAuthError, ELBAuthLatency</td><td>Going unusually high, if authentication is in use</td></tr></td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>ConsumedLCUs</td><td>None - monitor for cost</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>ActiveConnectionCount, NewConnectionCount, ProcessedBytes ProcessedPackets</td><td>Outside of expectations or use CloudWatch anomaly detection bands</td></tr></tbody></table> |
| 2 | AWS CloudWatch "AWS/ApplicationELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>UnhealthyRequestRoutingCount, UnhealthyStateDNS, UnhealthyStateRouting</td><td>Higher than 0 for longer than required for scaling</td></tr></tbody></table> |
| 3 | AWS CloudWatch "AWS/ApplicationELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>TargetConnectionErrorCount</td><td>Increasing</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>TargetResponseTime</td><td>Going unusually high</td></tr></tbody></table> |

!!! quotas "Operational Quotas"

Copied from the [official Application Load Balancer quotas](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-limits.html).

No key operational quotas.

## AWS Direct Connect

![AWS Direct Connect](../assets/monitoring-observability/Service-DX.png)

/// caption
AWS Direct Connect - [Drawio Source](../assets/monitoring-observability/Services.drawio)
///

!!! metrics "Metrics to Monitor"

| Number | Notes |
| :----: | -----|
| 1 | Monitor your router’s incoming and outgoing BPS and PPS, along with number of routes advertised and received against quotas. |
| 2 | AWS CloudWatch "AWS/DX" namespace, per connection:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ title="Alarm any time the condition exists." } </td><td>ConnectionState</td><td>Equals 0</td></tr><tr><td>:material-alarm-light:{ title="Alarm any time the condition exists." } </td><td>ConnectionEncryptionState</td><td>Equals 0 if MACSec is enabled</td></tr><tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>ConnectionErrorCount</td><td>Going up more than 1/min</td></tr><tr><td>:material-exclamation-thick:{ title="These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking." }</td><td>ConnectionLightLevel(Rx&#124;Tx)</td><td>Outside the range of:<br/>1/10G: -14.4 to 2.5<br/>100G: Tx: -4.3 to 4.5<br/>Rx: -10.6 to 4.5<br/>400G: Tx: -1 to 6.09<br/>Rx: -12 to 7.09</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>ConnectionBps(Ingress&#124;Egress)</td><td>80% of your link speed</td></tr></tbody></table><br/>AWS CloudWatch "AWS/DX" namespace, per VIF:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>VirtualInterfaceBps(Ingress&#124;Egress)</td><td>Exceeding plan</td></tr></tbody></table> |
| 3 | DX Gateway is not in the traffic path, and does not have metrics to monitor. |
| 4 | See Transit Gateway. |
| 5 | Virtual Private Gateways do not have metrics to monitor. |

!!! quotas "Operational Quotas"

Copied from the [official AWS Direct Connect quotas](https://docs.aws.amazon.com/directconnect/latest/UserGuide/limits.html).

| Component | Quota | Type |
| --- | --- | --- |
| Routes from customer to AWS, per BGP session, per AFI (private/transit) | 100 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } |
| Routes from customer to AWS, per BGP session, per AFI (public) | 1,000 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } |
| Routes from Transit Gateway to customer, combined AFI | 200 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } |

## AWS Site-to-Site VPN

![AWS Site-to-Site VPN](../assets/monitoring-observability/Service-S2SVPN.png)

/// caption
AWS Site-to-Site VPN - [Drawio Source](../assets/monitoring-observability/Services.drawio)
///

:material-chart-line: **Key metrics to monitor**

| Number | Notes  |
| :---: | --- |
| 1 | Monitor your router’s incoming and outgoing BPS and PPS, and alarm on tunnel down or errors. |
| 2 | See Direct Connect |
| 3 | AWS CloudWatch "AWS/VPN" namespace, per connection:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ title="Alarm any time the condition exists." } </td><td>TunnelState</td><td>Equals 0 (down)</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>TunnelData(In&#124;Out)</td><td>Exceeding 1.0 Gbps</td></tr></tbody></table> |
| 4 | See Transit Gateway |
| 5 | Virtual Private Gateways do not have metrics to monitor. |

:material-gauge: **Key operational quotas**

Copied from the [official AWS Site-to-Site VPN quotas](https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html).

| Component | Quota | Type |
| --- | --- | --- |
| Bandwidth | 1.25 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted." } |
| Packets per second | 140,000 | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted." } |

## AWS Transit Gateway

![AWS Transit Gateway](../assets/monitoring-observability/Service-TGW.png)

/// caption
AWS Transit Gateway - [Drawio Source](../assets/monitoring-observability/Services.drawio)
///

:material-chart-line: **Key metrics to monitor**

| Number | Notes |
| :---: |-----|
| 1 | AWS CloudWatch "AWS/TransitGateway" namespace, per attachment:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>(Packets&#124;Bytes)DropCount(Blackhole&#124;NoRoute)</td><td>Greater than 1% of traffic</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>Bytes(In&#124;Out)</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>Packets(In&#124;Out)</td><td>Approaching 7.5 Mpps</td></tr></tbody></table> |
| 2 | AWS CloudWatch "AWS/TransitGateway" namespace, per TransitGateway:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>(Packets&#124;Bytes)DropCount(Blackhole&#124;NoRoute)</td><td>Greater than 1% of traffic</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>Bytes(In&#124;Out)</td><td>None (alarm on attachments)</td></tr><tr><td>:material-eye-check:{ title="These statistics should always be monitored, and may be alarmed depending on specific use case." }</td><td>Packets(In&#124;Out)</td><td>None (alarm on attachments)</td></tr></tbody></table> |
| 3 | Consider enabling [Transit Gateway Flow Logs](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html). |

:material-gauge: **Key operational quotas**

Copied from the [official AWS Transit Gateway quotas](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html).

| Component                                            | Quota               | Type |
|------------------------------------------------------|---------------------| --- |
| VPC, Direct Connect, and Peering attachments, per AZ | 100 Gbps, 7.5 Mpps | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } |
