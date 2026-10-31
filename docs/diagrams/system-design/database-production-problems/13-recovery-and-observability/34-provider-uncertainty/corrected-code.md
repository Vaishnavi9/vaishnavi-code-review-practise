# Correction — A timeout does not prove payment failure

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Recovery algorithm, adapted to the provider’s documented capabilities.
persist stable operation ID before submission
submit using that same identity where idempotency is supported
on timeout: record UNKNOWN, query status / wait for authenticated webhook
reconcile against authoritative evidence before any new money movement
```

Database rollback cannot undo an already completed provider action. Compensation such as refund is a new operation with its own idempotency, possible failure and accounting entries.

**Still required:** Not every provider supports idempotency or status lookup; such cases require explicit operational reconciliation. A UI pending state can be safer than falsely reporting failure or success. Preserve audit evidence.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
