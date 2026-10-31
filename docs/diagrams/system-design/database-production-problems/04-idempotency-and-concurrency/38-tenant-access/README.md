# Finding an ID is not authorization

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Knowing an apartment number is not a key to its door. Knowing a payment ID similarly does not grant access to that merchant’s payment.

## Requirement

A merchant may read/change only its authorized records.

## Where it applies

Current repository exposes a merchant-scoped ID finder. End-to-end authorization has not been demonstrated.

## Production symptom and trigger

A backend trusts a merchant ID from the request or fetches by payment ID without ownership checks.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Merchant A obtains an ID belonging to merchant B

2. Endpoint fetches by ID alone

3. Database correctly returns the existing row

4. Missing authorization leaks B’s data

## Why the correction works

Transaction isolation concerns concurrent visibility, not tenant permissions. The current repository has a scoped finder, but existence of that method does not prove every endpoint uses it correctly.

## Limits, alternatives and trade-offs

Row-level security can provide additional enforcement with carefully managed roles/session context; it is disabled on the captured schema. Schema-per-tenant or database-per-tenant trades cost and operational complexity for stronger physical separation.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
