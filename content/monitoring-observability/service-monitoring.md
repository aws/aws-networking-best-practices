<!--- Never modify this file directly. Update the scripts/generate-service-monitoring.py instead. -->
# AWS Services Monitoring

Guidance about the important metrics to monitor and alarm on, listed by service.

For the metrics, the following symbols are used:

| Symbol | Meaning |
| :-: | --- |
| :material-alarm-light:{ title=Alarm any time the condition exists. } | Alarm any time the condition exists. |
| :material-exclamation-thick:{ title=These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. } | These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. |
| :material-eye-check:{ title=These statistics should always be monitored, and may be alarmed depending on specific use case. } | These statistics should always be monitored, and may be alarmed depending on specific use case. |

For quotas:

| Symbol | Meaning |
| :-: | --- |
| :octicons-stop-16:{ title=Hard quota – Cannot be adjusted. } | Hard quota – Cannot be adjusted. |
| :fontawesome-solid-road-barrier:{ title=Medium quota - Contact AWS to discuss these and possible alternative architectures. } | Medium quota - Contact AWS to discuss these and possible alternative architectures. |
| :material-image-auto-adjust:{ title=Soft quota - Adjustable by customer. } | Soft quota - Adjustable by customer. |

!!! info "Remember"
    Always validate the quotas below against the official AWS documentation - in case of differences, the official quotas should be used. Not all quotas are repeated here - only the most critical ones to keep an eye on.

## Application Load Balancer

