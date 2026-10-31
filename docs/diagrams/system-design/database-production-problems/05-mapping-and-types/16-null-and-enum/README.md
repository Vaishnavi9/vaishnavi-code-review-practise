# Nullable columns and unstable enum storage

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A missing answer is different from the answer zero. Likewise a numbered label changes meaning if the list of labels is reordered.

## Requirement

Preserve missing values and stable meaning across releases.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A nullable SQL number maps to a primitive; an ordinal enum changes after a new constant is inserted.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Database contains NULL or enum ordinal 1

2. Java expects a primitive or a reordered enum

3. Mapping fails or the value gets the wrong meaning

4. Old and new releases interpret data differently

## Why the correction works

A wrapper represents null; it does not validate business rules. STRING avoids ordinal reordering, but renaming constants still requires a data/compatibility migration. Never silently change ordinal mapping over existing rows.

## Limits, alternatives and trade-offs

Stable external codes plus AttributeConverter can decouple names. Unknown future values need a defined policy. The current status field is String and the table only allows CREATED; neither bad mapping is present here.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
