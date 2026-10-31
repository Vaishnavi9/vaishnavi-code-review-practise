# Intentionally wrong example — Duplicate and out-of-order outcomes

Teaching fragment only. Do not install this in the application.

```text
payment.setStatus(event.status());
repository.save(payment);
ack(event);
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. SUCCESS for operation K is committed

2. Older PENDING event or duplicate SUCCESS arrives

3. Blind overwrite regresses state or repeats an effect

4. Merchant view and accounting become inconsistent

A delayed pending event arrives after success; two workers process the same event.
