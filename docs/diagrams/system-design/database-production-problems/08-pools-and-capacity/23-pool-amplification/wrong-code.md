# Intentionally wrong example — Application scaling multiplies database connections

Teaching fragment only. Do not install this in the application.

```text
# Hypothetical budget: 50 instances * maximumPoolSize 30 = 1500 possible app connections.
# Database budget for this app is only 300. Increasing pool size makes it worse.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Traffic triggers more app instances

2. Each instance has its own pool

3. Combined connections and query concurrency exceed DB capacity

4. Queueing, timeouts and retries amplify the incident

Autoscaling grows from 5 to 50 instances while each maintains a large maximum pool; nested REQUIRES_NEW consumes additional connections.
