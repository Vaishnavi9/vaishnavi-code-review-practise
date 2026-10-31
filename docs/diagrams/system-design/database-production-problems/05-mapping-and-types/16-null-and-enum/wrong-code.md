# Intentionally wrong example — Nullable columns and unstable enum storage

Teaching fragment only. Do not install this in the application.

```java
long optionalFee; // cannot represent SQL NULL
@Enumerated(EnumType.ORDINAL)
PaymentStatus status;
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Database contains NULL or enum ordinal 1

2. Java expects a primitive or a reordered enum

3. Mapping fails or the value gets the wrong meaning

4. Old and new releases interpret data differently

A nullable SQL number maps to a primitive; an ordinal enum changes after a new constant is inserted.
