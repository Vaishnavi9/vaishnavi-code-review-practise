# Verification — Flush does not clear memory or commit batches

**Status: source-reviewed teaching scenario.** The exact Java/MongoDB/DynamoDB fragments in this chapter have not been compiled or executed as application integration tests. Related synthetic PostgreSQL tests, where executed, are listed separately in the [atlas evidence report](../../VERIFICATION.md). A related SQL assertion does not prove this whole integration.

## Proposed deterministic check

Measure heap, managed entity count, SQL batches, transaction age and total duration at increasing input sizes. Crash between chunks and verify resumability without duplicate effects.

## Expected result

Import bounded work without retaining every entity or accidentally changing atomicity.

## Observed result

Executed a Hibernate fixture confirming flush keeps an entity managed and its SQL changes are still rolled back; no large-import memory benchmark was run. No application integration run is claimed. Record runtime versions, fixture setup, input, failure injection, actual assertions, cleanup and result here when the exercise is executed. Test the wrong variant too: the check should fail for the intended reason, then pass with the correction.

## Independent variation

Change one assumption: add a competing writer, a retry, a missing value, a larger dataset, or a crash at the relevant boundary. Predict the result before running. Evidence from copied code is not independent understanding.
