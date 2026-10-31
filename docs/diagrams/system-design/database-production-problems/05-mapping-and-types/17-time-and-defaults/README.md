# Time zones and database defaults

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A meeting time without its city is ambiguous. A local date-time without an offset similarly cannot identify one worldwide instant.

## Requirement

Record an event instant consistently and know which layer supplies defaults.

## Where it applies

The current entity uses Instant and generates createdAt in its constructor. The database also has a default; document which path supplies the value.

## Production symptom and trigger

LocalDateTime is used for global events; an ORM sends NULL or a Java default and expects a SQL DEFAULT to replace it.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Server records local wall-clock time without offset

2. Another zone or daylight-saving boundary interprets it

3. Intended instant is ambiguous or shifted

4. Reports and ordering disagree

## Why the correction works

PostgreSQL timestamptz stores an instant, not the original zone ID. Store the zone separately if the business needs it. ORM-generated INSERT columns decide whether database defaults are used.

## Limits, alternatives and trade-offs

Clock skew means timestamps alone are not a causal ordering guarantee. PostgreSQL timestamp precision and Java nanoseconds may differ. Local appointments may require LocalDateTime plus a named zone instead.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/datatype-datetime.html)
