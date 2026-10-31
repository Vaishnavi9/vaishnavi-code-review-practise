package com.vaishnavi.transaction.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "transactions", schema = "paymesh")
public class Transaction {

    @Id
    @Column(nullable = false, updatable = false)
    private UUID id;

    @Column(name = "merchant_id", nullable = false, length = 100)
    private String merchantId;

    @Column(name="request_key", nullable = false, length=128)
    private String requestKey;

    @Column(name="amount_minor", nullable = false)
    private long amountMinor;

    @Column(nullable = false, length = 3)
    private String currency;

    @Column(nullable = false, length=20)
    private String status;

    @Column(name="created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected Transaction() {}

    public Transaction(
            String merchantId,
            String requestKey,
            long amountMinor,
            String currency) {

        this.id = UUID.randomUUID();
        this.merchantId = merchantId;
        this.requestKey = requestKey;
        this.amountMinor = amountMinor;
        this.currency = currency;
        this.status = "CREATED";
        this.createdAt = Instant.now();
    }

    public UUID getId() {
        return id;
    }

    public String getMerchantId() {
        return merchantId;
    }

    public String getRequestKey() {
        return requestKey;
    }

    public long getAmountMinor() {
        return amountMinor;
    }

    public String getCurrency() {
        return currency;
    }

    public String getStatus() {
        return status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
