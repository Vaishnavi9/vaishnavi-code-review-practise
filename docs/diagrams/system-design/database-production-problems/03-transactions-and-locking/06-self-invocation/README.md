# Transactional method called through this

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A security desk cannot check a visitor who bypasses the entrance. Spring’s normal proxy similarly cannot intercept a direct call inside the same object.

## Requirement

A two-write service operation must use one real transaction.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A helper carries @Transactional but an unannotated method in the same object calls it; individual repository transactions can commit separately.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Caller enters unannotated service method

2. this.writeBoth bypasses proxy interception

3. No service transaction is established by that annotation

4. Separate repository commits can leave only the first write

## Why the correction works

Move the transaction boundary to the actual external service entry point, or call a separate injected transactional bean. This describes proxy mode, not AspectJ weaving.

## Limits, alternatives and trade-offs

An existing outer transaction can change the outcome. Self-invocation does not erase an already active transaction. External network calls are not undone, and readOnly is not an authorization control.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/annotations.html)
