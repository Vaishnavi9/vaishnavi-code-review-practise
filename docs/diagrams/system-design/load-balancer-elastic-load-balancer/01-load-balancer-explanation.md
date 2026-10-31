# Load balancer: the first idea

Picture a supermarket with several checkout counters. A helper directs each arriving shopper to an open counter. That helper is the load balancer; each counter is a running copy of your application. One request normally goes to one selected copy, not to all copies.

The copies run the same application but have separate memory. Payment correctness still requires shared durable records, database constraints and idempotency. A load balancer does not prevent duplicate charges by itself.

## What AWS provides

Elastic Load Balancing (ELB) is the AWS service family. An Application Load Balancer (ALB) is its HTTP/HTTPS option. A listener receives traffic on a configured protocol and port. Listener rules choose a target group, which describes the registered destinations. The group is not an extra application server.

AWS adjusts load-balancer capacity with traffic. Adding or removing application instances is a separate scaling mechanism. Neither action automatically increases database capacity or a payment provider's quota.

Health checks help determine target eligibility. An important ALB exception: when all registered targets in a group are unhealthy, it can fail open and route to those targets. Health checks are not proof that a whole payment is correct.

## Where configuration belongs

These are proposed locations, not deployed configuration:

| File | Responsibility |
|---|---|
| `infra/kubernetes/deployment.yaml` | Describes the application Pods and containers. |
| `infra/kubernetes/service.yaml` | Selects application Pods using labels and defines service ports. |
| `infra/kubernetes/ingress.yaml` | References the Service and describes incoming HTTP routing. |
| `src/main/resources/application.properties` | Spring application settings, such as its listening port and graceful shutdown. |

For a cluster using the AWS Load Balancer Controller, deployment tooling applies the Kubernetes manifests. The installed controller watches the resources and configures AWS load-balancer resources, with suitable IAM permissions and networking. Spring does not read the Kubernetes manifests.

Configuration references: **Ingress → Service → selected Pods**.

Request flow with ALB IP targets: **Client → ALB → selected Pod**. The Service describes the selection; it is not necessarily another network hop. Instance-target mode routes through a node instead.

EKS means Elastic Kubernetes Service. ELK refers to a logging stack; it does not mean EKS or ELB. A Pod contains one or more containers.

## One check before moving on

If all application instances share one overloaded database, will adding more instances necessarily make payments faster? Explain what remains the bottleneck.

## Sources and status

Original teaching diagram. No cloud resources or application configuration were changed. Proposed file locations have not been created or deployed.

- [AWS: Application Load Balancer concepts](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [AWS: target health checks and fail-open behavior](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html)
- [AWS: application scaling and load balancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html)
- [AWS: ALB routing on EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
- [Spring Boot: graceful shutdown](https://docs.spring.io/spring-boot/3.5/reference/web/graceful-shutdown.html)
