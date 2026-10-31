# Intentionally wrong example — Collection fetch join and pagination

Teaching fragment only. Do not install this in the application.

```text
// Hypothetical Payment has a to-many operations collection.
em.createQuery("select p from Payment p join fetch p.operations", Payment.class)
  .setMaxResults(20).getResultList();
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Query joins payments with many operations

2. One root occupies multiple SQL rows

3. ORM may retrieve far more rows to preserve collections

4. Small page request consumes large time and memory

A collection fetch with a page can cause in-memory limiting, excessive reads, warnings or an exception if configured to fail.
