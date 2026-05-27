# Contributing

Welcome to the AWS Networking Best Practices Guide! We're a community-driven project that thrives on contributions from users like you. Whether you want to report an issue, suggest improvements, or share your expertise, we'd love your help in making this guide better for everyone.

## New to contributing?

Here are the most common ways to get started:

!!! tip "Quick Start Guide"

    **Found an error or missing info?** → [Report a correction](report-a-correction.md)

    **Have a networking question?** → [Ask on AWS re:Post](https://repost.aws/questions/ask)

    **Want to suggest a new best practice?** → [Request a new best practice](new-best-practice.md)

    **Ready to contribute content?** → [Create a pull request](making-a-pull-request.md)

Most contributions start with reporting issues or asking questions. Don't worry about getting everything perfect – our community is here to help!

### Creating an issue or contributing

<div class="grid cards" markdown>

*   :material-file-document-remove-outline: &nbsp;

    **Missing information in our docs?**

    ---

    Report missing information or potential inconsistencies in our
    documentation

    ---

    [:octicons-arrow-right-24: Report a correction][report a correction]

*   :material-lightbulb-on-20: &nbsp;

    **Want to submit an idea?**

    ---

    Propose a change, new best practice, or suggest an improvement

    ---

    [:octicons-arrow-right-24: Request a new best practice][new best practice]

*   :material-account-question-outline: &nbsp;

    **Have a question or need help?**

    ---

    Ask a question on our [AWS re:Post Networking & Content Delivery](https://repost.aws/topics/TA-2izgznkTKe0-VdIELPAgg/networking-content-delivery) community

    ---

    [:octicons-arrow-right-24: Ask a question][ask a question]

*   :material-source-pull: &nbsp;

    **Want to create a pull request?**

    ---

    Learn how to create a comprehensive and useful pull request (PR)

    ---

    [:octicons-arrow-right-24: Create a pull request][create a pull request]

</div>

  [report a correction]: report-a-correction.md
  [new best practice]: new-best-practice.md
  [ask a question]: https://repost.aws/questions/ask
  [create a pull request]: making-a-pull-request.md

## Contribution Guidelines

We've streamlined our processes to make contributing as easy as possible. Following these simple guidelines helps us respond to your contributions quickly and effectively.

## Checklist

Before interacting within the project, please take a moment to consider the
following questions. By doing so, you can ensure that you are using the correct
issue template and that you provide all necessary information when interacting
with our community.

## Good vs. Poor Contributions

### ✅ Good Examples

**Documentation Gap**: "The Networking Basics section lacks guidance on CIDR block planning for multi-region deployments. I'd like to contribute a best practices section covering IP address allocation strategies, including examples for small (< 10 VPCs) and large (> 50 VPCs) organizations."

**Content Enhancement**: "The current Connectivity within AWS section covers basic setup but missing advanced routing scenarios. I can add a section on route table design patterns for hub-and-spoke architectures with specific examples and diagrams."

**New Best Practice**: "Based on our experience with AWS Network Firewall in production, I'd like to contribute a section on rule optimization and performance tuning, including cost considerations and monitoring strategies."

### ❌ Poor Examples

**Vague Request**: "Need more info about networking"

**Too Broad**: "Fix all the documentation"

**No Context**: "Add something about security groups"

!!! note "Community Guidelines"
    All contributions are public and permanent. Please be constructive, respectful, and follow our [Code of Conduct](https://aws.github.io/code-of-conduct).

## Before You Contribute

Here's a quick checklist to ensure your contribution is helpful and gets the attention it deserves:

* **Search first**: Check if someone has already reported the same issue or asked a similar question

* **Use the right channel**:

  * Technical questions → [AWS re:Post](https://repost.aws/questions/ask)

  * Bug reports or feature requests → [GitHub Issues](https://github.com/aws/aws-networking-best-practices/issues)

* **Provide context**: Include relevant details like AWS services, regions, or error messages

* **Be respectful**: Follow our [Code of Conduct](https://aws.github.io/code-of-conduct) and keep discussions constructive

!!! info "Remember"
    Complete issue templates help us understand your request faster. Don't worry if you're unsure about something – our community is here to help!

## Rights and responsibilities

As maintainers, we are entrusted with the **responsibility** to moderate

communication within our community, including the authority to close, remove,
reject, or edit issues, discussions, comments, commits, and to block users who
**do not align** with our contribution guidelines and our [Code of Conduct](https://aws.github.io/code-of-conduct).

This role requires us to be actively involved in maintaining the integrity and
positive atmosphere of our community. Upholding these standards decisively
ensures a respectful and inclusive environment for all members.

### Code of Conduct

Our [Code of Conduct](https://aws.github.io/code-of-conduct) outlines the expectation for all community members to
treat one another with respect, employing inclusive and welcoming language. Our
commitment is to foster a positive and supportive environment, free of
inappropriate, offensive, or harmful behavior.

We take any violations seriously and will take appropriate action in response to
uphold these values.[^1]

  [^1]:
    **Warning and blocking policy:**
    Given the increasing popularity of our project and our commitment to a
    healthy community, we've defined clear guidelines on how we proceed with
    violations:

    1.1. **First warning:** Users displaying repeated inappropriate, offensive,

    or harmful behavior will receive a first warning. This warning serves as a
    formal notice that their behavior is not in alignment with our community
    standards and Code of Conduct. The first warning is permanent.

    1.2. **Second warning and opportunity for resolution:** If the behavior

    persists, a second warning will be issued. Upon receiving the second
    warning, the user will be given a 5-day period for reflection, during which
    they are encouraged to publicly explain or apologize for their actions.
    This period is designed to offer an opportunity for openly clearing out any
    misunderstanding.

    1.3. **Blocking:** Should there be no response or improvement in behavior

    following the second warning, we reserve the right to block the user from
    the community and repository. Blocking is considered a last resort, used
    only when absolutely necessary to protect the community's integrity and
    positive atmosphere.

    Blocking has been an exceptionally rare necessity in our overwhelmingly
    positive community, highlighting our preference for constructive dialogue
    and mutual respect. It aims to protect our community members and team.

### Incomplete issues and duplicates

We have invested significant time and effort in the setup of our contribution
process, ensuring that we assess the essential requirements for reviewing and
responding to issues effectively. Each field in our issue templates is
thoughtfully designed to help us fully understand your concerns and the nature
of your matter. We encourage all members to utilize the search function before
submitting new issues or starting discussions to help avoid duplicates. Your
cooperation is crucial in keeping our community's discussions constructive and
organized.

  * **Mandatory completion of issue templates:** We need all of the information

  required in our issue templates because it ensures that every user and
  maintainer, regardless of their experience, can understand the content and
  severity of your bug report or change request.

  * **Closing incomplete issues:**

  We *reserve the right to close issues lacking essential information*, such as
  those not adhering to the quality standards and requirements specified in our
  issue templates. Such issues can be reopened once the missing information has
  been provided.

  * **Handling duplicates:** To maintain organized and efficient

  communication within our [issue tracker], we *reserve the right to close any
  duplicated issues*. Opening multiple channels to ask the same question or report the
  same issue across different forums hinders our ability to manage and address
  community concerns effectively. This approach is vital for efficient time
  management, as duplicated questions can consume the time of multiple team
  members simultaneously. Ensuring that each issue or discussion is unique and
  progresses with new information helps us to maintain focus and support our
  community.

    We further *reserve the right to immediately close issues that
    are reopened without providing new information* or simply because users have

    not yet received a response to their issue/question, as the issue is marked as
    incomplete.

  * **Limitations of automated tools:**  While we believe in the value and

  efficiency that automated tools bring to identifying potential issues (such
  as those identified by Lighthouse, Accessibility tools, and others), simply
  submitting an issue generated by these tools does not constitute a complete
  bug report. These tools sometimes produce verbose outputs and may include
  false positives, which necessitate a critical evaluation. You are of course
  welcome to attach generated reports to your issue. However, this does not
  substitute the requirement for a minimal reproduction or a thorough discussion
  of the findings. *We reserve the right to mark these issues as incomplete and
  close them.* This practice ensures that we are addressing genuine concerns

  with precision and clarity, rather than navigating through extensive automated
  outputs.
