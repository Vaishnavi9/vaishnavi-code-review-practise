# Backend and database learning guide

Proposed study order · 31 October 2026. These are selected preparation topics for our synthetic payment system, not a verified interview question list or a guarantee of interview success. Complexity depends on the requirements; the order introduces prerequisites before harder combinations.

[Open the large black-and-white learning diagram](04-backend-learning-map.svg) · [Diagram-only Markdown](04-backend-learning-map.md) · [Business-block responsibilities](03-block-responsibilities.md)

Start with one payment request. Revisit the same request under duplicate delivery, concurrency, failure and load. Deployment stays at the end. The roadmap is an index; none of these topics is marked independently demonstrated by creating or reading it.

## Topic index

| Order | Concept | What we will understand | Where it belongs |
|---|---|---|---|
| 01 | Actors, system boundary and business rules | Identify who calls us, what we own and the rule that must stay true. | All blocks |
| 02 | HTTP requests, responses and payment milestones | Trace one request; distinguish validation, acceptance and completed payment. | Merchant backend; 2, 4 |
| 03 | Load balancers and health checks | Understand how a request reaches a healthy application instance. | Entry point before applications |
| 04 | API gateway, authentication and authorization | Separate routing and admission from identity, merchant status and permissions. | Entry point; 1, 2 |
| 05 | Controller, service, repository and dependency injection | Follow one request through Spring; distinguish business logic from storage access. | 4 and its persistence adapter |
| 06 | Entities, SQL types, money and identifiers | Map fields to columns; use explicit currency, amount units and operation identities. | 4, 9, 10 |
| 07 | Keys, constraints, relationships and normalization | Make invalid records rejectable; preserve merchant scope and historical meaning. | 1, 3, 4, 9 |
| 08 | Queries, joins, indexes and pagination | Bound results and inspect query plans; avoid duplicated joined rows and unstable pages. | Catalogue; payment and ledger reads |
| 09 | EntityManager, JDBC, flush, commit and rollback | Trace pending changes into SQL. Flush is not commit; rollback scope is local. | Repository and database path |
| 10 | Spring transactions, proxies and rollback rules | Choose the business transaction boundary and explain interception and failure rules. | 4, 9, 10, 12 |
| 11 | Thread safety: shared state, atomicity and visibility | Trace a lost update in a singleton; a local lock cannot coordinate different instances. | Shared state in any Java block |
| 12 | Executors, connection pools and bounded work | Bound concurrent work, queue size and waiting; more threads do not create database capacity. | 4, 6, 7, 8 and database clients |
| 13 | Snapshots, MVCC and isolation levels | Explain what two transactions can see and which anomalies remain possible. | 4, 9, 10 |
| 14 | Conditional updates, versions and row locks | Prevent two requests from both spending the same available amount. | 10, 12; refund handling in 4 |
| 15 | Deadlocks, lock ordering and transaction retries | Recognize conflicting lock orders and retry an eligible failed transaction safely. | Concurrent financial operations |
| 16 | Idempotency and repeated customer requests | Atomically claim a merchant-scoped operation and handle payload conflicts and lost responses. | 2, 4; durable request identity |
| 17 | Payment state machines and unknown outcomes | Allow valid transitions only; a provider timeout can leave the outcome unknown. | 4, 6, 7 |
| 18 | Synchronous calls, queues and retained streams | Compare direct calls, SQS work delivery and Kinesis or Kafka event consumption. | Handoffs between business blocks |
| 19 | Transactional outbox and the dual-write failure | Commit local state with its outgoing event; later publication may be duplicated. | 4 to 8 / 9; store-owned relay |
| 20 | Webhooks, inbox, acknowledgement and event ordering | Verify and durably receive updates; deduplicate effects and reject stale versions. | 7, 8, 9 and projection consumers |
| 21 | Ledger entries and accounting invariants | Separate payment status from balanced financial records and unique postings. | 9 |
| 22 | Cashflow, liquidity and atomic reservations | Separate expected, received, reserved and available funds; prevent excess refunds or payouts. | 9, 10, 12 |
| 23 | Provider identity, retry budgets and failure isolation | Use stable provider identities, bounded retries, backpressure, circuit breakers and dead-letter handling. | 6, 7, 8, 12 |
| 24 | Reconciliation and settlement evidence | Match records against independent reports; investigate missing or conflicting evidence. | 9, 10, 11; external partners |
| 25 | Capacity, latency objectives and load tests | Separate payments, requests, attempts and events; include arrivals while a backlog drains. | All request and worker paths |
| 26 | Caching, read replicas and stale information | Choose acceptable freshness; do not approve spending from a lagging view. | 3; status reads; 10 |
| 27 | Partitioning, sharding and consistent hashing | Compare data placement and hot keys; placement does not guarantee financial correctness. | Authoritative stores and event partitions |
| 28 | Logs, metrics, traces, audit and alerts | Connect a customer symptom to evidence; protect sensitive data and keep audit separate. | All blocks |
| 29 | Cross-service consistency and compensation | Reason about partial success across stores; compensation is a new business action, not a global rollback. | 4, 9, 10, 12 |
| 30 | Backups, restore, schema changes and recovery objectives | Distinguish replication from recoverable backups and validate restore and migration plans. | Durable stores and financial history |
| 31 | Containers, pods, Kubernetes and EKS | Place the application in a container and containers in a pod; map hosting separately from business rules. | Deployment of application modules |
| 32 | Scaling, safe releases and graceful shutdown | Coordinate instance count, capacity, health checks, draining and rollback-compatible changes. | Deployment and runtime lifecycle |

