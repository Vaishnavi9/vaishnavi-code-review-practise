# Correction — Floating point, overflow and decimal scale

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```java
// Imports: java.math.BigDecimal, java.math.RoundingMode.
// fractionDigits comes from supported currency metadata, not always 2.
long minor = new BigDecimal(input)
    .setScale(fractionDigits, RoundingMode.UNNECESSARY)
    .movePointRight(fractionDigits).longValueExact();
if (minor <= 0) throw new IllegalArgumentException("Amount must be positive");
```

UNNECESSARY rejects implicit rounding; longValueExact rejects overflow. The API may already accept minor units, in which case no major-to-minor conversion is required. Monetary arithmetic also needs overflow-safe addition.

**Still required:** Some products intentionally round; define the mode and when it applies. Currency format alone does not prove a supported currency. PostgreSQL numeric(p,s) may round input to its scale before range validation.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
