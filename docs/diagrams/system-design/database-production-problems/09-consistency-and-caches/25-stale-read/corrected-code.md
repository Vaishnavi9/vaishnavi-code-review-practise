# Correction — Read replica and cache lag after a write

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm: use stable request identity and authoritative writes.
receipt = commitOrReplayOnPrimary(command)
return receipt
// Read-your-write route: primary/consistency token as supported.
// Cached/reporting reads expose their freshness; they never authorize duplicate effects.
```

Consistency depends on the read path. A cache invalidation can race an older read that repopulates stale data; versioned updates, bounded staleness and bypass rules may be needed.

**Still required:** Primary reads do not fix client authorization, commit ambiguity or incorrect state transitions. Stronger read routing costs primary capacity. A report can tolerate lag where payment authorization cannot.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
