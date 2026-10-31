# Database learning prompts

These are comprehensive authoring prompts, not completed implementations or executed test results.

1. [Transactions, flush, rollback and recovery](01-transactions-flush-and-recovery.md)
2. [All application annotation families, IDs and object mapping](02-annotations-ids-and-object-mapping.md)
3. [Production database problems: bad code, corrected code and evidence](03-production-database-problems.md)

The production-problems prompt inventories query/fetching, indexes/plans, transaction boundaries, concurrency, idempotency, type conversion, constraints, deletion/cascades, pool capacity, caches/replicas, migrations/recovery, MongoDB, DynamoDB and misleading tests.

Existing transaction diagrams: [rollback learning pack](../../diagrams/system-design/rollback/README.md).

The prompts require version-specific API inventories so that missing annotation coverage is explicit. They do not claim to enumerate every future framework annotation or every imaginable production failure. The learner should study one scenario at a time.
