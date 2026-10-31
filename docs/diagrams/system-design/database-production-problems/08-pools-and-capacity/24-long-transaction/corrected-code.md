# Correction — Network calls hold database transactions open

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm with durable state, not synchronous fake atomicity.
TX1: reserve once; store payment intent and outgoing event; commit
worker: call provider using stable operation identity and timeout
TX2: record confirmed outcome with allowed-state guard; commit
uncertain outcome: reconcile before issuing another money movement
```

The corrected algorithm exposes the distributed boundary instead of implying database rollback reverses a remote charge. It requires worker recovery, provider idempotency where supported, and an explicit pending state.

**Still required:** This is a broader design, not a drop-in method. A brief synchronous call may fit another contract, but timeout uncertainty still exists. Limit transaction duration and monitor lock ages.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