## How each lesson works

For each topic: state the customer need and the rule that must remain true; draw one small conceptual diagram; predict what happens; trace one concrete example; introduce one failure; explain a correction, an alternative and evidence that could disprove the claim. Implementation comes when we deliberately start a hands-on exercise.

Use explicit progress states: introduced, practised with help, independently implemented, independently explained, or needs practice. A generated diagram or a passing copied test is not independent understanding.

## First walkthrough

Review 01–02 briefly, then start **03: load balancer**. Follow one merchant request to one healthy application instance. Keep the API gateway as the next, separate lesson. Do not explain all 32 topics in one sitting.

## Correctness checkpoints we must return to

- **Repeated requests:** one logical operation can produce many network attempts. The business effect must obey the defined identity and deduplication policy.
- **Concurrent requests:** two individually valid actions may violate a shared invariant when executed together. Use database guarantees that span every application instance.
- **Unknown outcomes:** a timeout does not prove that a provider failed to act. Preserve the original operation identity and recover evidence.
- **Financial positions:** acceptance, authorization, capture, settled funds and payout are different. Keep currency and reservations explicit.
- **Bounded capacity:** retries and continuing arrivals consume capacity. More threads or application copies cannot remove a provider quota or database bottleneck.

## Technical reference anchors

These support mechanisms; the roadmap order and the mapping to our business blocks are original teaching choices. Detailed lessons should verify additional claims against the exact library or service version used.

- [PostgreSQL transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html): topics 13–15; snapshots, anomalies and retry reasoning.
- [Spring Framework 6.2 transaction annotations](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/annotations.html): topic 10; proxy-based boundaries and annotation semantics for the project's Spring generation.
- [Java 25 memory model and synchronization](https://docs.oracle.com/javase/specs/jls/se25/html/jls-17.html): topic 11; shared state, visibility and ordering.
- [AWS transactional outbox guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html): topics 19–20; local atomicity, publication failures and duplicate handling.
- [Kubernetes pods](https://kubernetes.io/docs/concepts/workloads/pods/): topic 31; a pod contains one or more containers, not the other way around.

No application code, database records, deployment settings or AWS resources are changed by this learning map.
