# Correction — Database commit and event publish are two writes

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm with one local database transaction.
TX: write business state + outbox row with stable event ID; COMMIT
relay: claim committed outbox work; publish; record progress
consumer TX: insert unique inbox event ID + apply effect; COMMIT
acknowledge message only after durable consumer work
```

The outbox closes the local dual-write gap, but delivery can repeat. Inbox uniqueness and effect must share an atomic boundary. Claim leases need expiry/recovery so crashed workers do not strand work.

**Still required:** Ordering, poison events, bounded retries, schema evolution and retention still need policy. This does not make arbitrary external side effects exactly once. Current small service has no implemented outbox flow even though the larger database has outbox tables.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
