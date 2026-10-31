-- Connect to the paymesh database before executing this script.
-- This table already exists locally. Kept here for learning and reproducibility.
-- Run manually only against a database where paymesh.transactions does not exist.
-- The paymesh schema must already exist. Spring does not run this file automatically.

CREATE TABLE paymesh.transactions (
    id UUID PRIMARY KEY,

    merchant_id VARCHAR(100) NOT NULL,
    request_key VARCHAR(128) NOT NULL,

    amount_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT transactions_merchant_not_blank
        CHECK (length(btrim(merchant_id)) > 0),

    CONSTRAINT transactions_request_key_not_blank
        CHECK (length(btrim(request_key)) > 0),

    CONSTRAINT transactions_positive_amount
        CHECK (amount_minor > 0),

    CONSTRAINT transactions_currency_format
        CHECK (currency ~ '^[A-Z]{3}$'),

    CONSTRAINT transactions_initial_status
        CHECK (status = 'CREATED'),

    CONSTRAINT transactions_merchant_request_unique
        UNIQUE (merchant_id, request_key)
);
