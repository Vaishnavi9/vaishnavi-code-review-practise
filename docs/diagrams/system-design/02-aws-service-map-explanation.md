# Payment platform: AWS mapping

Proposed learning design · 31 October 2026. This is a technology-placement map, not a deployment inventory or a claim about another organization's architecture. No cloud resources are created by this document.

Read [the business-service map](01-business-service-map.md) first. Numbers below match its twelve responsibilities.

## Where technology fits

Arrows mean “uses” or “stores in”, as labelled. They do not show execution order. EKS hosts our Java applications; it does not implement payment business rules.

[Open the diagram](02-aws-service-map.md)


The relay represents the hand-off responsibility; each store owner should own its outbox and relay access. A single broadly privileged relay is not required. The arrows from consumers to Kinesis mean “reads from”, not the direction in which an event travels.

## All twelve blocks mapped

| Business block | Custom code | Candidate AWS support | Boundary / trade-off |
|---|---|---|---|
| 1 · Merchant management | Registration and status rules | EKS + DynamoDB | A database does not decide merchant eligibility. PostgreSQL is a simpler alternative for relational needs. |
| 2 · Authentication / authorization | Credential validation and merchant/resource permissions | EKS; Secrets Manager where secrets are needed | AWS IAM controls access to AWS resources, not merchant business permissions. A managed identity provider is a separate optional decision. |
| 3 · Method catalogue | Versioned capabilities and eligibility checks | EKS + DynamoDB | Cache only with a defined freshness/revocation policy. Currency metadata need not be its own service. |
| 4 · Orchestration | Idempotency, state machine, command coordination | EKS + DynamoDB conditional writes / transactions | Payment state and local outbox must commit atomically. More pods do not replace database invariants. |
| 5 · Risk and fraud | Applicable rules and decisions | EKS; storage chosen for access patterns | No fraud product is assumed. Start with explicit rules; external risk integrations are optional. |
| 6 · Provider integration | Provider adapters, timeout and retry decisions | EKS + Secrets Manager | Preserve the provider instruction identity. An unknown outcome must not trigger a blind resubmission. |
| 7 · Incoming outcomes | Callback authentication, deduplication and transition validation | EKS + DynamoDB | Durably accept before acknowledgement; reject stale or invalid transitions. |
| 8 · Merchant notifications | Signed HTTPS webhooks and retry policy | EKS + optional SQS / dead-letter queue | SQS supports work delivery; it does not implement the merchant webhook protocol. Duplicate delivery remains possible. |
| 9 · Financial ledger | Balanced entries and unique posting identities | EKS + RDS PostgreSQL | Proposed relational choice for local financial invariants; no atomic transaction spans this store and DynamoDB. |
| 10 · Settlement / cashflow | Expected, received, reserved and available balances | EKS + financial PostgreSQL store | Avoid one global balance and cross-currency summation. Availability depends on confirmed evidence and reservations. |
| 11 · Reconciliation | Statement matching, differences and cases | EKS workers + PostgreSQL + S3 | Retain source evidence; apply imports idempotently. A missing record can be delayed, not necessarily failed. |
| 12 · Payout management | Atomic reservation, instruction and outcome tracking | EKS + financial PostgreSQL store | External banking API performs the transfer. Keep the reservation and local payout intent in one transaction. |

## Shared supporting tools

| Responsibility | Candidate | What it does here |
|---|---|---|
| Hosting | EKS | Runs and manages containerized applications; a local process or simpler container host is enough for the first lesson. |
| Entry routing | Application Load Balancer | Routes HTTPS traffic to healthy application targets. It is not merchant authorization. |
| Gateway policy | Optional API gateway / application middleware | Admission, request-size limits, authentication integration and routing. Do not add both a gateway and extra proxies without a requirement. |
| Workload permissions | IAM with scoped workload roles | Limits which AWS operations each application may perform. No root or long-lived embedded access keys. |
| Secrets / encryption | Secrets Manager and KMS | Protect credentials and encryption keys; they do not repair authorization bugs. |
| Event history | Kinesis Data Streams | Lets independent consumers process retained events. Consumers need stable event IDs, idempotency and checkpoint rules. |
| Work delivery | SQS | Queues independent retryable work. It is a different abstraction from a retained stream. |
| Search | OpenSearch | Derived search/operations view; never the authority for payouts or available balances. |
| Observability | CloudWatch; optional Datadog | Logs, metrics, traces and alerts. Datadog is a separate product. Redact credentials and sensitive data. |
| Provisioning | Terraform | Describes and changes infrastructure. It is outside the payment request flow and is not an AWS service. |

## Correctness before scaling

1. This mixed-store example is optional. Starting with one PostgreSQL database and modules is a simpler learning baseline. Add DynamoDB only when its access and scaling model serves a requirement.
2. Commit local business state and its outbox in the same store's transaction. Publishing to Kinesis is a later step. Retrying publication may duplicate an event.
3. A ledger consumer applies its posting and deduplication marker atomically in its own store. An outbox does not make external bank/provider effects exactly once.
4. Reserve funds atomically before authorizing a payout. A lagging search document or event projection cannot approve spending.
5. More EKS pods do not increase provider quotas or database connection capacity. Bound concurrency and watch latency, throttles, queue age, consumer lag and rejected work.
6. The diagram omits networking, deployment and recovery details on purpose. It is not a production-ready infrastructure plan.

## Official product references

These sources describe the tools, not the proposed business architecture.

- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [DynamoDB transactions](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/transactions.html)
- [RDS for PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [Kinesis Data Streams](https://docs.aws.amazon.com/streams/latest/dev/introduction.html)
- [Amazon SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)
- [Amazon OpenSearch Service](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/what-is.html)
- [Terraform](https://developer.hashicorp.com/terraform/intro)

Verification: documentation references inspected during preparation; mapping is proposed. No application execution, cloud deployment or learner understanding is claimed.
