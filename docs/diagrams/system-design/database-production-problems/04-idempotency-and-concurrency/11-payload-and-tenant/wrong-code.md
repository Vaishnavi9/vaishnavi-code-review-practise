# Intentionally wrong example — Same idempotency key, different intent

Teaching fragment only. Do not install this in the application.

```java
return repo.findByRequestKey(key).orElseGet(() -> create(command));
// Wrong: no merchant scope and no payload comparison.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Key K belongs to merchant A and amount 100

2. Caller sends K with amount 900, or another merchant

3. Lookup uses only K and blindly replays

4. Response refers to wrong intent or leaks another merchant’s data

A client accidentally reuses a key, or another merchant uses the same text key.
