# Intentionally wrong example — Database commit and event publish are two writes

Teaching fragment only. Do not install this in the application.

```text
repository.save(payment);
broker.publish(event);
// Neither ordering makes two independent systems one atomic transaction.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Business row commits

2. Process crashes before event publish

3. No durable record says publish is still owed

4. Downstream system never learns about the change

Application commits a row then crashes before publishing, or publishes before the database rollback.
