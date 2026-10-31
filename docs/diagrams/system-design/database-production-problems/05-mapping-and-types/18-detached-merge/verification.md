# Verification — save can merge and return a different managed object

**Status: source-reviewed teaching scenario.** The exact Java/MongoDB/DynamoDB fragments in this chapter have not been compiled or executed as application integration tests. Related synthetic PostgreSQL tests, where executed, are listed separately in the [atlas evidence report](../../VERIFICATION.md). A related SQL assertion does not prove this whole integration.

## Proposed deterministic check

In a fixture, compare identity and EntityManager.contains for original versus returned object; inspect SQL and committed fields. Repeat for a missing ID and for a concurrent version conflict.

## Expected result

Modify the correct managed entity and avoid accidental overwrite from incomplete detached objects.

## Observed result

Executed a standalone Hibernate fixture: merge returned a different managed object while the input stayed detached. No application integration run is claimed. Record runtime versions, fixture setup, input, failure injection, actual assertions, cleanup and result here when the exercise is executed. Test the wrong variant too: the check should fail for the intended reason, then pass with the correction.

## Independent variation

Change one assumption: add a competing writer, a retry, a missing value, a larger dataset, or a crash at the relevant boundary. Predict the result before running. Evidence from copied code is not independent understanding.
