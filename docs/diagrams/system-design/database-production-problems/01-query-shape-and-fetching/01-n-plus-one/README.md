# N+1: a separate query for each row

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Ordering one item per trip makes ten items take ten trips. Here each trip is a database round trip and each extra item is a lazy association.

## Requirement

Render a bounded payment list with merchant names without one extra query per payment.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A page is fast with one payment but slows with many distinct merchants; SQL count grows with returned rows.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Query payments P1, P2, P3; distinct merchants M1, M2, M3

2. Access P1.merchant.name: SELECT merchant M1

3. Access P2.merchant.name: SELECT merchant M2

4. Access P3.merchant.name: SELECT merchant M3; four SELECTs total

## Why the correction works

The loop accesses an unloaded relationship. The changed query loads that specific relationship with the roots. The four-query count assumes three distinct uncached merchants, no second-level/query cache and a cold persistence context.

## Limits, alternatives and trade-offs

A DTO projection avoids entity materialisation; batch fetching reduces round trips but is not necessarily one query. Do not globally make every association eager. Other relationships and serializers can still introduce N+1. Current Transaction has no associations.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.hibernate.org/orm/6.6/userguide/html_single/#fetching)
- [Official reference](https://docs.spring.io/spring-data/jpa/reference/3.5/jpa/query-methods.html)
