#!/usr/bin/python3
# Because we want the service-monitoring.md file to be very consistent, and the formatting can be quite complex,
# this script exists to build that file for us.
import sys
from typing import Optional, List, Dict, Any

metric_types = {
    'crit': {'icon': ':material-alarm-light:', 'title': 'Alarm any time the condition exists.'},
    'warn': {'icon': ':material-exclamation-thick:', 'title': 'These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking.'},
    'info': {'icon': ':material-eye-check:', 'title': 'These statistics should always be monitored, and may be alarmed depending on specific use case.'}
}

quota_types = {
    'hard': { 'icon': ':octicons-stop-16:', 'title': 'Hard quota – Cannot be adjusted.'},
    'med': {'icon': ':fontawesome-solid-road-barrier:', 'title': 'Medium quota - Contact AWS to discuss these and possible alternative architectures.'},
    'soft': {'icon': ':material-image-auto-adjust:', 'title': 'Soft quota - Adjustable by customer.'}
}


def error_msg(s: str):
    print(f'❗️{s}')


def metric_item_str(item: dict) -> str:
    ret = ''

    if item['type'] == 'metrics':
        ret += f'AWS CloudWatch "{item["ns"]}" namespace'
        if item['per'] is not None:
            ret += f', per {item["per"]}'
        ret += ':<br/><table><thead><tr><th></th><th>Metric</th><th>Alarm if</th></tr></thead><tbody>'
        for datum in item['data']:
            if len(datum) != 3:
                error_msg(f'Metric datum {datum} does not have enough elements.')
                return ''
            if datum[0] not in metric_types:
                error_msg(f'Metric datum {datum} has an invalid metric type.')
                return ''
            ret += f'<tr><td>{metric_types[datum[0]]["icon"]}{{ {metric_types[datum[0]]["title"]} }}</td><td>{datum[1].replace("|", "&#129;")}</td><td>{datum[2]}</td></tr>'
        ret += '</tbody></table>'
        return ret
    elif item['type'] == 'text':
        return item["v"]
    else:
        error_msg(f'Metric item {item} has an unknown type {item['type']}')
        return ''


def gen_service(name:str, abbrev:str, items:List[Dict[str, Any]], quotas:Optional[List[List[str]]], quotas_url:str) -> str:
    ret = f'## {name}\n\n![{name}](../assets/monitoring-observability/Service-{abbrev}.png)\n\n'\
          f'/// caption\n'\
          f'[Drawio Source](../assets/monitoring-observability/Services.drawio)\n'\
          f'///\n\n=== "Metrics"\n'
    ret += '    | Number | Notes |\n    | :--: | --- |\n'
    for idx, item in enumerate(items):
        ret += f'    | {idx+1} | {metric_item_str(item)} |\n'

    ret += f'\n=== "Quotas"\n'
    ret += f'    Always check these against the [official {name} quotas.]({quotas_url})\n\n'
    if quotas is None or len(quotas) == 0:
        ret += f'    No key operational quotas.\n'
    else:
        ret += '    | Component | Quota | Type |\n'
        ret += '    | --- | --- | --- |\n'
        for q in quotas:
            if q[2] not in quota_types:
                error_msg(f'Quota datum {q} has an invalid quota type.')
                return ''
            ret += f'    | {q[0]} | {q[1]} | {quota_types[q[2]]["icon"]}{{ title="{quota_types[q[2]]["title"]}"}} |\n'
    ret += '\n'
    return ret


