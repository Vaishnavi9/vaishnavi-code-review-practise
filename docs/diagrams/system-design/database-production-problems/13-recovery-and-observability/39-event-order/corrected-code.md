# Correction — Duplicate and out-of-order outcomes

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm; requires trusted event identity and documented ordering.
TX: insert unique inbox event ID
    if duplicate: do not reapply effect
    otherwise: validate owner, operation, allowed transition and source version
               apply guarded state change and required local effects
COMMIT; acknowledge
// Reject/quarantine impossible transitions; reconcile conflicting authority.
```

A timestamp alone is not reliable causal order across clocks. Use provider sequence/version only where documented. Compare-and-set guards and transition rules must be operation-specific: a refund is not simply payment success becoming failure.

**Still required:** Terminal-state assumptions can be wrong for some products; define the state machine first. Poison events need bounded retries and a repair path. An inbox table alone does not implement correct handling.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
