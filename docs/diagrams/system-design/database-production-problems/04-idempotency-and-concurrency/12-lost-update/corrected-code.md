# Correction — Two writers overwrite each other

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Hypothetical accounts fixture; version is a required bigint column.
UPDATE accounts SET balance_minor = :next_balance, version = version + 1
WHERE id = :id AND version = :version_read;
-- Require exactly one affected row; zero means reload/re-evaluate or conflict.
-- JPA equivalent for entity updates: @jakarta.persistence.Version Long version;
```

The version predicate makes the check and write atomic. Check the affected-row count. Hibernate @Version implements optimistic locking for supported entity operations; bulk/custom SQL must preserve the invariant explicitly.

**Still required:** A version conflict does not mean retry the stale calculated value. Atomic arithmetic updates or pessimistic locking can fit other requirements. @Version alone does not prevent cross-row write skew.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