if __name__ == '__main__':
    text = ('<!--- Never modify this file directly. Update the scripts/generate-service-monitoring.py instead. -->\n'
            '# AWS Services Monitoring\n\n'
            'Guidance about the important metrics to monitor and alarm on, listed by service.\n\n'
            'For the metrics, the following symbols are used:\n\n| Symbol | Meaning |\n| :-: | --- |\n')
    for key, data in metric_types.items():
        text += f'| {data["icon"]}{{ title={data["title"]} }} | {data["title"]} |\n'
    text += '\nFor quotas:\n\n| Symbol | Meaning |\n| :-: | --- |\n'
    for key, data in quota_types.items():
        text += f'| {data["icon"]}{{ title={data["title"]} }} | {data["title"]} |\n'

    text += ('\n!!! info "Remember"\n'
             '    Always validate the quotas below against the official AWS documentation - in case of differences, the official quotas should be used. Not all quotas are repeated here - only the most critical ones to keep an eye on.\n\n')

    text += gen_service('Application Load Balancer', 'ALB',
                        items=[{'type': 'metrics', 'ns': 'AWS/ApplicationELB', 'per': None, 'data':
                            [['crit', 'RejectedConnectionCount', 'Going up more than 2/min'],
                             ['warn', 'UnhealthyHostCount', 'Higher than 0 for longer than expected for scaling.'],
                             ['warn', 'ELBAuthError, ELBAuthLatency', 'Going usually high, if user authentication is in use.'],
                             ['info', 'ConsumedLCUs', 'None - monitor for cost'],
                             ['info', 'ActiveConnectionCount, NewConnectionCount, ProcessedBytes, ProcessedPackets', 'Outside of band.']]},
                               {'type': 'metrics', 'ns': 'AWS/ApplicationELB', 'per': 'target group', 'data':
                                   [['warn', 'UnhealthyRequestCount, UnhealthyStateDNS, UnhealthyStateRouting', 'Higher than 0 for longer than expected for scaling.']]},
                               {'type': 'metrics', 'ns': 'AWS/ApplicationELB', 'per': 'target group', 'data':
                                   [['warn', 'TargetConnectionErrorCount', 'Increasing'],
                                    ['info', 'TargetResponseTime', 'Going unusually high']]},
                               {'type': 'text', 'v': 'Consider enabling access and/or connection logs.'}],
                        quotas=None,
                        quotas_url='https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-limits.html')

    text += gen_service('AWS Direct Connect', 'DX',
                        items=[{'type': 'text', 'v': 'Monitor your router’s incoming and outgoing BPS and PPS, along with number of routes advertised and received against quotas.'},
                               {'type': 'metrics', 'ns': 'AWS/DX', 'per': 'connection', 'data':
                                   [['crit', 'ConnectionState', 'Equals 0'],
                                    ['crit', 'ConnectionEncryptionState', 'Equals 0 if MACsec is enabled'],
                                    ['warn', 'ConnectionErrorCount', 'Going up more than 1/min'],
                                    ['warn', 'ConnectionLightLevel(Rx|Tx)',
                                     'Outside the range of:<br><table><tbody>'
                                     '<tr><td>1/10G:</td><td>Rx and Tx</td><td>-14.4 to 2.5</td></tr>'
                                     '<tr><td rowspan="2">100G</td><td>Tx</td><td>-4.3 to 4.5</td></tr><tr><td>Rx</td><td>-10.6 to 4.5</td></tr>'
                                     '<tr><td rowspan="2">400G</td><td>Tx</td><td>-1 to 6.09</td></tr><tr><td>Rx</td><td>-12 to 7.09</td></tr>'
                                     '</tbody></table>'],
                                    ['info', 'ConnectionBps(Ingress|Egress)', '80% of your link speed']]},
                               {'type': 'text', 'v': 'DX Gateway is not in the traffic path, and does not have metrics to monitor.'},
                               {'type': 'text', 'v': 'See [AWS Transit Gateway](#aws-transit-gateway).'},
                               {'type': 'text', 'v': 'Virtual Private Gateways do not have metrics to monitor'}],
                        quotas=[['Routes from customer to AWS, per BGP session, per AFI (private/transit)', '100', 'med'],
                                ['Routes from customer to AWS, per BGP session, per AFI (public)', '1000', 'med'],
                                ['Routes from Transit Gateway to customer, combined AFIs', '200', 'med']],
                        quotas_url='https://docs.aws.amazon.com/directconnect/latest/UserGuide/limits.html')

    text += gen_service('AWS Site-to-Site VPN', 'S2SVPN',
                        items=[{'type': 'text', 'v': 'Monitor your router’s incoming and outgoing BPS and PPS, and alarm on tunnel down or errors.'},
                               {'type': 'text', 'v': 'See [Direct Connect](#aws-direct-connect)'},
                               {'type': 'metrics', 'ns': 'AWS/VPN', 'per': 'tunnel', 'data':
                                   [['crit', 'TunnelState', 'Equals 0 (down)'],
                                    ['info', 'TunnelDataIn, TunnelDataOut', 'Exceeding 1.0 Gbps']]},
                               {'type': 'text', 'v': 'See [AWS Transit Gateway](#aws-transit-gateway)'},
                               {'type': 'text', 'v': 'Virtual Private Gateways do not have metrics to monitor.'}],
                        quotas=[['Bandwidth per tunnel', '1.25 Gbps', 'hard'],
                                ['Packets per second', '140,000', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html')

    text += gen_service('AWS Transit Gateway', 'TGW',
                        items=[{'type': 'metrics', 'ns': 'AWS/TransitGateway', 'per': 'attachment', 'data':
                            [['info', '(Packet|Bytes)DropCount(Blackhole|NoRoute)', 'Greater than 1% of traffic'],
                             ['info', 'BytesIn + BytesOut', 'Approaching 100 Gbps'],
                             ['info', 'PacketsIn + PacketsOut', 'Approaching 7.5 Mpps']]},
                               {'type': 'metrics', 'ns': 'AWS/TransitGateway', 'per': 'Transit Gateway', 'data':
                                   [['info', '(Packet|Bytes)DropCount(Blackhole|NoRoute)', 'Greater than 1% of traffic'],
                                    ['info', 'BytesIn + BytesOut', 'None (alarm on the attachment)'],
                                    ['info', 'PacketsIn + PacketsOut', 'None (alarm on the attachment)']]},
                               {'type': 'text', 'v': 'Consider enabling [Transit Gateway Flow Logs](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html)'}],
                        quotas=[['VPC, Direct Connect, and Peering Attachments, per AZ', '100 Gbps, 7.5 Mpps', 'med']],
                        quotas_url='https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html')

    text += gen_service('Network Load Balancer', 'NLB',
                        items=[{'type': 'metrics', 'ns': 'AWS/NetworkELB', 'per': 'NLB', 'data':
                            [['crit', 'RejectedFlowCount', 'Greater than 0'],
                             ['crit', 'PortAllocationErrorCount', 'Greater than 0'],
                             ['warn', 'UnHealthyHostCount', 'Higher than 0 for longer than expected for scaling.'],
                             ['warn', 'UnhealthyRoutingFlowCount', 'Greater than 0'],
                             ['warn', 'TCP_(Client|ELB|Target)_Reset_Count', 'Outside of band, or a large percentage of NewFlowCount'],
                             ['info', 'ActiveFlowCount, NewFlowCount, PeakPacketsPerSecond, ProcessedByte, ProcessedPacket', 'Outside of band']]},
                               {'type': 'metrics', 'ns': 'AWS/NetworkELB', 'per': 'target group', 'data':
                                   [['crit', 'PortAllocationErrorCount', 'Greater than 0'],
                                    ['warn', 'UnhealthyRoutingRequestCount, UnhealthyStateDNS, UnhealthyStateRouting', 'Greater than 0']]},
                               {'type': 'text', 'v': 'Appropriate per-target monitoring.'},
                               {'type': 'text', 'v': 'Consider enabling [access logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html) if you are using TLS listeners.'}],
                        quotas=None,
                        quotas_url='https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-limits.html')

    text += gen_service('Gateway Load Balancer', 'GWLB',
                        items=[{'type': 'metrics', 'ns': 'AWS/PrivateLinkEndpoints', 'per': None, 'data':
                            [['warn', 'PacketsDropped', 'Greater than 0.5%'],
                             ['warn', 'RstPacketsReceived', 'Greater than 10 pps'],
                             ['info', 'ActiveConnections', 'Going anomalously high'],
                             ['info', 'BytesProcessed', 'Approaching 100 Gbps'],
                             ['info', 'NewConnections', 'Going anomalously high']]},
                               {'type': 'metrics', 'ns': 'AWS/GatewayELB', 'per': None, 'data':
                                   [['crit', 'RejectedFlowCount', 'Greater than 0'],
                                    ['warn', 'UnhealthyHostCount', 'Staying over 0'],
                                    ['info', 'ConsumedLCUs', 'Unexpected increases'],
                                    ['info', 'ActiveFlowCount', 'Going anomalously high'],
                                    ['info', 'NewFlowCount', 'Going anomalously high'],
                                    ['info', 'ProcessedBytes', 'Approaching 100 Gbps']]},
                               {'type': 'metrics', 'ns': 'AWS/GatewayELB', 'per': 'target group', 'data':
                                   [['warn', 'UnhealthyHostCount', 'Staying over 0']]},
                               {'type': 'text', 'v': 'Per target monitoring.'}],
                        quotas=[['Network traffic (per GWLB)', '100 Gpbs', 'hard'], ['Network traffic (per GWLBe)', '100 Gbps', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/quotas-limits.html')

    text += gen_service('Route53 Endpoints, Resolver, and Resolver DNS Firewall', 'R53',
                        items=[{'type': 'metrics', 'ns': 'AWS/Route53Resolver', 'per': None, 'data':
                            [['warn', 'InboundQueryVolume or OutboundQueryAggregateVolume', 'Greater than 8,000 per second'],
                             ['info', 'EndpointUnHealthyENICount', 'Greater than 0 for more than 10 minute']]},
                               {'type': 'metrics', 'ns': 'Instances', 'per': 'instance', 'data':
                                   [['warn', 'linklocal_allowance_exceeded', 'Greater than 20 per minute']]},
                               {'type': 'text', 'v': 'Consider utilizing the [Resolver DNS firewall](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-overview.html)'},
                               {'type': 'text', 'v': 'Consider enabling [query logging](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html) from the VPC+2 resolver, endpoints, and the DNS Firewall'}],
                        quotas=[['Packets per second from an instance to link-local/VPC+2, per interface', '1,024 pps', 'hard'],
                                ['Queries per second per IP address in an endpoint', '10,000 qps', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html')

    text += gen_service('NAT Gateway', 'NAT',
                        items=[{'type': 'metrics', 'ns': 'AWS/NATGateway', 'per': None, 'data':
                            [['crit', 'PacketsDropCount', 'More than 0.1% per second'],
                             ['warn', 'ErrorPortAllocation', 'More than 2 per second'],
                             ['warn', 'BytesInFromSource + BytesInFromDestination', 'Approaching 100 Gbps'],
                             ['warn', 'PacketsInFromSource + PacketsInFromDestination', 'Approaching 10 Mpps']]}],
                        quotas=[['Bits per seconds', '5 Gbps cold, able to scale up to 100 Gbps', 'hard'],
                                ['Packets per second', '1 Mpps cold, able to scale up to 10 Mpps', 'hard'],
                                ['Simultaneous connections from a source IP to each unique destination (can be mitigated by adding additional public IPs to the NAT gateway)', '55,000', 'hard'],
                                ['Number of public IPs per NAT gateway', '8 (2 by default)', 'soft']],
                        quotas_url='https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html')

    text += gen_service('Internet Gateway', 'IGW',
                        items=[{'type': 'text', 'v': 'Monitor instances (see Instances page) for network traffic exceeded.'},
                               {'type': 'text', 'v': 'Consider enabling [CloudWatch Internet Monitor](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-InternetMonitor.html)'},
                               {'type': 'text', 'v': 'Consider using [Network Access Analyzer](https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html)'},
                               {'type': 'text', 'v': 'Consider enabling [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)'}],
                        quotas=[['Traffic to the internet, per instance', '5 Gbps or 50% of network bandwidth for instances with more than 32 vCPUs', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html')

    text += gen_service('AWS PrivateLink', 'PL',
                        items=[{'type': 'text', 'v': 'Monitor the attached load balancer (see their entries)'},
                               {'type': 'metrics', 'ns': 'AWS/PrivateLinkServices', 'per': 'service', 'data':
                                   [['warn', 'RstPacketsSent', 'Increasing quickly'],
                                    ['warn', 'BytesProcessed', 'Approaching 100 Gbps'],
                                    ['info', 'ActiveConnections', 'Unexpectedly increasing'],
                                    ['info', 'NewConnections', 'Unexpectedly increasing']]},
                               {'type': 'metrics', 'ns': 'AWS/PrivateLinkEndpoints', 'per': 'endpoint', 'data':
                                   [['warn', 'PacketsDropped', 'Increasing quickly'],
                                    ['warn', 'RstPacketsReceived', 'Increasing quickly'],
                                    ['warn', 'BytesProcessed', 'Approaching 100 Gbps'],
                                    ['info', 'ActiveConnections', 'Unexpectedly increasing'],
                                    ['info', 'NewConnections', 'Unexpectedly increasing']]},
                               {'type': 'text', 'v': 'Consider enabling [Contributor Insights](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-cloudwatch-metrics.html#privatelink-contributor-insights) to see which endpoints are the largest contributors to traffic.'}],
                        quotas=[['Bits per second', '10 Gbps cold, able to scale to 100 Gbps', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-limits-endpoints.html')

    text += gen_service('Instances', 'Inst',
                        items=[{'type': 'metrics', 'ns': 'agent', 'per': 'network interface', 'data':
                            [['crit', 'conntrack_allowance_exceeded', 'Increasing quickly'],
                             ['warn', 'conntrack_allowance_availabile', 'Approaching zero'],
                             ['warn', 'bw_(in|out)_allowance_exceeded', 'Increasing quickly'],
                             ['warn', 'Per interface RX dropped count', 'Increasing quickly'],
                             ['warn', 'queue_<X>_tx_queue_stop', 'Increasing quickly'],
                             ['warn', 'pps_allowance_exceeded', 'Increasing quickly'],
                             ['warn', 'linklocal_allowance_exceeded', 'Increasing quickly'],
                             ['info', 'Output from “tc –s qdisc show <interface>”', 'Shows drops increasing quickly']]},
                               {'type': 'text', 'v': 'AWS CloudWatch “AWS/EC2” namespace contains many metrics to monitor, the exact ones depend on the details of the workload – CPUUtilization is a common one. See [the EC2 metrics page](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html) for more.'},
                               {'type': 'text', 'v': 'Consider enabling [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html).'}],
                        quotas=[['Bits per second', 'Varies by [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html)', 'hard'],
                                ['Packets per second from an instance to link-local/VPC+2, per interface', '1,024 pps', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html')

    text += gen_service('AWS Network Firewall', 'ANFW',
                        items=[{'type': 'metrics', 'ns': 'AWS/NetworkFirewall', 'per': None, 'data':
                            [['crit', 'InvalidDroppedPackets, OtherDroppedPackets', 'Greater than 20/min'],
                             ['info', 'DroppedPackets, RejectedPackets, ReceivedPackets', 'Unexpected changes']]},
                               {'type': 'text', 'v': 'A Firewall Endpoint is a GWLB endpoint – see [GWLB](#gateway-load-balancer) for monitoring details.'},
                               {'type': 'text', 'v': 'Consider [exporting flow, alert, and/or TLS logs](https://docs.aws.amazon.com/network-firewall/latest/developerguide/firewall-logging.html) from AWS Network Firewall’s stateful rules engine.'}],
                        quotas=[['Bits per second, per endpoint', '100 Gbps', 'hard']],
                        quotas_url='https://docs.aws.amazon.com/network-firewall/latest/developerguide/quotas.html')

















    with open('service-monitoring.md', 'w') as f:
        f.write(text)







