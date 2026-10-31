# Correction — Application scaling multiplies database connections

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
# Capacity worksheet, not deployable configuration.
app_connection_budget = database_limit - administration - other_clients - safety_headroom
per_instance_limit <= app_connection_budget / maximum_simultaneous_instances
# Include rolling-deployment surge, workers, and nested transaction demand.
# Enforce admission limits; load-test the resulting budget.
```

A connection ceiling is not a throughput target. Database CPU, disk and lock contention can saturate before the connection limit. A suspended outer transaction can hold its connection while REQUIRES_NEW requests another.

**Still required:** Pooling proxies may help connection overhead, not unlimited query work. Avoid deep nesting and unrelated work inside transactions. Exact pool sizes require measurements, not a universal number.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
