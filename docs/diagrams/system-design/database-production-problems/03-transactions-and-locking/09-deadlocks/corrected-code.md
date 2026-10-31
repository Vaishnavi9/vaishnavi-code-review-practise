# Correction — Deadlocks and whole-transaction retry

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Both transactions use the same global ordering.
SELECT id FROM accounts WHERE id IN (:a, :b) ORDER BY id FOR UPDATE;
-- Apply the balanced transfer within this transaction.
-- On deadlock/serialization failure: rollback, bounded retry of whole unit.
```

Consistent lock order removes this particular cycle. Re-read values and rerun business checks inside the new attempt. Use SQLSTATE classification such as deadlock 40P01 and serialization 40001.

**Still required:** Other tables and triggers can introduce different lock paths. Lock timeout 55P03 is not identical to deadlock. Do not blindly retry external charging. Monitor lock waits, retries and exhausted attempts.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
