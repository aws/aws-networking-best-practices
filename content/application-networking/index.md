# Application Networking

This section covers how application traffic is distributed, how services discover and communicate with each other, and how container workloads manage service-to-service connectivity. Application networking operates on top of the connectivity layer and uses the foundational infrastructure (VPCs, subnets, IP addressing) underneath.

The application networking services covered here handle the concerns that sit between "my VPCs can route to each other" and "my application code makes a call": load distribution, service discovery, authentication, traffic management, and observability for service-to-service communication.

## 1. Load Balancing

**Elastic Load Balancing** distributes traffic across multiple targets so that applications stay available, scale horizontally, and absorb the failure of any individual target. AWS offers three managed load balancers, and they are not interchangeable: each is built for a different traffic class and a different role in the architecture.

**Key services:**

*   **Application Load Balancer (ALB)** — L7 load balancing for HTTP, HTTPS, and gRPC with content-based routing, TLS termination, mutual TLS, and AWS WAF integration
*   **Network Load Balancer (NLB)** — L4 load balancing for TCP, UDP, TLS, and QUIC with ultra-high throughput, client IP preservation, and static IPs per Availability Zone
*   **Gateway Load Balancer (GWLB)** — Transparent insertion of third-party network appliances (firewalls, IDS/IPS) into the data path; structurally different from ALB and NLB

***Key insight:*** *ALB and NLB distribute application traffic to targets. GWLB does something fundamentally different: it transparently inserts a fleet of third-party appliances into the data path. Treating GWLB as a peer of ALB or NLB is the most common source of confusion.*

## 2. Service to Service

**Service-to-service communication** is the connective tissue of any non-trivial application. The interesting questions are rarely "ALB or NLB?" — they're "how do consumers find providers?", "how do services authenticate each other?", "what happens when a target fails?", and "how do I deploy a new version safely?"

**Key patterns:**

*   **Service discovery** — Route 53 private hosted zones, AWS Cloud Map, and Amazon VPC Lattice DNS
*   **Authentication and authorization** — Amazon VPC Lattice auth policies with SigV4, security groups, and mutual TLS
*   **Traffic management** — Amazon VPC Lattice weighted routing, ALB weighted target groups, and Route 53 weighted records
*   **Cross-VPC and cross-account access** — Amazon VPC Lattice service networks, AWS PrivateLink endpoint services, and internal load balancers over existing connectivity
*   **Asynchronous patterns** — Amazon EventBridge and AWS Step Functions with direct connections to private APIs

***Key insight:*** *Each pattern can be assembled from individual building blocks (Route 53, PrivateLink, ALB, IAM) where the team owns the integration, or covered through Amazon VPC Lattice, which folds discovery, authentication, cross-VPC reach, traffic management, and observability into a single managed layer.*

## 3. Container Mesh

**Container mesh** covers how containerized workloads handle service-to-service communication, from in-cluster primitives through cross-cluster connectivity to full service mesh deployments. The key question is: which specific capabilities do you need, and where should each one live?

**Key patterns:**

*   **In-cluster container networking** — Amazon VPC CNI, Pod Identity, security groups for pods, ECS service connect, and awsvpc network mode
*   **Amazon VPC Lattice as the alternative to a mesh** — Cross-cluster, cross-VPC, cross-account service communication through the AWS Gateway API Controller without a mesh control plane
*   **Self-managed service mesh** — Running Istio, Cilium, or Linkerd on top of Amazon VPC Lattice or traditional AWS connectivity when sidecar-mesh features are genuinely required

***Key insight:*** *Most of the capabilities people adopt a service mesh for are already covered natively by AWS-managed services. Adopt a self-managed mesh only when a specific sidecar-mesh feature (mesh-managed mTLS lifecycle, mesh CRDs, per-request resilience policies) is the genuine requirement.*

---

## Explore Application Networking Topics

<div class="grid cards" markdown>

*   :material-scale-balance: **Load Balancing**

    ---

    ALB, NLB, and GWLB: when to use each, best practices, health checks, Availability Zone resilience, and how to combine them.

    [:octicons-arrow-right-24: Load Balancing](load-balancing.md)

*   :material-swap-horizontal: **Service to Service**

    ---

    Service discovery, authentication, traffic management, observability, cross-VPC access, and async patterns.

    [:octicons-arrow-right-24: Service to Service](service-to-service.md)

*   :material-hexagon-multiple: **Container Mesh**

    ---

    In-cluster networking, Amazon VPC Lattice for containers, and self-managed mesh on AWS.

    [:octicons-arrow-right-24: Container Mesh](container-mesh.md)

</div>
