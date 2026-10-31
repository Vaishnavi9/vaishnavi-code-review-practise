# Correction — Flush does not clear memory or commit batches

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Fragment inside a deliberately bounded transaction; input must also be streamed/bounded.
int count = 0;
for (Row row : boundedChunk) {
    em.persist(map(row));
    if (++count % 100 == 0) { em.flush(); em.clear(); }
}
em.flush();
em.clear();
// Commit belongs to the transaction owner, not flush/clear.
```

clear detaches objects; batch size must be measured. JDBC batching requires appropriate configuration and compatible ID strategy/SQL patterns. A flush failure requires ending the unit of work.

**Still required:** Multiple committed chunks lose whole-import atomicity; use staging/publish designs if the business requires all-or-nothing visibility. Identity generation may require early INSERTs and constrain batching.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
