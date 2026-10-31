# Intentionally wrong example — A timeout does not prove payment failure

Teaching fragment only. Do not install this in the application.

```text
try { provider.charge(newRandomKey(), amount); }
catch (TimeoutException e) { provider.charge(newRandomKey(), amount); }
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Provider receives operation K and may complete it

2. Response is lost; local caller sees timeout

3. Caller retries with fresh identity K2

4. Provider may accept two distinct charges

Connection times out after the provider receives a payment; application retries using a new provider operation key.
