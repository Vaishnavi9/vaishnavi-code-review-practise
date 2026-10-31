# CAUGHT FAILURE: the transaction can still be doomed

[Open the large diagram](05-caught-inner-failure.svg)

This illustrates the common UnexpectedRollbackException case: an inner proxied REQUIRED method requests rollback while the outer caller attempts normal completion. Do not swallow the failure and report success. Recover in a new transaction after the failed one ends. A same-object call that bypasses the proxy is a different case; distinguish the paths when debugging.

**Rule:** Catching an exception does not repair a transaction marked rollback-only.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```text
// Pseudocode: the inner call crosses another Spring proxy.
outer REQUIRED T1:
    try inner REQUIRED T1
    catch failure
    return normally
// T1 still cannot commit.
```

## Evidence to obtain

Use two Spring-managed beans, make the inner call fail, catch outside that call, and assert rollback plus the outer completion error.

## Explain without looking

How many physical transactions exist in this example?

## Source notes

- [Propagation](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/tx-propagation.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
