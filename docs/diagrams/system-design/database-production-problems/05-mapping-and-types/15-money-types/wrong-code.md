# Intentionally wrong example — Floating point, overflow and decimal scale

Teaching fragment only. Do not install this in the application.

```java
long minor = (long) (Double.parseDouble(input) * 100);
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Parse decimal input as binary floating point

2. Multiply and truncate toward zero

3. Precision loss or overflow changes the intended amount

4. Stored payment no longer matches the customer instruction

Floating point multiplication/truncation loses a minor unit; fixed scale two is wrongly applied to every currency; integers overflow.
