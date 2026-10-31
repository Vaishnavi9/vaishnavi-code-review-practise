# Floating point, overflow and decimal scale

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Measuring coins with a stretched ruler introduces tiny errors. Binary floating point can similarly misrepresent exact decimal monetary inputs.

## Requirement

Represent amounts exactly under a documented currency scale and range.

## Where it applies

Current amountMinor is long, not double. This is an input/conversion extension lesson; the current service does not perform this conversion.

## Production symptom and trigger

Floating point multiplication/truncation loses a minor unit; fixed scale two is wrongly applied to every currency; integers overflow.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Parse decimal input as binary floating point

2. Multiply and truncate toward zero

3. Precision loss or overflow changes the intended amount

4. Stored payment no longer matches the customer instruction

## Why the correction works

UNNECESSARY rejects implicit rounding; longValueExact rejects overflow. The API may already accept minor units, in which case no major-to-minor conversion is required. Monetary arithmetic also needs overflow-safe addition.

## Limits, alternatives and trade-offs

Some products intentionally round; define the mode and when it applies. Currency format alone does not prove a supported currency. PostgreSQL numeric(p,s) may round input to its scale before range validation.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/datatype-numeric.html)
