# Java mapping and SQL column disagree

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

An address written for one building cannot reliably reach a different building. A mapping must identify the correct schema, table, column and compatible type.

## Requirement

Store and read the intended values without silent coercion or mapping surprises.

## Where it applies

Current merchantId is correctly mapped as String. The wrong example intentionally changes it to demonstrate the failure.

## Production symptom and trigger

Wrong schema/name/import, UUID versus numeric column, excessive string length, invalid JSON or a converter error causes persistence failure.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Java entity supplies a value under its mapping metadata

2. Hibernate selects JDBC binding and column name/type

3. JDBC transports values; PostgreSQL checks target type and constraints

4. Mismatch fails at mapping, binding, SQL execution or result extraction

## Why the correction works

JDBC transports SQL values; it does not independently infer JPA entities. Hibernate maps entities to SQL. Mongo’s mapper/driver uses BSON, while DynamoDB Enhanced Client maps to AttributeValue. These are distinct pipelines.

## Limits, alternatives and trade-offs

Length metadata is not input validation. Silent casts can hurt index use or obscure bugs. SQLSTATE 22001 is string truncation, 22003 numeric range, 22P02 invalid textual representation; actual exceptions depend on the failing layer.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
- [Official reference](https://www.postgresql.org/docs/18/datatype-numeric.html)
