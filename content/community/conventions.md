# Conventions

This section explains several conventions used in this best practices guide.

## Architecture Diagrams

### AWS Architecture Icons

Use the [most recent set of AWS Architecture Icons](https://aws.amazon.com/architecture/icons/) in any architecture diagrams. Only use icons for what they actually represent. 

### Accessibility

Create architecture diagrams with accessibility in mind. Text (or lines) and the background should have a contrast ration of [at least 4.5:1](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html). Generally, white or black on a strongly contrasting background is the best choice. 

- __Keep it simple__: Create diagrams that are as simple as possible; split content over several diagrams if needed.

- __Use double encoding__: Avoid using color as a sole indicator of difference.

- __Use alt text thoughtfully__: Include alt text on visuals to briefly describe the content.

## Representing IP addresses

### Example IP ranges and addresses

Use one of the multiple available [documentation ranges](https://en.wikipedia.org/wiki/Reserved_IP_addresses) for IPv4 and IPv6 addresses, when documenting "public" IP addresses. A good example would be ```192.0.2.0/24``` for an IPv4 range or ```2001:db8::/32``` for an IPv6 range. 

For "internal range" examples use [RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) (```10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16```), [RFC6598](https://datatracker.ietf.org/doc/html/rfc6598) (```100.64.0.0/10```), or [RFC6815](https://datatracker.ietf.org/doc/html/rfc6815) space (```198.19.0.0/16```), which is all supported within VPC.

### Representing IPv6 addresses and networks

Adhere to [RFC5952](https://datatracker.ietf.org/doc/html/rfc5952) when representing IPv6 addresses. 

| <!-- --> | Example  |
| -------- | -------- |
| :material-check:{ style="color: #4DB6AC" } __Correct__ | ```2001:db8:0:1234::```
| :material-close:{ style="color: #EF5350" } __Wrong__ | ```2001:0db8:0000:1234::```
| :material-close:{ style="color: #EF5350" } __Wrong__ | ```2001:DB8:0:1234::```
| :material-close:{ style="color: #EF5350" } __Wrong__ | ```2001:0DB8:0000:1234::```