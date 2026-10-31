# Intentionally wrong example — Time zones and database defaults

Teaching fragment only. Do not install this in the application.

```java
LocalDateTime occurredAt = LocalDateTime.now();
// INSERT ... created_at = NULL; assume DEFAULT now() is applied.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Server records local wall-clock time without offset

2. Another zone or daylight-saving boundary interprets it

3. Intended instant is ambiguous or shifted

4. Reports and ordering disagree

LocalDateTime is used for global events; an ORM sends NULL or a Java default and expects a SQL DEFAULT to replace it.
