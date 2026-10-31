# Production database problems — beginner atlas

41 scenarios across 13 categories. Each has a plain-language analogy, failure sequence, corrected sequence, before/after snippets, trade-offs and verification instructions. This is a broad foundation, not a claim to enumerate every possible database incident.

[Evidence and limitations](VERIFICATION.md) · [Terminology and mapping pipeline](mapping-pipeline.md) · [Detailed authoring inventory](../../../learning-prompts/database-study/03-production-database-problems.md)

**Version context:** practice project uses Spring Boot 3.5.11, Spring Data JPA 3.5 / Hibernate 6.6 families, Java 25 and AWS SDK v2 BOM 2.57.7. Source schema is PostgreSQL 18.6. MongoDB examples are hypothetical mongosh fragments; there is no Mongo integration in this project. DynamoDB libraries are present, but no table connection has been tested.

**Snippet contract:** These are focused teaching fragments or explicitly labelled algorithms, not complete application files. Unspecified fixture entities, methods, tables and infrastructure do not exist merely because a snippet names them. SQL `:name` parameters require client binding and cannot be pasted unchanged into psql. Java imports/framework assumptions are stated where needed. The practice repository is narrow and does not expose every JpaRepository method used in hypothetical examples.

**Learning order:** begin with constraints, duplicate insertion, payload/tenant scope and lost updates. Then study transaction boundaries, querying, distributed recovery and capacity. For each case, explain the invariant and predict the failure before typing a fix.

| Case | Topic | Category |
|---|---|---|
| 01 | [N+1: a separate query for each row](01-query-shape-and-fetching/01-n-plus-one/README.md) | query shape and fetching |
| 02 | [Collection fetch join and pagination](01-query-shape-and-fetching/02-collection-pagination/README.md) | query shape and fetching |
| 03 | [Unbounded reads, offset cost and unstable pages](01-query-shape-and-fetching/03-keyset-pages/README.md) | query shape and fetching |
| 04 | [An index that does not match the query](02-indexes-and-plans/04-index-access-pattern/README.md) | indexes and plans |
| 05 | [Function filters and stale planning assumptions](02-indexes-and-plans/05-functions-and-plans/README.md) | indexes and plans |
| 06 | [Transactional method called through this](03-transactions-and-locking/06-self-invocation/README.md) | transactions and locking |
| 07 | [Checked exceptions and swallowed failures](03-transactions-and-locking/07-exception-rules/README.md) | transactions and locking |
| 08 | [Catching a constraint error does not repair a transaction](03-transactions-and-locking/08-failed-transaction/README.md) | transactions and locking |
| 09 | [Deadlocks and whole-transaction retry](03-transactions-and-locking/09-deadlocks/README.md) | transactions and locking |
| 10 | [Check then insert is not atomic](04-idempotency-and-concurrency/10-duplicate-insert/README.md) | idempotency and concurrency |
| 11 | [Same idempotency key, different intent](04-idempotency-and-concurrency/11-payload-and-tenant/README.md) | idempotency and concurrency |
| 12 | [Two writers overwrite each other](04-idempotency-and-concurrency/12-lost-update/README.md) | idempotency and concurrency |
| 13 | [Concurrent refunds exceed the captured amount](04-idempotency-and-concurrency/13-refund-limit/README.md) | idempotency and concurrency |
| 14 | [Cross-row invariants and write skew](04-idempotency-and-concurrency/14-write-skew/README.md) | idempotency and concurrency |
| 15 | [Floating point, overflow and decimal scale](05-mapping-and-types/15-money-types/README.md) | mapping and types |
| 16 | [Nullable columns and unstable enum storage](05-mapping-and-types/16-null-and-enum/README.md) | mapping and types |
| 17 | [Time zones and database defaults](05-mapping-and-types/17-time-and-defaults/README.md) | mapping and types |
| 18 | [save can merge and return a different managed object](05-mapping-and-types/18-detached-merge/README.md) | mapping and types |
| 19 | [Annotations do not guarantee installed constraints](06-constraints-and-schema/19-constraints/README.md) | constraints and schema |
| 20 | [Cascade delete, orphan removal and shared children](07-delete-and-lifecycle/20-cascade-and-orphans/README.md) | delete and lifecycle |
| 21 | [Bulk updates leave managed objects stale](07-delete-and-lifecycle/21-bulk-cache/README.md) | delete and lifecycle |
| 22 | [Connections are not returned to the pool](08-pools-and-capacity/22-connection-leak/README.md) | pools and capacity |
| 23 | [Application scaling multiplies database connections](08-pools-and-capacity/23-pool-amplification/README.md) | pools and capacity |
| 24 | [Network calls hold database transactions open](08-pools-and-capacity/24-long-transaction/README.md) | pools and capacity |
| 25 | [Read replica and cache lag after a write](09-consistency-and-caches/25-stale-read/README.md) | consistency and caches |
| 26 | [Schema changes break mixed application versions](10-migrations-and-storage/26-schema-rollout/README.md) | migrations and storage |
| 27 | [Long snapshots, dead tuples and storage growth](10-migrations-and-storage/27-mvcc-vacuum/README.md) | migrations and storage |
| 28 | [MongoDB unique identity needs an actual index](11-mongodb/28-mongo-uniqueness/README.md) | mongodb |
| 29 | [MongoDB stale read–modify–write](11-mongodb/29-mongo-atomic-update/README.md) | mongodb |
| 30 | [DynamoDB PutItem replaces an existing item](12-dynamodb/30-dynamo-overwrite/README.md) | dynamodb |
| 31 | [DynamoDB batch success can contain unfinished work](12-dynamodb/31-dynamo-partial-batch/README.md) | dynamodb |
| 32 | [DynamoDB index lag and TTL are not correctness gates](12-dynamodb/32-dynamo-consistency-and-ttl/README.md) | dynamodb |
| 33 | [Database commit and event publish are two writes](13-recovery-and-observability/33-outbox-dual-write/README.md) | recovery and observability |
| 34 | [A timeout does not prove payment failure](13-recovery-and-observability/34-provider-uncertainty/README.md) | recovery and observability |
| 35 | [Passing tests can hide missing commit and missing coverage](13-recovery-and-observability/35-test-false-confidence/README.md) | recovery and observability |
| 36 | [A backup is useful only if recovery works](13-recovery-and-observability/36-backup-and-reconciliation/README.md) | recovery and observability |
| 37 | [Java mapping and SQL column disagree](05-mapping-and-types/37-type-and-schema-mismatch/README.md) | mapping and types |
| 38 | [Finding an ID is not authorization](04-idempotency-and-concurrency/38-tenant-access/README.md) | idempotency and concurrency |
| 39 | [Duplicate and out-of-order outcomes](13-recovery-and-observability/39-event-order/README.md) | recovery and observability |
| 40 | [Soft delete does not automatically change visibility or uniqueness](07-delete-and-lifecycle/40-soft-delete/README.md) | delete and lifecycle |
| 41 | [Flush does not clear memory or commit batches](08-pools-and-capacity/41-flush-memory/README.md) | pools and capacity |
