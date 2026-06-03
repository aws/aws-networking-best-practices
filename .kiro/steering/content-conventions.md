# Content Conventions for AWS Networking Best Practices

This document defines the structural, formatting, and tone conventions for all content pages in this project. Follow these conventions when creating new sections (e.g., Security, Observability) or modifying existing ones to maintain consistency across the site.

## Content Scope and Priorities

These principles define what content belongs in this guide and how to frame it. They align with the project's [philosophy](content/community/philosophy.md).

- **Real-world, production-ready patterns over theoretical or basic setups.** Prioritize multi-account connectivity patterns over single-account demos. Show production-ready security configurations, not minimal examples. Include cost optimization strategies based on actual usage patterns.
- **Multi-account is the default context.** Assume the reader operates in an AWS Organizations environment with multiple accounts, centralized networking, and cross-account resource sharing. Single-account patterns are acceptable only as stepping stones or for explicitly scoped sandbox/PoC guidance.
- **IPv6 is a core element, not optional.** All examples and best practices must include both IPv4 and IPv6 considerations. Treat IPv6 adoption as inevitable. When a page covers a service or pattern, include IPv6 guidance (dual-stack configuration, IPv6-specific behavior, planning recommendations). Diagrams should show dual-stack implementations by default where applicable.
- **Strong fundamentals before advanced patterns.** Ensure foundational concepts are explained clearly because they enable informed decisions across diverse use cases. Advanced patterns should reference the fundamentals they build on.
- **Cost optimization as a first-class concern.** Networking costs (cross-AZ data transfer, NAT gateway processing, Transit Gateway data processing, egress charges) are significant. Include cost implications in best practices and architectural decisions, not as an afterthought.
- **Reference pricing dimensions, not specific values.** AWS pricing varies by Region and changes frequently. When discussing cost, describe the pricing *dimensions* (per-hour, per-GB processed, per-attachment, per-request) and relative cost comparisons (e.g., "VPC peering has no data processing charge while Transit Gateway charges per-GB"), but do not include specific dollar amounts (e.g., "$0.02/GB"). Link to the official pricing page for current values.

## AI Discoverability (GEO/AEO)

This guide is consumed by AI models (ChatGPT, Claude, Kiro, Perplexity, Google AI Overviews) as much as by human readers. When an LLM searches for AWS networking guidance, it typically fetches a single page, reads it, and synthesizes a recommendation from that page alone. The following principles ensure our content is effective in that context:

- **First paragraphs must include specific, quantitative, citable claims.** LLMs decide whether to read a page based on the snippet (first 1-2 sentences). Generic openings like "Learn about Transit Gateway" get skipped. Specific openings like "AWS Transit Gateway interconnects up to 5,000 VPCs through a single regional hub with per-GB data processing at $0.02/GB" get fetched and cited. Lead every page with the most important, specific facts.
- **Each page must be self-contained for single-page consumption.** LLMs typically fetch one page per search result. If understanding a recommendation requires reading three other pages, the LLM gets an incomplete picture. Include enough inline context (1-2 sentences summarizing a prerequisite concept) that a reader of *only that page* can form a complete understanding. Cross-reference links are still valuable for humans, but don't rely on them as the sole source of critical context.
- **Include failure modes alongside capabilities.** LLMs that only see capabilities without constraints will hallucinate that a service can do things it cannot. Every "Best Practices" section should include what goes wrong when the practice is not followed, common incorrect assumptions, and explicit "do NOT use when" guidance. Capability + constraint on the same page creates a stable reasoning unit for AI models.
- **Write decision-grade content, not just tutorial content.** When users ask LLMs for recommendations, the model needs to synthesize a decision. Content that answers "when should I use X vs Y vs Z" is more valuable for AI discoverability than content that only answers "how do I configure X." Our "When to use" and "Combining with other services" sections serve this purpose — ensure they contain enough specificity to be directly quotable.
- **Avoid generic opening sentences.** Never start a page or section with "This page covers..." or "Learn about..." or "In this section, we will..." — these are invisible to AI models because they contain no information. Start with the substance.

