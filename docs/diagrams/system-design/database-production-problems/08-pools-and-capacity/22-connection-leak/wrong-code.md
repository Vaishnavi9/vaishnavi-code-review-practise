# Intentionally wrong example — Connections are not returned to the pool

Teaching fragment only. Do not install this in the application.

```java
Connection c = dataSource.getConnection();
PreparedStatement s = c.prepareStatement(sql);
ResultSet r = s.executeQuery();
// No finally/close; an exception leaks resources.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Each request borrows one connection

2. Failure skips cleanup

3. Pool reaches its connection limit

4. New requests wait and time out without reaching SQL

A JDBC connection or result stream leaks on exceptions; active pool count stays high after requests finish.
