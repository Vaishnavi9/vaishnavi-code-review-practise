# Intentionally wrong example — Flush does not clear memory or commit batches

Teaching fragment only. Do not install this in the application.

```java
for (Row row : allRows) {
    em.persist(map(row));
    em.flush(); // frequent flush harms batching; entities remain managed
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Import loads many rows and creates managed entities

2. flush sends SQL but retains managed objects

3. Persistence context and transaction grow

4. Heap, dirty checking, locks and rollback costs increase

A huge loop persists records and calls flush, but never clears the persistence context; one enormous transaction also holds locks and rollback work.
