# Correction — Catching a constraint error does not repair a transaction

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm: transactionTemplate owns the transaction; no outer transaction.
try {
    return writeInOwnTransaction(command);
} catch (KnownDuplicateRequestConflict conflict) {
    return readAndCompareInFreshTransaction(command);
}
```

The recovery boundary is outside the failed database transaction. Do not translate every integrity exception to an idempotency hit: NOT NULL, CHECK and unrelated unique constraints mean different things.

**Still required:** The algorithm requires actual new transaction ownership, not a same-object annotated call. Savepoints can recover SQL state in a deliberate JDBC design, but do not rewind Hibernate managed objects.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