![Application Load Balancer](../assets/monitoring-observability/Service-ALB.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/ApplicationELB" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>RejectedConnectionCount</td><td>Going up more than 2/min</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyHostCount</td><td>Higher than 0 for longer than expected for scaling.</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>ELBAuthError, ELBAuthLatency</td><td>Going usually high, if user authentication is in use.</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ConsumedLCUs</td><td>None - monitor for cost</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveConnectionCount, NewConnectionCount, ProcessedBytes, ProcessedPackets</td><td>Outside of band.</td></tr></tbody></table> |
    | 2 | AWS CloudWatch "AWS/ApplicationELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyRequestCount, UnhealthyStateDNS, UnhealthyStateRouting</td><td>Higher than 0 for longer than expected for scaling.</td></tr></tbody></table> |
    | 3 | AWS CloudWatch "AWS/ApplicationELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>TargetConnectionErrorCount</td><td>Increasing</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>TargetResponseTime</td><td>Going unusually high</td></tr></tbody></table> |
    | 4 | Consider enabling access and/or connection logs. |

=== "Quotas"
    Always check these against the [official Application Load Balancer quotas.](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-limits.html)

    No key operational quotas.

## AWS Direct Connect

![AWS Direct Connect](../assets/monitoring-observability/Service-DX.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | Monitor your router’s incoming and outgoing BPS and PPS, along with number of routes advertised and received against quotas. |
    | 2 | AWS CloudWatch "AWS/DX" namespace, per connection:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>ConnectionState</td><td>Equals 0</td></tr><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>ConnectionEncryptionState</td><td>Equals 0 if MACsec is enabled</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>ConnectionErrorCount</td><td>Going up more than 1/min</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>ConnectionLightLevel(Rx&#129;Tx)</td><td>Outside the range of:<br><table><tbody><tr><td>1/10G:</td><td>Rx and Tx</td><td>-14.4 to 2.5</td></tr><tr><td rowspan="2">100G</td><td>Tx</td><td>-4.3 to 4.5</td></tr><tr><td>Rx</td><td>-10.6 to 4.5</td></tr><tr><td rowspan="2">400G</td><td>Tx</td><td>-1 to 6.09</td></tr><tr><td>Rx</td><td>-12 to 7.09</td></tr></tbody></table></td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ConnectionBps(Ingress&#129;Egress)</td><td>80% of your link speed</td></tr></tbody></table> |
    | 3 | DX Gateway is not in the traffic path, and does not have metrics to monitor. |
    | 4 | See [AWS Transit Gateway](#aws-transit-gateway). |
    | 5 | Virtual Private Gateways do not have metrics to monitor |

=== "Quotas"
    Always check these against the [official AWS Direct Connect quotas.](https://docs.aws.amazon.com/directconnect/latest/UserGuide/limits.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Routes from customer to AWS, per BGP session, per AFI (private/transit) | 100 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures."} |
    | Routes from customer to AWS, per BGP session, per AFI (public) | 1000 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures."} |
    | Routes from Transit Gateway to customer, combined AFIs | 200 | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures."} |

## AWS Site-to-Site VPN

![AWS Site-to-Site VPN](../assets/monitoring-observability/Service-S2SVPN.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | Monitor your router’s incoming and outgoing BPS and PPS, and alarm on tunnel down or errors. |
    | 2 | See [Direct Connect](#aws-direct-connect) |
    | 3 | AWS CloudWatch "AWS/VPN" namespace, per tunnel:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>TunnelState</td><td>Equals 0 (down)</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>TunnelDataIn, TunnelDataOut</td><td>Exceeding 1.0 Gbps</td></tr></tbody></table> |
    | 4 | See [AWS Transit Gateway](#aws-transit-gateway) |
    | 5 | Virtual Private Gateways do not have metrics to monitor. |

=== "Quotas"
    Always check these against the [official AWS Site-to-Site VPN quotas.](https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Bandwidth per tunnel | 1.25 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Packets per second | 140,000 | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## AWS Transit Gateway

![AWS Transit Gateway](../assets/monitoring-observability/Service-TGW.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/TransitGateway" namespace, per attachment:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>(Packet&#129;Bytes)DropCount(Blackhole&#129;NoRoute)</td><td>Greater than 1% of traffic</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>BytesIn + BytesOut</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>PacketsIn + PacketsOut</td><td>Approaching 7.5 Mpps</td></tr></tbody></table> |
    | 2 | AWS CloudWatch "AWS/TransitGateway" namespace, per Transit Gateway:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>(Packet&#129;Bytes)DropCount(Blackhole&#129;NoRoute)</td><td>Greater than 1% of traffic</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>BytesIn + BytesOut</td><td>None (alarm on the attachment)</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>PacketsIn + PacketsOut</td><td>None (alarm on the attachment)</td></tr></tbody></table> |
    | 3 | Consider enabling [Transit Gateway Flow Logs](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html) |

=== "Quotas"
    Always check these against the [official AWS Transit Gateway quotas.](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | VPC, Direct Connect, and Peering Attachments, per AZ | 100 Gbps, 7.5 Mpps | :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures."} |

## Network Load Balancer

![Network Load Balancer](../assets/monitoring-observability/Service-NLB.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/NetworkELB" namespace, per NLB:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>RejectedFlowCount</td><td>Greater than 0</td></tr><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>PortAllocationErrorCount</td><td>Greater than 0</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnHealthyHostCount</td><td>Higher than 0 for longer than expected for scaling.</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyRoutingFlowCount</td><td>Greater than 0</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>TCP_(Client&#129;ELB&#129;Target)_Reset_Count</td><td>Outside of band, or a large percentage of NewFlowCount</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveFlowCount, NewFlowCount, PeakPacketsPerSecond, ProcessedByte, ProcessedPacket</td><td>Outside of band</td></tr></tbody></table> |
    | 2 | AWS CloudWatch "AWS/NetworkELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>PortAllocationErrorCount</td><td>Greater than 0</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyRoutingRequestCount, UnhealthyStateDNS, UnhealthyStateRouting</td><td>Greater than 0</td></tr></tbody></table> |
    | 3 | Appropriate per-target monitoring. |
    | 4 | Consider enabling [access logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html) if you are using TLS listeners. |

=== "Quotas"
    Always check these against the [official Network Load Balancer quotas.](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-limits.html)

    No key operational quotas.

## Gateway Load Balancer

![Gateway Load Balancer](../assets/monitoring-observability/Service-GWLB.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/PrivateLinkEndpoints" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>PacketsDropped</td><td>Greater than 0.5%</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>RstPacketsReceived</td><td>Greater than 10 pps</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveConnections</td><td>Going anomalously high</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>BytesProcessed</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>NewConnections</td><td>Going anomalously high</td></tr></tbody></table> |
    | 2 | AWS CloudWatch "AWS/GatewayELB" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>RejectedFlowCount</td><td>Greater than 0</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyHostCount</td><td>Staying over 0</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ConsumedLCUs</td><td>Unexpected increases</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveFlowCount</td><td>Going anomalously high</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>NewFlowCount</td><td>Going anomalously high</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ProcessedBytes</td><td>Approaching 100 Gbps</td></tr></tbody></table> |
    | 3 | AWS CloudWatch "AWS/GatewayELB" namespace, per target group:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>UnhealthyHostCount</td><td>Staying over 0</td></tr></tbody></table> |
    | 4 | Per target monitoring. |

=== "Quotas"
    Always check these against the [official Gateway Load Balancer quotas.](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/quotas-limits.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Network traffic (per GWLB) | 100 Gpbs | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Network traffic (per GWLBe) | 100 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## Route53 Endpoints, Resolver, and Resolver DNS Firewall

![Route53 Endpoints, Resolver, and Resolver DNS Firewall](../assets/monitoring-observability/Service-R53.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/Route53Resolver" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>InboundQueryVolume or OutboundQueryAggregateVolume</td><td>Greater than 8,000 per second</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>EndpointUnHealthyENICount</td><td>Greater than 0 for more than 10 minute</td></tr></tbody></table> |
    | 2 | AWS CloudWatch "Instances" namespace, per instance:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>linklocal_allowance_exceeded</td><td>Greater than 20 per minute</td></tr></tbody></table> |
    | 3 | Consider utilizing the [Resolver DNS firewall](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-overview.html) |
    | 4 | Consider enabling [query logging](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html) from the VPC+2 resolver, endpoints, and the DNS Firewall |

=== "Quotas"
    Always check these against the [official Route53 Endpoints, Resolver, and Resolver DNS Firewall quotas.](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Packets per second from an instance to link-local/VPC+2, per interface | 1,024 pps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Queries per second per IP address in an endpoint | 10,000 qps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## NAT Gateway

![NAT Gateway](../assets/monitoring-observability/Service-NAT.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/NATGateway" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>PacketsDropCount</td><td>More than 0.1% per second</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>ErrorPortAllocation</td><td>More than 2 per second</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>BytesInFromSource + BytesInFromDestination</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>PacketsInFromSource + PacketsInFromDestination</td><td>Approaching 10 Mpps</td></tr></tbody></table> |

=== "Quotas"
    Always check these against the [official NAT Gateway quotas.](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Bits per seconds | 5 Gbps cold, able to scale up to 100 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Packets per second | 1 Mpps cold, able to scale up to 10 Mpps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Simultaneous connections from a source IP to each unique destination (can be mitigated by adding additional public IPs to the NAT gateway) | 55,000 | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Number of public IPs per NAT gateway | 8 (2 by default) | :material-image-auto-adjust:{ title="Soft quota - Adjustable by customer."} |

## Internet Gateway

![Internet Gateway](../assets/monitoring-observability/Service-IGW.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | Monitor instances (see Instances page) for network traffic exceeded. |
    | 2 | Consider enabling [CloudWatch Internet Monitor](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-InternetMonitor.html) |
    | 3 | Consider using [Network Access Analyzer](https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html) |
    | 4 | Consider enabling [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) |

=== "Quotas"
    Always check these against the [official Internet Gateway quotas.](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Traffic to the internet, per instance | 5 Gbps or 50% of network bandwidth for instances with more than 32 vCPUs | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## AWS PrivateLink

![AWS PrivateLink](../assets/monitoring-observability/Service-PL.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | Monitor the attached load balancer (see their entries) |
    | 2 | AWS CloudWatch "AWS/PrivateLinkServices" namespace, per service:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>RstPacketsSent</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>BytesProcessed</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveConnections</td><td>Unexpectedly increasing</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>NewConnections</td><td>Unexpectedly increasing</td></tr></tbody></table> |
    | 3 | AWS CloudWatch "AWS/PrivateLinkEndpoints" namespace, per endpoint:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>PacketsDropped</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>RstPacketsReceived</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>BytesProcessed</td><td>Approaching 100 Gbps</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>ActiveConnections</td><td>Unexpectedly increasing</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>NewConnections</td><td>Unexpectedly increasing</td></tr></tbody></table> |
    | 4 | Consider enabling [Contributor Insights](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-cloudwatch-metrics.html#privatelink-contributor-insights) to see which endpoints are the largest contributors to traffic. |

=== "Quotas"
    Always check these against the [official AWS PrivateLink quotas.](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-limits-endpoints.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Bits per second | 10 Gbps cold, able to scale to 100 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## Instances

![Instances](../assets/monitoring-observability/Service-Inst.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "agent" namespace, per network interface:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>conntrack_allowance_exceeded</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>conntrack_allowance_availabile</td><td>Approaching zero</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>bw_(in&#129;out)_allowance_exceeded</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>Per interface RX dropped count</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>queue_<X>_tx_queue_stop</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>pps_allowance_exceeded</td><td>Increasing quickly</td></tr><tr><td>:material-exclamation-thick:{ These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking. }</td><td>linklocal_allowance_exceeded</td><td>Increasing quickly</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>Output from “tc –s qdisc show <interface>”</td><td>Shows drops increasing quickly</td></tr></tbody></table> |
    | 2 | AWS CloudWatch “AWS/EC2” namespace contains many metrics to monitor, the exact ones depend on the details of the workload – CPUUtilization is a common one. See [the EC2 metrics page](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html) for more. |
    | 3 | Consider enabling [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html). |

=== "Quotas"
    Always check these against the [official Instances quotas.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Bits per second | Varies by [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html) | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |
    | Packets per second from an instance to link-local/VPC+2, per interface | 1,024 pps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

## AWS Network Firewall

![AWS Network Firewall](../assets/monitoring-observability/Service-ANFW.png)

/// caption
[Drawio Source](../assets/monitoring-observability/Services.drawio)
///

=== "Metrics"
    | Number | Notes |
    | :--: | --- |
    | 1 | AWS CloudWatch "AWS/NetworkFirewall" namespace:<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody><tr><td>:material-alarm-light:{ Alarm any time the condition exists. }</td><td>InvalidDroppedPackets, OtherDroppedPackets</td><td>Greater than 20/min</td></tr><tr><td>:material-eye-check:{ These statistics should always be monitored, and may be alarmed depending on specific use case. }</td><td>DroppedPackets, RejectedPackets, ReceivedPackets</td><td>Unexpected changes</td></tr></tbody></table> |
    | 2 | A Firewall Endpoint is a GWLB endpoint – see [GWLB](#gateway-load-balancer) for monitoring details. |
    | 3 | Consider [exporting flow, alert, and/or TLS logs](https://docs.aws.amazon.com/network-firewall/latest/developerguide/firewall-logging.html) from AWS Network Firewall’s stateful rules engine. |

=== "Quotas"
    Always check these against the [official AWS Network Firewall quotas.](https://docs.aws.amazon.com/network-firewall/latest/developerguide/quotas.html)

    | Component | Quota | Type |
    | --- | --- | --- |
    | Bits per second, per endpoint | 100 Gbps | :octicons-stop-16:{ title="Hard quota – Cannot be adjusted."} |

