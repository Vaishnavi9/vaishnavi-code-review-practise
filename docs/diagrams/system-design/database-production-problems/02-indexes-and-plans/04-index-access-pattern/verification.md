# Verification — An index that does not match the query

**Status: source-reviewed teaching scenario.** The exact Java/MongoDB/DynamoDB fragments in this chapter have not been compiled or executed as application integration tests. Related synthetic PostgreSQL tests, where executed, are listed separately in the [atlas evidence report](../../VERIFICATION.md). A related SQL assertion does not prove this whole integration.

## Proposed deterministic check

Use EXPLAIN without ANALYZE first. EXPLAIN ANALYZE executes the query, including writes; use it only on safe reads or isolated fixtures. Refresh statistics when appropriate and compare representative skewed merchants.

## Expected result

Find one merchant’s recent payments without assuming any index guarantees speed.

## Observed result

No chapter-specific integration run is claimed. Record runtime versions, fixture setup, input, failure injection, actual assertions, cleanup and result here when the exercise is executed. Test the wrong variant too: the check should fail for the intended reason, then pass with the correction.

## Independent variation

Change one assumption: add a competing writer, a retry, a missing value, a larger dataset, or a crash at the relevant boundary. Predict the result before running. Evidence from copied code is not independent understanding.
