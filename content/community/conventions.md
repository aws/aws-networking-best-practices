# Conventions

This section explains several conventions used in this best practices guide.

## Architecture Diagrams

### AWS Architecture Icons

Use the [most recent set of AWS Architecture Icons](https://aws.amazon.com/architecture/icons/) in any architecture diagrams. Only use icons for what they actually represent.

### Format and tooling

Provide architecture diagrams in PNG file format with a light neutral background, such as white. Leave a border of 8px around all elements. Each diagram needs to be accompanied by the source in [draw.io](https://www.drawio.com/) format to allow future modifications.

#### File Organization

Store files using this structure:

```
content/
  assets/
    basics/
      vpc-setup-diagram.png
      vpc-setup-diagram.drawio
    security/
      network-acl-flow.png
      network-acl-flow.drawio
```

#### Technical Requirements

* **File format**: PNG with transparent or white background
* **Dimensions**: Maximum 1200px wide, maintain aspect ratio
* **File size**: Keep under 500KB for optimal loading
* **Resolution**: 72-96 DPI for web display

![Image title](../assets/community/Example.png){ width="300" }
/// caption
Example image caption - [Drawio Source](../assets/community/Example.drawio)
///

### Accessibility

Create architecture diagrams with accessibility in mind. Text (or lines) and the background should have a contrast ratio of [at least 4.5:1](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html). Generally, white or black on a strongly contrasting background is the best choice.

#### Accessibility Examples

**Good contrast combinations:**

* Black text (#000000) on white background (#FFFFFF) - 21:1 ratio
* Dark gray text (#16191F) on white background - 12.6:1 ratio

**Poor contrast combinations:**

* Light gray text (#CCCCCC) on white background - 1.6:1 ratio ❌
* Yellow text on white background - 1.1:1 ratio ❌

#### Guidelines

* **Keep it simple**: Create diagrams that are as simple as possible; split content over several diagrams if needed. If you can't sketch it on a napkin, it's too complicated.

* **Use double encoding**: Avoid using color as a sole indicator of difference.

* **Use alt text thoughtfully**: Include alt text on visuals to briefly describe the content.

### Diagram styling

Use the following guidance to align your diagram's style with AWS' visual style and language. Does your diagram check off all these element guidelines?

* **Background Color**: Use white (#FFFFFF) as the background color. Do not leave the background transparent.

* **Lines and arrows**: Lines should have a minimum thickness/width of 1 pt. Use solid lines for primary connections and containers. Secondary connections and containers can be represented as Dashed lines. For arrow pointer styles use open arrow pointers over closed ones.

* **Colors**: Do not modify the colors provided by official icon libraries - use as is because they contain semantic meaning (e.g., certain colors represent a service category). If you need to add additional colors to your diagram, make sure the color values are included within the [AWS Brand color palette](https://design.amazon.com/styleguide/9188F3F120Af/aws/visual-identity/color/).

* **Typography (fonts)**: Use the weight Regular in most cases. Bold can be used to provide extra emphasis if needed. Do not use Thin or Light (they fail accessibility standards below most diagram-needed font sizes). The minimum font size should be 12px. Use the color #16191F or #000000 for most icon/illustration labels. In diagrams *italics* is preferred over ^^underlines^^. (In a diagram with arrows/lines, underlines can add unnecessary visual noise).

* **Labels and text**: Center align the label with the icon and place it under the icon. Do not embed explanatory text into images - it neither accessible nor localizable. Use only short labels for each illustrative object or icon. If you'd like to highlight specific parts of the diagram with explanatory text, use callouts. This is better for accessibility, localization, and regional compliance.

* **Outside framing**: Apply a padding of 8px equally to the top, bottom, left, and right of your image. Do not apply a visible outside border to the diagram, and we recommend staying away from border shadows and fades.

## Representing IP addresses

Use approved documentation ranges to avoid conflicts with real networks and ensure examples work universally. Our automated validation checks enforce these standards.

### Example IP ranges and addresses

Use one of the multiple available [documentation ranges](https://en.wikipedia.org/wiki/Reserved_IP_addresses) for IPv4 and IPv6 addresses, when documenting "public" IP addresses. A good example would be ```192.0.2.0/24``` for an IPv4 range or ```2001:db8::/32``` for an IPv6 range.

For "internal range" examples use [RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) (```10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16```), [RFC6598](https://datatracker.ietf.org/doc/html/rfc6598) (```100.64.0.0/10```), or [RFC6815](https://datatracker.ietf.org/doc/html/rfc6815) space (```198.19.0.0/16```), which is all supported within VPC.

#### Complete Network Examples

**Multi-tier VPC setup:**

```
VPC: 10.0.0.0/16
  Public subnet: 10.0.1.0/24
  Private subnet: 10.0.2.0/24
  Database subnet: 10.0.3.0/24
```

### Representing IPv6 addresses and networks

Adhere to [RFC5952](https://datatracker.ietf.org/doc/html/rfc5952) when representing IPv6 addresses.

| <!-- --> | Example |
| -------- | -------- |
| :material-check:{ style="color: #4DB6AC" } **Correct** | ```2001:db8:0:1234::``` |
| :material-close:{ style="color: #EF5350" } **Wrong** | ```2001:0db8:0000:1234::``` |
| :material-close:{ style="color: #EF5350" } **Wrong** | ```2001:DB8:0:1234::``` |
| :material-close:{ style="color: #EF5350" } **Wrong** | ```2001:0DB8:0000:1234::``` |

## Console Screenshots

The AWS console goes through frequent changes, and those images can be hard to update while keeping a consistent look between multiple screenshots in a section. Furthermore, customers should be investing in automating AWS deployments, and using the console only for review, monitoring, or tinkering. Thus, the use of screenshots should be avoided for most cases, including:

* How to configure a service
* Basic AWS operations

Consider carefully before using them for:

* Showing graphical output in the console (maps, charts, and the like)
* Highlighting a single function or item in the console, especially if explaining where it is would be complex.

## Quick Checklist

Before submitting diagrams:

* [ ] Uses latest AWS Architecture Icons
* [ ] PNG format with white background
* [ ] Includes matching .drawio source file
* [ ] Text contrast ratio ≥ 4.5:1
* [ ] Font size ≥ 12px
* [ ] Uses approved IP ranges
* [ ] File size < 500KB
* [ ] Descriptive alt text included