## Tone and Voice

- **Patterns-first, opinionated, direct.** Lead with the architectural pattern or decision, not with service descriptions. State what the right answer is and explain why.
- **Explain WHY, not just WHAT.** Every best practice must include rationale. "Deploy NAT Gateways per-AZ" is incomplete without "because a single NAT Gateway is a single point of failure and cross-AZ traffic incurs data transfer charges."
- **Use `***Key insight:***` callouts** to highlight the single most important takeaway in each major section. These are italic-bold one-liners that distill the section's core message.
- **Be direct about trade-offs.** State when something is "not the right choice" and explain what is. Avoid hedging language like "you might consider" or "it depends" without following up with the specific factors that determine the answer.
- **Address the reader as a practitioner.** Assume they're building production AWS networks, not learning cloud basics.
- **Technical precision verified by substance.** Link to authoritative AWS documentation rather than duplicating content. When referencing a service capability, link to the official docs. Accuracy matters more than comprehensiveness.
- **Use correct AWS service names.** Follow the naming conventions in `.kiro/steering/aws-service-names.json`. Use the full name (with "AWS" or "Amazon" prefix) on first mention per page, then the short name on subsequent mentions. Never use names listed in the `do_not_use` field. Key rules: "Amazon VPC" (not just "VPC") when referring to the service; "AWS WAF" always requires the prefix; "NAT gateway" and "internet gateway" are lowercase (VPC features, not services); "Elastic Load Balancing" is the service name (not "Elastic Load Balancer").
- **Follow AWS style conventions.** No Latin abbreviations (use "for example" not "e.g.", use "that is" not "i.e."). Spell out "Availability Zone" in prose (use "AZ" only in compound adjectives like "Multi-AZ", "per-AZ", "cross-AZ", or where space is severely limited like mermaid diagrams). Use lowercase for resource names that aren't proper nouns (security group, transit gateway, load balancer). Don't use "allows you to" — rewrite to "you can" or focus on the action. Always include a space between numbers and units (100 Gbps, not 100Gbps). Never use "Note that" or "Please" — delete them entirely. Don't start headings with articles (a, an, the). Use "VPC Flow Logs" (title case) for the feature name, "flow logs" (lowercase) for the resource.

## Page Structure

Every content sub-page (not index pages) follows this structure in order:

### 1. Title (H1)

```markdown
# Page Title
```

Single H1 at the top. Use the service or concept name.

### 2. Prerequisites Admonition

```markdown
!!! info "Prerequisites"
    This section assumes familiarity with [Page A](link.md) and [Page B](link.md). Review those topics first if you're new to AWS networking fundamentals.
```

- Required on every sub-page except the very first page in the reading order (e.g., `aws-prerequisites.md` in Foundation).
- Link to the specific pages the reader should understand first.
- Keep it to one sentence.

### 3. Opening Paragraphs

- 2-3 paragraphs that frame the page's scope, explain why the topic matters for networking, and set up the key decisions the reader will face.
- **The first sentence must be a specific, quantitative, citable claim** — not a generic framing statement. This is the snippet that determines whether an AI model reads the page.
- No bullet lists in the opening — use prose.
- State the page's organizing principle (e.g., "This page is patterns-first" or "This page covers two distinct concerns: ingress and egress").

### 4. Mermaid Diagram

Every page includes at least one mermaid diagram near the top that provides a visual overview of the page's scope. Use consistent styling:

```markdown
``` mermaid
graph TB
    subgraph GroupName["Label"]
        Node1["Description"]
        Node2["Description"]
    end

    style GroupName fill:none,stroke:#2563eb,stroke-width:2px,stroke-dasharray:5 5,color:#2563eb
    style Node1 fill:#2563eb,stroke:#1e40af,color:#fff
