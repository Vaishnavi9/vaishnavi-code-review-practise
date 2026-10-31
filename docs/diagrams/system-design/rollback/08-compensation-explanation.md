# COMPENSATION: a new corrective action

[Open the large diagram](08-compensation.svg)

Use a compensating workflow for completed effects that cannot share a local database transaction. A provider timeout means the original action may have happened: establish the outcome before choosing an action, and do not blindly submit another payment. A refund is not a SQL rollback. Compensation must handle duplicate requests, failures and human recovery. A full saga implementation is a later topic, not implemented here.

**Rule:** Compensation does not erase history or guarantee an instant reversal.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```text
// Explanatory pseudocode; no provider integration is implemented.
confirmed external outcome + later failure
    -> record recovery task
    -> request permitted compensation with stable identity
    -> reconcile until outcome is known
```

## Evidence to obtain

With a fake provider, simulate a completed action followed by local failure. Verify recovery is recorded and retries do not create duplicate compensation effects.

## Explain without looking

Will rolling back PostgreSQL cancel an already completed provider action?

## Source notes

- [Compensation](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga-orchestration.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
