# Intentionally wrong example — DynamoDB index lag and TTL are not correctness gates

Teaching fragment only. Do not install this in the application.

```text
// Wrong assumptions:
if (gsiLookup(key).isEmpty()) acceptAsNew();
if (itemExists()) assumeStillValid();
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Base-table write succeeds

2. GSI has not caught up, or TTL cleanup has not happened

3. Application treats visibility as the business rule

4. Duplicate acceptance or stale validity decision occurs

A GSI query misses a just-written item; code assumes TTL removes data immediately at the expiry second.
