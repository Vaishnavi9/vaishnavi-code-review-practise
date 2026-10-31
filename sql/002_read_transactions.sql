-- Read-only inspection. Connect to database paymesh.
-- Replace the synthetic merchant placeholder with the value from your debugger.
-- In the integration test, pause after service.create returns and before cleanup.
SELECT id, merchant_id, request_key, amount_minor, currency, status, created_at
FROM paymesh.transactions
WHERE merchant_id = 'code-review-test-REPLACE-WITH-DEBUGGER-VALUE'
ORDER BY created_at, id
LIMIT 20;
