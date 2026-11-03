# Philosophy

Understanding our project philosophy helps you contribute effectively and ensures your expectations align with our goals. This page outlines the core principles that guide content creation, review decisions, and the overall direction of the AWS Networking Best Practices guide.

## Why This Matters

Whether you're using this guide for your architecture decisions or contributing new content, these principles help you understand:

* What types of content we prioritize

* How we evaluate new contributions

* Why certain approaches are recommended over others

## Design Principles

### Focus on Real-World Use Cases

We prioritize practical scenarios over theoretical possibilities. Content should address common challenges that AWS networking professionals face daily.

**Examples:**

* Multi-account connectivity patterns over single-account demos

* Production-ready security configurations over basic setups

* Cost optimization strategies based on actual usage patterns

### Prioritize Strong Fundamentals

We emphasize proven networking concepts that form the foundation of reliable architectures.

**This means:**

* Understanding fundamentals provides the foundation for evaluating advanced designs and capabilities

* Grasping design principles enables informed decisions across diverse use cases

* Learning troubleshooting methodology builds diagnostic skills that complement technical implementation

### IPv6 as a Core Element

IPv6 isn't optional or future-focused—it's essential for modern AWS networking.

**Our approach:**

* All examples include both IPv4 and IPv6 configurations

* Diagrams show dual-stack implementations by default

* Guidance treats IPv6 adoption as inevitable, not optional

### Architecture Over Procedure and Values

We document design decisions and the reasons behind them, and rely on AWS documentation for what changes frequently or is procedural.

**This means:**

* Capacity and count quotas, limits, and prices are named by dimension (for example, per-tunnel throughput or per-GB data processing) and linked to the current AWS documentation, not stated as numbers. Values a design must be configured to, such as MTU or encapsulation overhead, may be stated with a link to the page that defines them

* Guidance explains what to build, why, and what breaks otherwise; step-by-step console, CLI, and configuration procedures stay in the AWS documentation

* Issues and proposals that ask for concrete values or procedures are welcome as input; reviewers translate them into the design decision underneath

### Technical Precision and Clarity

We write for experienced practitioners who need accurate, actionable information.

**Standards:**

* Technical accuracy verified by AWS networking specialists

* Clear explanations without oversimplification

* Links to authoritative sources rather than duplicating content
