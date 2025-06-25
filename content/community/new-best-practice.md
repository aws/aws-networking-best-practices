# Propose a New Best Practice

Have an idea for improving AWS networking guidance? We'd love to hear it! This page walks you through proposing new best practices that benefit the entire community.

## Quick Overview

Before submitting your proposal:

1. **Check if it's really a new best practice** (not a [bug report])

2. **Research existing solutions** and reference them

3. **Discuss with the community** on AWS re:Post

4. **Submit a detailed proposal** using our template

Ready to get started? Continue reading for the complete process.

  [bug report]: report-a-correction.md

## What Makes a Good Proposal

### Is This Really a New Best Practice?

New best practices should add significant value to the community. Ask yourself:

* Does this solve a common networking challenge?

* Would this benefit multiple organizations, not just yours?

* Is this networking-specific guidance (not general AWS advice)?

**Not sure?** If you're reporting an error or inconsistency, use our [correction report](report-a-correction.md) instead.

### Do Your Research

* Search for existing solutions in AWS documentation, blogs, and forums

* Reference any existing guidance and explain how your proposal improves it

* Check our [community discussions](https://repost.aws/topics/TA-2izgznkTKe0-VdIELPAgg/networking-content-delivery) for related topics

[:octicons-comment-discussion-16:&nbsp; Join the discussion][AWS re:Post Networking & Content Delivery community]{ .md-button .md-button--primary }

  [AWS re:Post Networking & Content Delivery community]: https://repost.aws/topics/TA-2izgznkTKe0-VdIELPAgg/networking-content-delivery

## Issue template

Ready to submit your proposal? Use [this template](https://github.com/aws/aws-networking-best-practices/issues/new?template=new-best-practice.md) to ensure you include all the necessary information:

* Title
* Context <small>optional</small>
* Description
* Related links
* Use cases
* Visuals <small>optional</small>

### Title

A good title is short and descriptive. It should be a one-sentence executive
summary of the idea, so the potential impact and benefit for our community can
be inferred from the title.

| <!-- --> | Example  |
| -------- | -------- |
| :material-check:{ style="color: #4DB6AC" } **Clear** | SD-WAN integration with TGW |
| :material-close:{ style="color: #EF5350" } **Wordy** | Add a feature where you describe how to integrate various SD-WAN options with a Transit Gateway |
| :material-close:{ style="color: #EF5350" } **Unclear** | Improve TGW |
| :material-close:{ style="color: #EF5350" } **Useless** | Help |

### Context <small>optional</small> { #context }

Before describing your idea, you can provide additional context for us to
understand what you are trying to achieve. Explain the circumstances
in which you're using the proposed best practice, and what you _think_ might be
relevant. Don't write about the actual best practice here.

> **Why this might be helpful**: some ideas might only benefit specific
> customers, environments, or edge cases, for example, when your network
> contains thousands of VPCs. With a little context, best practice guides
> can be prioritized more accurately.

### Description

Next, provide a detailed and clear description of your idea. Explain why your
idea is relevant to the AWS Networking Architecture guide and should be added
here and not in another AWS documentation or blog post.

*   **Explain the <u>what</u>, not the <u>why</u>** – don't explain

    the benefits of your idea here, we're getting there.
    Focus on describing the proposed solution as precisely as possible.

*   **Keep it short and concise** – be brief and to the point when describing

    your idea, there is no need to over-describe it. Maintainers and future
    users will be grateful for having to read less.

*   **One idea at a time** – if you have multiple ideas that don't belong

    together, please open separate new best practice proposals for each of those ideas.

---

> **Why we need this**: To understand and evaluate your proposed change, we
> need to have a clear understanding of your idea. By providing a detailed and
> precise description, you can help save you and us time spent discussing
> further clarification of your idea in the comments.

### Related links

Please provide any relevant links to issues, discussions, or documentation
sections related to your new best practice proposal. If you (or someone else) already
discussed this idea with our community on our discussion board, please include
the link to the discussion as well.

> **Why we need this**: Related links help us gain a comprehensive
> understanding of your new best practice proposal by providing additional context.
> Additionally, linking to previous issues and discussions allows us
> to quickly evaluate the feedback and input already provided by our community.

### Use cases

Explain how your new best practice proposal would work from user's
perspective – what's the expected impact, and why does it not only benefit you,
but other users? How many of them? Furthermore, would it potentially break
any other best practice?

> **Why we need this**: Understanding the use cases and benefits of an idea is
> crucial in evaluating its potential impact and usefulness for the project and
> its users. This information helps us to understand the expected value of the
> idea and how it aligns with the goals of the project.

### Visuals <small>optional</small> { #visuals }

We now have a clear and detailed description of your idea, including information
on its potential use cases and relevant links for context. If you have any
visuals, such as sketches, screenshots, mockups, or external assets, you may
present them in this section.

**You can drag and drop the files here or include links to external assets.**

Additionally, if you have seen this change, feature, or improvement used in
other public websites, please provide an example by showcasing
it and describing how it was implemented and incorporated.

> **Why this might be helpful**: Illustrations and visuals can help us
> maintainers better understand and envision your idea. Sketches,
> or diagrams can create an additional level of detail and clarity that text
> alone may not be able to convey. Also, seeing how your idea has been
> documented in other public websites can help us understand its potential impact and
> feasibility, which helps us maintainers evaluate and
> triage new best practice proposals.

**We'll take it from here.**

---

## After You Submit

Once you've submitted your proposal:

* **Be patient** - Review takes time as we consider community impact

* **Engage in discussion** - Respond to questions and feedback

* **Be open to changes** - Your idea might evolve through community input

* **Stay involved** - Consider helping implement approved proposals

## If Your Proposal is Rejected

We understand rejection can be disappointing. We evaluate proposals based on:

* Community benefit and broad applicability

* Alignment with project goals

* Implementation and maintenance effort

* Clarity and completeness
