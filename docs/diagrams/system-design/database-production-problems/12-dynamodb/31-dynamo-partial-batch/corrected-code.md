# Correction — DynamoDB batch success can contain unfinished work

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Algorithm; bounded attempts, deadline and durable retry path required.
pending = originalWrites
while pending is not empty and retryBudgetAllows:
    result = batchWrite(pending)
    pending = result.unprocessedItems
    if pending is not empty: waitWithExponentialBackoffAndJitter()
if pending is not empty: persistOrReportUnfinishedWork(pending)
else: reportBatchComplete()
```

BatchWriteItem is not one atomic transaction and does not support per-item conditional expressions. Whole-call errors also need a defined retry path. Repeating unconditional puts can overwrite newer data, so workload semantics matter.

**Still required:** Use TransactWriteItems for a supported all-or-nothing set when required, with its limits and conflict handling. Do not retry forever or hide failures. No live Dynamo batch test was run.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
