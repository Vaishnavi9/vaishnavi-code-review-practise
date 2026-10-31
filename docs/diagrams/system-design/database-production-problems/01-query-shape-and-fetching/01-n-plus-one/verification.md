# Verification — N+1: a separate query for each row

**Status: source-reviewed teaching scenario.** The exact Java/MongoDB/DynamoDB fragments in this chapter have not been compiled or executed as application integration tests. Related synthetic PostgreSQL tests, where executed, are listed separately in the [atlas evidence report](../../VERIFICATION.md). A related SQL assertion does not prove this whole integration.

## Proposed deterministic check

Clear the persistence context and caches between variants. Seed three distinct merchants and payments. Count SELECTs across both query and rendering, assert equal outputs and four versus one for this isolated fixture. Repeat with shared merchants; the count may differ. Watch SELECTs/request and p95, not SQL logging alone.

## Expected result

Render a bounded payment list with merchant names without one extra query per payment.

## Observed result

Executed a matching synthetic Hibernate 6.6.42/H2 fixture: 4 SELECTs versus 1, identical merchant names. The application itself has no such relationships. No application integration run is claimed. Record runtime versions, fixture setup, input, failure injection, actual assertions, cleanup and result here when the exercise is executed. Test the wrong variant too: the check should fail for the intended reason, then pass with the correction.

## Independent variation

Change one assumption: add a competing writer, a retry, a missing value, a larger dataset, or a crash at the relevant boundary. Predict the result before running. Evidence from copied code is not independent understanding.
