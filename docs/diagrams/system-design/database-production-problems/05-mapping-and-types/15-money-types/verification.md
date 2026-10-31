# Verification — Floating point, overflow and decimal scale

**Status: source-reviewed teaching scenario.** The exact Java/MongoDB/DynamoDB fragments in this chapter have not been compiled or executed as application integration tests. Related synthetic PostgreSQL tests, where executed, are listed separately in the [atlas evidence report](../../VERIFICATION.md). A related SQL assertion does not prove this whole integration.

## Proposed deterministic check

Check 0.29 -> 29 at scale 2, excessive fractional digits, negative/zero, maximum range, and supported currencies with scale 0 or 3. Assert rejected inputs do not reach persistence.

## Expected result

Represent amounts exactly under a documented currency scale and range.

## Observed result

Executed the exact BigDecimal conversion shape: 0.29 -> 29; excess precision and long overflow were rejected. No application integration run is claimed. Record runtime versions, fixture setup, input, failure injection, actual assertions, cleanup and result here when the exercise is executed. Test the wrong variant too: the check should fail for the intended reason, then pass with the correction.

## Independent variation

Change one assumption: add a competing writer, a retry, a missing value, a larger dataset, or a crash at the relevant boundary. Predict the result before running. Evidence from copied code is not independent understanding.
