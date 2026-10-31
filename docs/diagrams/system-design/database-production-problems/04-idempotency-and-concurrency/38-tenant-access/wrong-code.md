# Intentionally wrong example — Finding an ID is not authorization

Teaching fragment only. Do not install this in the application.

```java
return repository.findById(paymentId).orElseThrow();
// Assumes an unpredictable UUID is sufficient authorization.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Merchant A obtains an ID belonging to merchant B

2. Endpoint fetches by ID alone

3. Database correctly returns the existing row

4. Missing authorization leaks B’s data

A backend trusts a merchant ID from the request or fetches by payment ID without ownership checks.
