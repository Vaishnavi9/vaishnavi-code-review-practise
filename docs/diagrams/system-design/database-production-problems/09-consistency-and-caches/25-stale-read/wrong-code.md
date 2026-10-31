# Intentionally wrong example — Read replica and cache lag after a write

Teaching fragment only. Do not install this in the application.

```text
if (replica.findPayment(key).isEmpty()) {
    submitAnotherPayment();
}
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Primary commits payment P

2. Replica or cache has not received P

3. Client sees missing on a stale GET

4. Naive retry creates another business operation

POST commits to primary; immediate GET reads a lagging replica or old cache entry.