```
```

Color conventions:
- Blue (`#2563eb`) for primary/network-layer concepts
- Purple (`#7c3aed`) for application-layer or secondary concepts
- Green (`#059669`) for third groupings or alternatives
- Orange (`#ff9900`) for AWS-level containers
- Use `fill:none` with `stroke-dasharray:5 5` for grouping subgraphs

### 5. Key Capabilities (for service-focused pages)

Use grid cards to present 4-6 key capabilities:

```markdown
<div class="grid cards" markdown>

*   :material-icon-name: **Capability title**

    ---

    One to three sentences describing the capability and why it matters.

</div>
```

### 6. Main Content Sections (H2)

Organize by architectural concern, not by service feature list. Common patterns:

- **For service pages:** Concepts → Best Practices → When to Use → Combining with Other Services → Documentation
- **For pattern pages:** Pattern overview → Options (with comparison tables) → Best Practices → Documentation
- **For informational pages:** Concepts → Best Practices → Documentation

### 7. Best Practices Section

```markdown
## Best Practices

### Category Name

#### Specific practice title (imperative verb)

Explanation paragraph with rationale (WHY this matters, not just WHAT to do).

Additional detail, examples, or caveats.

***Key insight:*** *The single most important takeaway from this subsection.*
```

- Use H3 (`###`) for practice categories, H4 (`####`) for individual practices.
- Each practice starts with an imperative verb (Deploy, Use, Enable, Design, Plan, Avoid).
- Include rationale in every practice — never just a bare instruction.
- Include failure modes: what goes wrong when the practice is not followed, common incorrect assumptions.
- Use tables for comparisons, options, or decision matrices within practices.

### 8. "When to Use" Section (where applicable)

```markdown
## When to use [Service Name]

[Service] is the right choice when:

* Condition 1
* Condition 2

[Service] is **not** the right choice when:

* Condition 1 (use [Alternative] instead)
* Condition 2
```

- Include this section for services where there's a genuine choice (Organizations, VPC, IPAM, Transit Gateway, etc.).
- Omit for concepts that are always required (CIDR planning, subnets, Regions/AZs).
- Always state what the alternative is when something is "not the right choice."

### 9. "Combining with Other Services" Section (where applicable)

```markdown
## Combining [Topic] with other services

| Combination | [Topic] provides | Other service provides |
| --- | --- | --- |
| **[Topic] + Service A** | What this topic handles | What the other service handles |
```

- Include for services and concepts that interact with other AWS services.
- Omit for purely informational pages (Regions/AZs, Before You Start).
- Each row should make clear what each service's role is in the combination.

### 10. Documentation Section

Always use grid cards with Material icons:

```markdown
## Documentation

<div class="grid cards" markdown>

*   :material-file-document: **Title**

    ---

    One-sentence description of what this resource covers.

    [:octicons-arrow-right-24: Link text](https://url)

</div>
```

- Include 4-6 documentation links.
- Prefer official AWS documentation, then whitepapers, then blog posts.
- Use appropriate Material icons (`:material-file-document:` for docs, `:material-post:` for blogs, `:material-school:` for workshops, `:material-currency-usd:` for pricing, `:material-github:` for repos).

### 11. Cross-References Section

End every page with cross-references to related pages:

```markdown
## Related [Section] Pages

- **[Page Name](link.md)** — One sentence explaining the relationship
```

Or for pages with many cross-references, group by section:

```markdown
**Relationship to other Foundation topics:**
- **[Page](link.md)**: How this page relates to that one

**Relationship to Connectivity:**
- **[Page](../connectivity/page.md)**: How this page relates to connectivity topics
```

## Index Page Structure

Section index pages (Foundation, Connectivity, Application Networking) follow a different structure:

