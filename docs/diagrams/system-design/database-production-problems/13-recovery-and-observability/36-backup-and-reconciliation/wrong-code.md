# Intentionally wrong example — A backup is useful only if recovery works

Teaching fragment only. Do not install this in the application.

```text
if (backupFileExists()) report("Recovery proven");
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Backup job reports success

2. Incident requires restoration

3. Missing logs, permissions or procedure block recovery

4. Restored local data may also disagree with external payments

Backups exist but nobody has restored them; events/providers continued during the outage; restored state disagrees with external reality.
