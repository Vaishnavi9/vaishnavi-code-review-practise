# Application scaling multiplies database connections

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Adding queues at a small kitchen does not add cooks. More application instances can simply send more work to the same database.

## Requirement

Keep total database work and connection demand within measured capacity.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Autoscaling grows from 5 to 50 instances while each maintains a large maximum pool; nested REQUIRES_NEW consumes additional connections.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Traffic triggers more app instances

2. Each instance has its own pool

3. Combined connections and query concurrency exceed DB capacity

4. Queueing, timeouts and retries amplify the incident

## Why the correction works

A connection ceiling is not a throughput target. Database CPU, disk and lock contention can saturate before the connection limit. A suspended outer transaction can hold its connection while REQUIRES_NEW requests another.

## Limits, alternatives and trade-offs

Pooling proxies may help connection overhead, not unlimited query work. Avoid deep nesting and unrelated work inside transactions. Exact pool sizes require measurements, not a universal number.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/tx-propagation.html)
- [Official reference](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
