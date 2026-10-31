# Intentionally wrong example — DynamoDB batch success can contain unfinished work

Teaching fragment only. Do not install this in the application.

```text
client.batchWriteItem(request);
return "all saved";
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Submit batch of puts/deletes

2. Service processes some items and returns others unprocessed

3. Application ignores the remaining list

4. Caller is told all succeeded while some data is missing

BatchWriteItem response has UnprocessedItems which the application ignores.
