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
| :material-image-auto-adjust:{ title="Soft quota - Adjustable by customer. Number afterwards indicates medium/hard limit." } | Soft quota - Adjustable by customer. Number afterwards indicates medium/hard limit. |
| :fontawesome-solid-road-barrier:{ title="Medium quota - Contact AWS to discuss these and possible alternative architectures." } | Medium quota - Contact AWS to discuss these and possible alternative architectures. |
| :octicons-stop-16:{ title="Hard quota – Cannot be adjusted." } | Hard quota – Cannot be adjusted. |

![Image title](../assets/monitoring-observability/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/monitoring-observability/Example.drawio)
///
