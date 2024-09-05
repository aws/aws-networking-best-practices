# Propose as new best practice

This AWS Networking Architecture guidance is a powerful resource and tool for
designing and planning your AWS-based network. With a very higher number of 
users, we understand that our project serves a wide range of users cases, which
is why we have created the following guide.

---

Put yourself in our shoes – with a project of this size, it can be challenging
to maintain existing guidance while constantly adding new best practices at the
same time. We highly value every idea or contribution from our community, and
we kindly ask you to take the time to read the following guidelines before
submitting your new best practice proposal in our public [issue tracker]. This will help us
better understand the proposed change and how it will benefit our community.

This guide is our best effort to explain the criteria and reasoning behind our
decisions when evaluating new best practice proposals and considering them for
implementation.

  [issue tracker]: https://github.com/aws/aws-networking-best-practices/issues

## Before creating an issue

Before you invest your time to fill out and submit a new best practice proposal, we kindly
ask you to do some preliminary work by answering some questions to determine if
your idea is a good fit for the AWS Networking Architecture guide and matches
the project's [philosophy] and tone.

__Please do the following things before creating an issue.__

  [philosophy]: philosophy.md

### It's not a bug, it's a feature

Proposals of new best practices are intended to suggest minor adjustments, ideas
for new best practice guides, or to kindly influence the project's direction and
vision. It is important to note that these proposals are not intended for reporting
corrections or bugs, as they're missing essential information for debugging.

If you want to report a bug, please refer to our [reporting a correction guide] instead.

  [bug reporting guide]: report-a-correction.md

### Look for sources of inspiration

If you have seen your best practice idea documented in another public website,
please reference it, as this allows us to evaluate potential fit more quickly. Explain
what you like and dislike about this existing best practices documentation.

### Connect with our community

Our [AWS re:Post Networking & Content Delivery community] is the best place to connect
with our community. When evaluating new ideas, it's essential to seek input from other
users and consider alternative viewpoints. This approach helps to implement new best 
practices guides in a way that benefits a large number of users.

[:octicons-comment-discussion-16:&nbsp; Join the discussion][AWS re:Post Networking & Content Delivery community]{ .md-button .md-button--primary }

  [AWS re:Post Networking & Content Delivery community]: https://repost.aws/topics/TA-2izgznkTKe0-VdIELPAgg/networking-content-delivery

## Issue template

Now that you have taken the time to do the necessary preliminary work and ensure
that your idea meets our requirements, you are invited to create a proposal for a
new best practice. The following guide will walk you through all the necessary steps to
help you submit a comprehensive and useful issue:

- [Title]
- [Context] <small>optional</small>
- [Description]
- [Related links]
- [Use cases]
- [Visuals] <small>optional</small>
- [Checklist]

  [Title]: #title
  [Context]: #context
  [Description]: #description
  [Related links]: #related-links
  [Use cases]: #use-cases
  [Visuals]: #visuals
  [Checklist]: #checklist

### Title

A good title is short and descriptive. It should be a one-sentence executive
summary of the idea, so the potential impact and benefit for our community can
be inferred from the title.

| <!-- --> | Example  |
| -------- | -------- |
| :material-check:{ style="color: #4DB6AC" } __Clear__ | SD-WAN integration with TGW
| :material-close:{ style="color: #EF5350" } __Wordy__ | Add a feature where you describe how to integrate various SD-WAN options with a Transit Gateway
| :material-close:{ style="color: #EF5350" } __Unclear__ | Improve TGW
| :material-close:{ style="color: #EF5350" } __Useless__ | Help

### Context <small>optional</small> { #context }

Before describing your idea, you can provide additional context for us to
understand what you are trying to achieve. Explain the circumstances
in which you're using the proposed best practice, and what you _think_ might be
relevant. Don't write about the actual best practice here.

> __Why this might be helpful__: some ideas might only benefit specific
> customers, environments, or edge cases, for example, when your network
> contains thousands of VPCs. With a little context, best practice guides
> can be prioritized more accurately.

### Description

Next, provide a detailed and clear description of your idea. Explain why your
idea is relevant to the AWS Networking Architecture guide and should be added 
here and not in another AWS documentation or blog post.

-   __Explain the <u>what</u>, not the <u>why</u>__ – don't explain
    [the benefits of your idea][Use cases] here, we're getting there.
    Focus on describing the proposed solution as precisely as possible.

-   __Keep it short and concise__ – be brief and to the point when describing
    your idea, there is no need to over-describe it. Maintainers and future
    users will be grateful for having to read less.

-   __One idea at a time__ – if you have multiple ideas that don't belong
    together, please open separate new best practice proposals for each of those ideas.

---

> __Why we need this__: To understand and evaluate your proposed change, we
> need to have a clear understanding of your idea. By providing a detailed and
> precise description, you can help save you and us time spent discussing
> further clarification of your idea in the comments.

### Related links

Please provide any relevant links to issues, discussions, or documentation
sections related to your new best practice proposal. If you (or someone else) already
discussed this idea with our community on our discussion board, please include
the link to the discussion as well.

> __Why we need this__: Related links help us gain a comprehensive
> understanding of your new best practice proposal by providing additional context.
> Additionally, linking to previous issues and discussions allows us
> to quickly evaluate the feedback and input already provided by our community.

### Use cases

Explain how your new best practice proposal would work from user's
perspective – what's the expected impact, and why does it not only benefit you,
but other users? How many of them? Furthermore, would it potentially break
any other best practice?

> __Why we need this__: Understanding the use cases and benefits of an idea is
> crucial in evaluating its potential impact and usefulness for the project and
> its users. This information helps us to understand the expected value of the
> idea and how it aligns with the goals of the project.

### Visuals <small>optional</small> { #visuals }

We now have a clear and detailed description of your idea, including information
on its potential use cases and relevant links for context. If you have any
visuals, such as sketches, screenshots, mockups, or external assets, you may
present them in this section.

__You can drag and drop the files here or include links to external assets.__

Additionally, if you have seen this change, feature, or improvement used in
other public websites, please provide an example by showcasing
it and describing how it was implemented and incorporated.

> __Why this might be helpful__: Illustrations and visuals can help us
> maintainers better understand and envision your idea. Sketches,
> or diagrams can create an additional level of detail and clarity that text
> alone may not be able to convey. Also, seeing how your idea has been
> documented in other public websites can help us understand its potential impact and
> feasibility, which helps us maintainers evaluate and
> triage new best practice proposals.

### Checklist

Thanks for following the guide and creating a high-quality new best practice proposal – you
are almost done. The checklist ensures that you have read this guide and have
worked to your best knowledge to provide us with every piece of information to
review your idea.

__We'll take it from here.__

---

## Rejected requests

__Your new best practice proposal got rejected? We're sorry for that.__ We understand it can
be frustrating when your ideas don't get accepted, but as the maintainers of a
very popular project, we always need to consider the needs of our entire
community, sometimes forcing us to make tough decisions.

We always have to consider and balance many factors when evaluating change
requests, and we explain the reasoning behind our decisions whenever we can.
If you're unsure why your new best practice proposal was rejected, please don't hesitate
to ask for clarification.

The following principles (in no particular order) form the basis for our
decisions:

- [ ] Alignment with vision and tone of the project
- [ ] Effort of implementation and maintenance
- [ ] Usefulness to the majority of users
- [ ] Simplicity and ease of use
- [ ] Accessibility
