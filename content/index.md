# Introduction

**A reference architecture for AWS networking best practices**

Enterprise AWS networks are built on five interconnected pillars:

- **Foundation** - Core infrastructure (AWS Organizations, VPCs, subnets, IPAM) that everything else depends on
- **Connectivity** - Communication through internet gateways, Transit Gateway, Direct Connect, and VPN services
- **Application Networking** - Traffic distribution via Elastic Load Balancing, service-to-service communication through VPC Lattice, and container networking
- **Security** - Protection through Network Firewall, PrivateLink, and Verified Access
- **Observability** - Monitoring and troubleshooting capabilities

``` mermaid
block-beta
  columns 6

  %% 1. Left Sidebar (Takes 1 of 6 columns)
  block:Left:1
    columns 1
    Security
  end

  %% 2. Center Stack (Takes 4 of 6 columns)
  block:Center:4
    columns 1

    %% --- Application Networking ---
    block:AppNet
      columns 1
      AppNetLabel["Application Networking"]
      block:AppItems
        columns 3
        LB["Load Balancing"]
        S2S["Service to Service"]
        CM["Container Mesh"]
      end
    end

    %% --- Connectivity ---
    block:Conn
      columns 1
      ConnLabel["Connectivity"]
      block:ConnItems
        columns 3
        Internet
        AWS["Within AWS"]
        Hybrid["Hybrid & Multi-Cloud"]
      end
    end

    %% --- Foundation ---
    Foundation
  end

  %% 3. Right Sidebar (Takes 1 of 6 columns)
  block:Right:1
    columns 1
    Observability
  end

  %% --- STYLING ---

  %% 1. FONT SIZING
  classDef largeText font-size:24px;
  class Security,Foundation,Observability,AppNetLabel,ConnLabel largeText

  %% 2. LAYOUT CONTAINERS
  classDef layout fill:none,stroke:none;
  class Left,Center,Right,AppItems,ConnItems layout

  %% 3. LABELS
  classDef label fill:none,stroke:none,color:#fff;
  class AppNetLabel,ConnLabel label

  %% 4. VISIBLE CONTENT BLOCKS - Consistent color scheme
  classDef mainBox fill:#2563eb,stroke:#1e40af,stroke-width:2px,color:#fff;
  class AppNet,Conn,Foundation,Security,Observability mainBox

  %% 5. INNER ITEMS
  classDef dashed stroke:#64748b,stroke-dasharray:5 5,fill:#f1f5f9,color:#0f172a;
  class LB,S2S,CM,Internet,AWS,Hybrid dashed

  %% 6. HEIGHT ADJUSTMENT
  style Security height:377px
  style Observability height:377px
```

## Architecture Overview

Start with Foundation to understand the basics, then explore each pillar based on your specific networking requirements.

<div class="grid cards" markdown>

*   :material-network: **Foundation**

    ---

    Essential AWS networking concepts including VPCs, subnets, routing, and
    core infrastructure components.

    ---

    [:octicons-arrow-right-24: Foundation](foundation/)

*   :material-lan-connect: **Connectivity**

    ---

    Internet access, connectivity within AWS, and hybrid & multi-cloud
    networking solutions.

    ---

    [:octicons-arrow-right-24: Connectivity](connectivity/)

*   :material-application: **Application Networking**

    ---

    Load balancing, service-to-service communication, and container mesh
    networking for modern applications.

    ---

    [:octicons-arrow-right-24: Application Networking](application-networking/)

*   :material-lock-outline: **Security**

    ---

    Secure your AWS network with defense-in-depth strategies, access controls,
    and threat protection.

    ---

    [:octicons-arrow-right-24: Security](security/)

*   :material-monitor-eye: **Observability**

    ---

    Monitor network performance, troubleshoot connectivity issues, and gain
    visibility into your AWS network.

    ---

    [:octicons-arrow-right-24: Observability](observability/)

</div>

## Contribute

Help improve this guide by [reporting issues](community/report-a-correction.md),
[suggesting new best practices](community/new-best-practice.md), or
[contributing content](community/making-a-pull-request.md). Join our
community-driven effort to create comprehensive AWS networking resources for
everyone.