```markdown
# Section Title

Opening paragraph (2-3 sentences framing the section's scope).

## 1. Sub-topic Name

**Bold service/concept name** followed by a one-sentence description.

**Key [concepts/services/patterns/decisions]:**

*   **Item** — Description
*   **Item** — Description

***Best Practice / Key insight:*** *One-liner takeaway.*

## 2. Next Sub-topic

[repeat pattern]

---

## Explore [Section] Topics

<div class="grid cards" markdown>

-   :material-icon: **Page Title**

    ---

    One-sentence description of what the page covers in depth.

    [:octicons-arrow-right-24: Link text](page.md)

</div>
```

- Numbered sections (## 1, ## 2, etc.) provide content summaries.
- Grid cards at the bottom link to the full sub-pages.
- Each grid card description should be more specific than just the page title — mention key topics covered.

## Formatting Conventions

### Tables

Use tables for:
- Comparisons between options (service A vs service B)
- Decision matrices (when to use what)
- Sizing recommendations
- Quota/limit summaries

Always include a header row. Align columns for readability in source.

### Admonitions

Available types and when to use them:
- `!!! info "Prerequisites"` — Top of page, for prerequisite links
- `!!! tip "Title"` — Helpful shortcuts or automation suggestions
- `!!! note "Title"` — Important clarifications that aren't warnings
- `!!! danger "Title"` — Anti-patterns or approaches that cause real harm

Use sparingly. One prerequisites admonition per page is standard. Additional admonitions only where they genuinely interrupt the reading flow with critical information.

### Code Blocks

Use fenced code blocks for:
- IaC examples (CloudFormation YAML, Terraform HCL)
- CLI commands
- Configuration snippets

Always specify the language for syntax highlighting.

### Links

- Internal links use relative paths: `[Page](page.md)` or `[Page](../section/page.md)`
- External links use full URLs: `[Title](https://docs.aws.amazon.com/...)`
- Prefer linking to official AWS documentation over third-party sources
- Use `[:octicons-arrow-right-24: Link text](url)` only inside grid cards

## Content Depth Guidelines

| Page type | Target length | Depth |
| --- | --- | --- |
| Index page | 80-160 lines | Summaries only; no deep content |
| Foundation sub-page | 200-450 lines | Detailed best practices with rationale, diagrams, tables |
| Connectivity sub-page | 400-1000+ lines | Deeply opinionated, multiple services per page, extensive best practices |
| Application Networking sub-page | 400-1000+ lines | Patterns-first, multiple options per pattern, detailed comparison |

## Content Principles

1. **Every recommendation needs rationale.** "Do X" is never sufficient. "Do X because Y happens when you don't, and the cost of Y is Z" is the standard.
2. **State the default choice clearly.** When multiple options exist, name the recommended default and explain when to deviate.
3. **Include "New environments" and "Existing environments" guidance** at the end of long pages to help readers at different stages.
4. **Cross-reference aggressively.** Pages should link to related pages in other sections. A reader on the VPC page should be able to find their way to Transit Gateway, CIDR planning, and subnets without going back to the index.
5. **Use comparison tables for multi-option decisions.** When a reader must choose between 2+ approaches, a table with dimensions (cost, complexity, use case) is more useful than prose.
6. **Don't repeat content across pages.** If a topic is covered in depth on another page, link to it with a one-sentence summary rather than duplicating the explanation. However, include enough inline context (1-2 sentences) that a reader of only that page understands the reference without clicking through.
7. **Include failure modes with every capability.** What breaks when this practice is not followed? What are the common incorrect assumptions? This prevents AI models from hallucinating capabilities and helps human readers avoid pitfalls.
8. **Lead with specifics, not generics.** First sentences of pages and sections should contain the most important, specific, quotable facts — not meta-descriptions of what the section covers. "AWS Cloud WAN manages topology across 30+ Regions through a single policy document" is better than "This section covers AWS Cloud WAN."
9. **Make pages self-contained for single-page consumption.** Each page should provide enough context that a reader (human or AI) who reads only that page can form a complete, accurate understanding of the topic and make informed decisions.
