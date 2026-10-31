# Check then insert is not atomic

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two cashiers can both see the last ticket before either sells it. Only one shared reservation rule can decide the winner.

## Requirement

At most one row for a merchant/request key, even across application instances.

## Where it applies

Relevant to the current create method: it inserts a new UUID each call; database uniqueness is present, but replay/conflict handling is not implemented.

## Production symptom and trigger

Two requests both see an absent key and attempt insertion.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Request A reads key K: absent

2. Request B reads key K: absent

3. Both try INSERT; Java checks did not serialize them

4. Unique constraint allows one; loser needs deliberate handling

## Why the correction works

The database unique constraint is the arbiter. A Java synchronized block cannot protect multiple application instances. NOT NULL prevents missing values; it does not replace uniqueness.

## Limits, alternatives and trade-offs

DO NOTHING does not return the existing row. A same-statement CTE can fail to see a concurrent winner due to snapshot timing. Higher isolation can require whole-transaction retry. This creates a local record, not an exactly-once external charge.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/sql-insert.html)
- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
