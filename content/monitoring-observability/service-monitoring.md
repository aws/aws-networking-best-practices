# AWS Services Monitoring

Guidance about the important metrics to monitor and alarm on, listed by service.

For the metrics, the following symbols are used:


Symbol | Meaning
:----: | --------------
👁️ | These statistics should always be monitored, and may be alarmed depending on specific use case.
❗️ | These statistics should trigger alarms if the condition persists for several minutes. A couple increments occasionally should be expected as a normal part of networking.
‼️ | Alarm any time the condition exists. 

For quotas:

Symbol | Meaning
:-: | ---
(s) | Soft quota - Adjustable by customer. Number afterwards indicates medium/hard limit.
(m) | Medium quota - Contact AWS to discuss these and possible alternative architectures.
(h) | Hard quota – Cannot be adjusted. 

