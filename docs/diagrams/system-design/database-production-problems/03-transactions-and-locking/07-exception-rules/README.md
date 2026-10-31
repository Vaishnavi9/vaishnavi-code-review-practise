# Checked exceptions and swallowed failures

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A supervisor can act only on a reported failure and the agreed rules. Catching a failure and declaring success hides that signal.

## Requirement

Business rejection must not accidentally commit partial work.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A checked business exception escapes with default rules; or a catch block converts a failure to a success response.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Method starts a transaction and writes A

2. A checked exception escapes

3. Default rule does not request rollback for that type

4. Commit can be attempted if transaction remains viable

## Why the correction works

Default Spring rules request rollback for RuntimeException and Error. Use specific rollbackFor classes for checked failures. Global configuration can change defaults; inspect it before diagnosing.

## Limits, alternatives and trade-offs

noRollbackFor does not revive a transaction already aborted by PostgreSQL. Catching a persistence failure and continuing is not a repair. Programmatic rollback-only is another option when an explicit rejected result is intended.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/rolling-back.html)
