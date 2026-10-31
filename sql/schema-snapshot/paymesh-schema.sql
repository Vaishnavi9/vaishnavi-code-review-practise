--
-- PostgreSQL database dump
--

\restrict SpODwGXreBJH66GyKBPtNkx5dB8UL7BcsJGLpD1hdvhJcGYboAP7cuiZ4tdfLWX

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: paymesh; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA paymesh;


SET default_table_access_method = heap;

--
-- Name: bank_accounts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.bank_accounts (
    bank_account_id uuid DEFAULT gen_random_uuid() NOT NULL,
    cash_ledger_account_id uuid NOT NULL,
    bank_code character varying(100) NOT NULL,
    external_account_token character varying(300) NOT NULL,
    currency character varying(3) NOT NULL,
    purpose character varying(30) NOT NULL,
    status character varying(30) NOT NULL,
    CONSTRAINT bank_accounts_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text))
);


--
-- Name: bank_statement_lines; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.bank_statement_lines (
    statement_line_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statement_id uuid NOT NULL,
    line_number integer NOT NULL,
    external_transaction_reference character varying(200),
    direction character varying(3) NOT NULL,
    amount_minor bigint NOT NULL,
    description text,
    booked_at timestamp with time zone NOT NULL,
    value_date date,
    CONSTRAINT bank_statement_lines_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT bank_statement_lines_direction_check CHECK (((direction)::text = ANY ((ARRAY['IN'::character varying, 'OUT'::character varying])::text[]))),
    CONSTRAINT bank_statement_lines_line_number_check CHECK ((line_number > 0))
);


--
-- Name: bank_statements; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.bank_statements (
    statement_id uuid DEFAULT gen_random_uuid() NOT NULL,
    bank_account_id uuid NOT NULL,
    external_statement_reference character varying(200) NOT NULL,
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    source_file_reference character varying(500),
    imported_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bank_statements_check CHECK ((period_end > period_start))
);


--
-- Name: fund_reservations; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.fund_reservations (
    reservation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    settlement_batch_id uuid NOT NULL,
    source_account_id uuid NOT NULL,
    reserved_account_id uuid NOT NULL,
    amount_minor bigint NOT NULL,
    status character varying(40) NOT NULL,
    reservation_journal_entry_id uuid NOT NULL,
    release_journal_entry_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    closed_at timestamp with time zone,
    CONSTRAINT fund_reservations_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT fund_reservations_check CHECK ((source_account_id <> reserved_account_id)),
    CONSTRAINT fund_reservations_check1 CHECK ((release_journal_entry_id IS DISTINCT FROM reservation_journal_entry_id))
);


--
-- Name: idempotency_requests; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.idempotency_requests (
    request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    request_scope character varying(200) NOT NULL,
    idempotency_key character varying(200) NOT NULL,
    request_fingerprint character varying(128) NOT NULL,
    payment_id uuid,
    operation_id uuid,
    payout_id uuid,
    status character varying(40) NOT NULL,
    response_code integer,
    response_body jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT idempotency_requests_response_code_check CHECK (((response_code >= 100) AND (response_code <= 599)))
);


--
-- Name: journal_entries; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.journal_entries (
    journal_entry_id uuid DEFAULT gen_random_uuid() NOT NULL,
    posting_key character varying(250) NOT NULL,
    operation_id uuid,
    payout_id uuid,
    reversal_of_entry_id uuid,
    event_type character varying(50) NOT NULL,
    currency character varying(3) NOT NULL,
    description character varying(500),
    effective_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT journal_entries_check CHECK ((reversal_of_entry_id IS DISTINCT FROM journal_entry_id)),
    CONSTRAINT journal_entries_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text))
);


--
-- Name: journal_lines; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.journal_lines (
    journal_line_id uuid DEFAULT gen_random_uuid() NOT NULL,
    journal_entry_id uuid NOT NULL,
    account_id uuid NOT NULL,
    line_number integer NOT NULL,
    side character varying(6) NOT NULL,
    amount_minor bigint NOT NULL,
    CONSTRAINT journal_lines_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT journal_lines_line_number_check CHECK ((line_number > 0)),
    CONSTRAINT journal_lines_side_check CHECK (((side)::text = ANY ((ARRAY['DEBIT'::character varying, 'CREDIT'::character varying])::text[])))
);


--
-- Name: ledger_accounts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.ledger_accounts (
    account_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid,
    account_code character varying(150) NOT NULL,
    name character varying(200) NOT NULL,
    account_type character varying(30) NOT NULL,
    currency character varying(3) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ledger_accounts_account_type_check CHECK (((account_type)::text = ANY ((ARRAY['ASSET'::character varying, 'LIABILITY'::character varying, 'REVENUE'::character varying, 'EXPENSE'::character varying, 'EQUITY'::character varying])::text[]))),
    CONSTRAINT ledger_accounts_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text))
);


--
-- Name: merchant_provider_accounts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.merchant_provider_accounts (
    merchant_provider_account_id uuid DEFAULT gen_random_uuid() CONSTRAINT merchant_provider_accounts_merchant_provider_account_i_not_null NOT NULL,
    merchant_id uuid NOT NULL,
    provider_id uuid NOT NULL,
    external_account_reference character varying(200) NOT NULL,
    credential_secret_reference character varying(500),
    status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: merchants; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.merchants (
    merchant_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(200) NOT NULL,
    onboarding_status character varying(30) NOT NULL,
    processing_status character varying(30) NOT NULL,
    payout_status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: outbox_events; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.outbox_events (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    payment_id uuid,
    payout_id uuid,
    event_type character varying(100) NOT NULL,
    schema_version integer DEFAULT 1 NOT NULL,
    payload jsonb NOT NULL,
    status character varying(40) NOT NULL,
    publish_attempt_count integer DEFAULT 0 NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    CONSTRAINT outbox_events_publish_attempt_count_check CHECK ((publish_attempt_count >= 0)),
    CONSTRAINT outbox_events_schema_version_check CHECK ((schema_version > 0))
);


--
-- Name: payment_operations; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payment_operations (
    operation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    parent_operation_id uuid,
    operation_type character varying(30) NOT NULL,
    amount_minor bigint NOT NULL,
    status character varying(40) NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT payment_operations_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT payment_operations_check CHECK ((parent_operation_id IS DISTINCT FROM operation_id)),
    CONSTRAINT payment_operations_operation_type_check CHECK (((operation_type)::text = ANY ((ARRAY['AUTHORIZE'::character varying, 'CHARGE'::character varying, 'CAPTURE'::character varying, 'VOID'::character varying, 'REFUND'::character varying])::text[]))),
    CONSTRAINT payment_operations_version_check CHECK ((version >= 0))
);


--
-- Name: payment_status_history; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payment_status_history (
    history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    payment_version bigint NOT NULL,
    old_status character varying(40),
    new_status character varying(40) NOT NULL,
    reason character varying(300),
    source_inbox_event_id uuid,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payment_status_history_payment_version_check CHECK ((payment_version >= 0))
);


--
-- Name: payments; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payments (
    payment_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    merchant_order_reference character varying(200),
    amount_minor bigint NOT NULL,
    currency character varying(3) NOT NULL,
    payment_method_type character varying(50) NOT NULL,
    status character varying(40) NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT payments_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text)),
    CONSTRAINT payments_version_check CHECK ((version >= 0))
);


--
-- Name: payout_attempts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payout_attempts (
    payout_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payout_id uuid NOT NULL,
    bank_account_id uuid NOT NULL,
    attempt_number integer NOT NULL,
    external_idempotency_key character varying(200) NOT NULL,
    bank_reference character varying(200),
    status character varying(40) NOT NULL,
    error_code character varying(100),
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    last_checked_at timestamp with time zone,
    resolved_at timestamp with time zone,
    CONSTRAINT payout_attempts_attempt_number_check CHECK ((attempt_number > 0))
);


--
-- Name: payout_destinations; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payout_destinations (
    payout_destination_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    bank_account_token character varying(300) NOT NULL,
    account_holder_name character varying(200) NOT NULL,
    currency character varying(3) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payout_destinations_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text))
);


--
-- Name: payouts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.payouts (
    payout_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reservation_id uuid NOT NULL,
    payout_destination_id uuid NOT NULL,
    amount_minor bigint NOT NULL,
    currency character varying(3) NOT NULL,
    status character varying(40) NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT payouts_amount_minor_check CHECK ((amount_minor > 0)),
    CONSTRAINT payouts_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text)),
    CONSTRAINT payouts_version_check CHECK ((version >= 0))
);


--
-- Name: provider_attempts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.provider_attempts (
    attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation_id uuid NOT NULL,
    merchant_provider_account_id uuid NOT NULL,
    attempt_number integer NOT NULL,
    provider_request_scope character varying(100) NOT NULL,
    provider_idempotency_key character varying(200) NOT NULL,
    provider_reference character varying(200),
    status character varying(40) NOT NULL,
    provider_status character varying(100),
    error_code character varying(100),
    next_action jsonb,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    last_checked_at timestamp with time zone,
    resolved_at timestamp with time zone,
    CONSTRAINT provider_attempts_attempt_number_check CHECK ((attempt_number > 0))
);


--
-- Name: provider_inbox_events; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.provider_inbox_events (
    inbox_event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_provider_account_id uuid NOT NULL,
    attempt_id uuid,
    deduplication_key character varying(250) NOT NULL,
    event_type character varying(100) NOT NULL,
    payload jsonb NOT NULL,
    status character varying(40) NOT NULL,
    processing_attempt_count integer DEFAULT 0 NOT NULL,
    last_error text,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    verified_at timestamp with time zone NOT NULL,
    processed_at timestamp with time zone,
    next_attempt_at timestamp with time zone,
    CONSTRAINT provider_inbox_events_processing_attempt_count_check CHECK ((processing_attempt_count >= 0))
);


--
-- Name: providers; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.providers (
    provider_id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: reconciliation_cases; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.reconciliation_cases (
    case_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statement_line_id uuid,
    journal_entry_id uuid,
    payment_id uuid,
    payout_id uuid,
    reason character varying(100) NOT NULL,
    status character varying(40) NOT NULL,
    resolution_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone
);


--
-- Name: reconciliation_matches; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.reconciliation_matches (
    statement_line_id uuid NOT NULL,
    journal_line_id uuid NOT NULL,
    matched_amount_minor bigint NOT NULL,
    match_method character varying(30) NOT NULL,
    matched_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reconciliation_matches_matched_amount_minor_check CHECK ((matched_amount_minor > 0))
);


--
-- Name: settlement_batches; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.settlement_batches (
    settlement_batch_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    batch_reference character varying(200) NOT NULL,
    currency character varying(3) NOT NULL,
    status character varying(40) NOT NULL,
    cutoff_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    finalized_at timestamp with time zone,
    CONSTRAINT settlement_batches_currency_check CHECK (((currency)::text ~ '^[A-Z]{3}$'::text))
);


--
-- Name: settlement_items; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.settlement_items (
    settlement_item_id uuid DEFAULT gen_random_uuid() NOT NULL,
    settlement_batch_id uuid NOT NULL,
    source_journal_line_id uuid NOT NULL,
    item_type character varying(30) NOT NULL,
    signed_amount_minor bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT settlement_items_signed_amount_minor_check CHECK ((signed_amount_minor <> 0))
);


--
-- Name: transactions; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.transactions (
    id uuid NOT NULL,
    merchant_id character varying(100) NOT NULL,
    request_key character varying(128) NOT NULL,
    amount_minor bigint NOT NULL,
    currency character varying(3) NOT NULL,
    status character varying(20) DEFAULT 'CREATED'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT transactions_currency_format CHECK (((currency)::text ~ '^[A-Z]{3}$'::text)),
    CONSTRAINT transactions_initial_status CHECK (((status)::text = 'CREATED'::text)),
    CONSTRAINT transactions_merchant_not_blank CHECK ((length(btrim((merchant_id)::text)) > 0)),
    CONSTRAINT transactions_positive_amount CHECK ((amount_minor > 0)),
    CONSTRAINT transactions_request_key_not_blank CHECK ((length(btrim((request_key)::text)) > 0))
);


--
-- Name: webhook_deliveries; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.webhook_deliveries (
    delivery_id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    endpoint_id uuid NOT NULL,
    destination_url_snapshot character varying(2000) NOT NULL,
    status character varying(40) NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    next_attempt_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    delivered_at timestamp with time zone,
    CONSTRAINT webhook_deliveries_attempt_count_check CHECK ((attempt_count >= 0))
);


--
-- Name: webhook_delivery_attempts; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.webhook_delivery_attempts (
    delivery_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    delivery_id uuid NOT NULL,
    attempt_number integer NOT NULL,
    http_status integer,
    error_code character varying(100),
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    CONSTRAINT webhook_delivery_attempts_attempt_number_check CHECK ((attempt_number > 0)),
    CONSTRAINT webhook_delivery_attempts_http_status_check CHECK (((http_status >= 100) AND (http_status <= 599)))
);


--
-- Name: webhook_endpoints; Type: TABLE; Schema: paymesh; Owner: -
--

CREATE TABLE paymesh.webhook_endpoints (
    endpoint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    merchant_id uuid NOT NULL,
    url character varying(2000) NOT NULL,
    signing_secret_reference character varying(500) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bank_accounts bank_accounts_bank_code_external_account_token_currency_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_accounts
    ADD CONSTRAINT bank_accounts_bank_code_external_account_token_currency_key UNIQUE (bank_code, external_account_token, currency);


--
-- Name: bank_accounts bank_accounts_cash_ledger_account_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_accounts
    ADD CONSTRAINT bank_accounts_cash_ledger_account_id_key UNIQUE (cash_ledger_account_id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (bank_account_id);


--
-- Name: bank_statement_lines bank_statement_lines_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statement_lines
    ADD CONSTRAINT bank_statement_lines_pkey PRIMARY KEY (statement_line_id);


--
-- Name: bank_statement_lines bank_statement_lines_statement_id_line_number_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statement_lines
    ADD CONSTRAINT bank_statement_lines_statement_id_line_number_key UNIQUE (statement_id, line_number);


--
-- Name: bank_statements bank_statements_bank_account_id_external_statement_referenc_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statements
    ADD CONSTRAINT bank_statements_bank_account_id_external_statement_referenc_key UNIQUE (bank_account_id, external_statement_reference);


--
-- Name: bank_statements bank_statements_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statements
    ADD CONSTRAINT bank_statements_pkey PRIMARY KEY (statement_id);


--
-- Name: fund_reservations fund_reservations_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_pkey PRIMARY KEY (reservation_id);


--
-- Name: fund_reservations fund_reservations_release_journal_entry_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_release_journal_entry_id_key UNIQUE (release_journal_entry_id);


--
-- Name: fund_reservations fund_reservations_reservation_journal_entry_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_reservation_journal_entry_id_key UNIQUE (reservation_journal_entry_id);


--
-- Name: idempotency_requests idempotency_requests_merchant_id_request_scope_idempotency__key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_merchant_id_request_scope_idempotency__key UNIQUE (merchant_id, request_scope, idempotency_key);


--
-- Name: idempotency_requests idempotency_requests_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_pkey PRIMARY KEY (request_id);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (journal_entry_id);


--
-- Name: journal_entries journal_entries_posting_key_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_entries
    ADD CONSTRAINT journal_entries_posting_key_key UNIQUE (posting_key);


--
-- Name: journal_lines journal_lines_journal_entry_id_line_number_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_lines
    ADD CONSTRAINT journal_lines_journal_entry_id_line_number_key UNIQUE (journal_entry_id, line_number);


--
-- Name: journal_lines journal_lines_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_lines
    ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (journal_line_id);


--
-- Name: ledger_accounts ledger_accounts_account_code_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.ledger_accounts
    ADD CONSTRAINT ledger_accounts_account_code_key UNIQUE (account_code);


--
-- Name: ledger_accounts ledger_accounts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.ledger_accounts
    ADD CONSTRAINT ledger_accounts_pkey PRIMARY KEY (account_id);


--
-- Name: merchant_provider_accounts merchant_provider_accounts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.merchant_provider_accounts
    ADD CONSTRAINT merchant_provider_accounts_pkey PRIMARY KEY (merchant_provider_account_id);


--
-- Name: merchant_provider_accounts merchant_provider_accounts_provider_id_external_account_ref_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.merchant_provider_accounts
    ADD CONSTRAINT merchant_provider_accounts_provider_id_external_account_ref_key UNIQUE (provider_id, external_account_reference);


--
-- Name: merchants merchants_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.merchants
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (merchant_id);


--
-- Name: outbox_events outbox_events_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.outbox_events
    ADD CONSTRAINT outbox_events_pkey PRIMARY KEY (event_id);


--
-- Name: payment_operations payment_operations_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_operations
    ADD CONSTRAINT payment_operations_pkey PRIMARY KEY (operation_id);


--
-- Name: payment_status_history payment_status_history_payment_id_payment_version_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_status_history
    ADD CONSTRAINT payment_status_history_payment_id_payment_version_key UNIQUE (payment_id, payment_version);


--
-- Name: payment_status_history payment_status_history_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_status_history
    ADD CONSTRAINT payment_status_history_pkey PRIMARY KEY (history_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: payout_attempts payout_attempts_bank_account_id_external_idempotency_key_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_attempts
    ADD CONSTRAINT payout_attempts_bank_account_id_external_idempotency_key_key UNIQUE (bank_account_id, external_idempotency_key);


--
-- Name: payout_attempts payout_attempts_payout_id_attempt_number_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_attempts
    ADD CONSTRAINT payout_attempts_payout_id_attempt_number_key UNIQUE (payout_id, attempt_number);


--
-- Name: payout_attempts payout_attempts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_attempts
    ADD CONSTRAINT payout_attempts_pkey PRIMARY KEY (payout_attempt_id);


--
-- Name: payout_destinations payout_destinations_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_destinations
    ADD CONSTRAINT payout_destinations_pkey PRIMARY KEY (payout_destination_id);


--
-- Name: payouts payouts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payouts
    ADD CONSTRAINT payouts_pkey PRIMARY KEY (payout_id);


--
-- Name: payouts payouts_reservation_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payouts
    ADD CONSTRAINT payouts_reservation_id_key UNIQUE (reservation_id);


--
-- Name: provider_attempts provider_attempts_merchant_provider_account_id_provider_req_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_attempts
    ADD CONSTRAINT provider_attempts_merchant_provider_account_id_provider_req_key UNIQUE (merchant_provider_account_id, provider_request_scope, provider_idempotency_key);


--
-- Name: provider_attempts provider_attempts_operation_id_attempt_number_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_attempts
    ADD CONSTRAINT provider_attempts_operation_id_attempt_number_key UNIQUE (operation_id, attempt_number);


--
-- Name: provider_attempts provider_attempts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_attempts
    ADD CONSTRAINT provider_attempts_pkey PRIMARY KEY (attempt_id);


--
-- Name: provider_inbox_events provider_inbox_events_merchant_provider_account_id_deduplic_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_inbox_events
    ADD CONSTRAINT provider_inbox_events_merchant_provider_account_id_deduplic_key UNIQUE (merchant_provider_account_id, deduplication_key);


--
-- Name: provider_inbox_events provider_inbox_events_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_inbox_events
    ADD CONSTRAINT provider_inbox_events_pkey PRIMARY KEY (inbox_event_id);


--
-- Name: providers providers_code_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.providers
    ADD CONSTRAINT providers_code_key UNIQUE (code);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (provider_id);


--
-- Name: reconciliation_cases reconciliation_cases_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_cases
    ADD CONSTRAINT reconciliation_cases_pkey PRIMARY KEY (case_id);


--
-- Name: reconciliation_matches reconciliation_matches_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_matches
    ADD CONSTRAINT reconciliation_matches_pkey PRIMARY KEY (statement_line_id, journal_line_id);


--
-- Name: settlement_batches settlement_batches_batch_reference_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_batches
    ADD CONSTRAINT settlement_batches_batch_reference_key UNIQUE (batch_reference);


--
-- Name: settlement_batches settlement_batches_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_batches
    ADD CONSTRAINT settlement_batches_pkey PRIMARY KEY (settlement_batch_id);


--
-- Name: settlement_items settlement_items_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_items
    ADD CONSTRAINT settlement_items_pkey PRIMARY KEY (settlement_item_id);


--
-- Name: settlement_items settlement_items_source_journal_line_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_items
    ADD CONSTRAINT settlement_items_source_journal_line_id_key UNIQUE (source_journal_line_id);


--
-- Name: transactions transactions_merchant_request_unique; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.transactions
    ADD CONSTRAINT transactions_merchant_request_unique UNIQUE (merchant_id, request_key);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: webhook_deliveries webhook_deliveries_event_id_endpoint_id_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_event_id_endpoint_id_key UNIQUE (event_id, endpoint_id);


--
-- Name: webhook_deliveries webhook_deliveries_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_pkey PRIMARY KEY (delivery_id);


--
-- Name: webhook_delivery_attempts webhook_delivery_attempts_delivery_id_attempt_number_key; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_delivery_attempts
    ADD CONSTRAINT webhook_delivery_attempts_delivery_id_attempt_number_key UNIQUE (delivery_id, attempt_number);


--
-- Name: webhook_delivery_attempts webhook_delivery_attempts_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_delivery_attempts
    ADD CONSTRAINT webhook_delivery_attempts_pkey PRIMARY KEY (delivery_attempt_id);


--
-- Name: webhook_endpoints webhook_endpoints_pkey; Type: CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_endpoints
    ADD CONSTRAINT webhook_endpoints_pkey PRIMARY KEY (endpoint_id);


--
-- Name: bank_statement_lines_reference_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX bank_statement_lines_reference_idx ON paymesh.bank_statement_lines USING btree (external_transaction_reference);


--
-- Name: fund_reservations_batch_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX fund_reservations_batch_idx ON paymesh.fund_reservations USING btree (settlement_batch_id);


--
-- Name: fund_reservations_source_status_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX fund_reservations_source_status_idx ON paymesh.fund_reservations USING btree (source_account_id, status);


--
-- Name: journal_entries_effective_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX journal_entries_effective_idx ON paymesh.journal_entries USING btree (effective_at);


--
-- Name: journal_entries_operation_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX journal_entries_operation_idx ON paymesh.journal_entries USING btree (operation_id);


--
-- Name: journal_entries_payout_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX journal_entries_payout_idx ON paymesh.journal_entries USING btree (payout_id);


--
-- Name: journal_lines_account_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX journal_lines_account_idx ON paymesh.journal_lines USING btree (account_id);


--
-- Name: ledger_accounts_merchant_currency_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX ledger_accounts_merchant_currency_idx ON paymesh.ledger_accounts USING btree (merchant_id, currency);


--
-- Name: merchant_provider_accounts_merchant_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX merchant_provider_accounts_merchant_idx ON paymesh.merchant_provider_accounts USING btree (merchant_id);


--
-- Name: outbox_events_available_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX outbox_events_available_idx ON paymesh.outbox_events USING btree (status, available_at);


--
-- Name: outbox_events_payment_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX outbox_events_payment_idx ON paymesh.outbox_events USING btree (payment_id);


--
-- Name: outbox_events_payout_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX outbox_events_payout_idx ON paymesh.outbox_events USING btree (payout_id);


--
-- Name: payment_operations_parent_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payment_operations_parent_idx ON paymesh.payment_operations USING btree (parent_operation_id);


--
-- Name: payment_operations_payment_created_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payment_operations_payment_created_idx ON paymesh.payment_operations USING btree (payment_id, created_at);


--
-- Name: payments_merchant_created_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payments_merchant_created_idx ON paymesh.payments USING btree (merchant_id, created_at);


--
-- Name: payments_merchant_order_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payments_merchant_order_idx ON paymesh.payments USING btree (merchant_id, merchant_order_reference);


--
-- Name: payout_attempts_reference_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payout_attempts_reference_idx ON paymesh.payout_attempts USING btree (bank_account_id, bank_reference);


--
-- Name: payout_destinations_merchant_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payout_destinations_merchant_idx ON paymesh.payout_destinations USING btree (merchant_id);


--
-- Name: payouts_destination_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payouts_destination_idx ON paymesh.payouts USING btree (payout_destination_id);


--
-- Name: payouts_status_created_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX payouts_status_created_idx ON paymesh.payouts USING btree (status, created_at);


--
-- Name: provider_attempts_reference_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX provider_attempts_reference_idx ON paymesh.provider_attempts USING btree (merchant_provider_account_id, provider_reference);


--
-- Name: provider_attempts_status_check_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX provider_attempts_status_check_idx ON paymesh.provider_attempts USING btree (status, last_checked_at);


--
-- Name: provider_inbox_events_attempt_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX provider_inbox_events_attempt_idx ON paymesh.provider_inbox_events USING btree (attempt_id);


--
-- Name: provider_inbox_events_retry_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX provider_inbox_events_retry_idx ON paymesh.provider_inbox_events USING btree (status, next_attempt_at);


--
-- Name: reconciliation_cases_status_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX reconciliation_cases_status_idx ON paymesh.reconciliation_cases USING btree (status, created_at);


--
-- Name: reconciliation_matches_journal_line_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX reconciliation_matches_journal_line_idx ON paymesh.reconciliation_matches USING btree (journal_line_id);


--
-- Name: settlement_batches_merchant_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX settlement_batches_merchant_idx ON paymesh.settlement_batches USING btree (merchant_id, currency, created_at);


--
-- Name: settlement_items_batch_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX settlement_items_batch_idx ON paymesh.settlement_items USING btree (settlement_batch_id);


--
-- Name: webhook_deliveries_retry_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX webhook_deliveries_retry_idx ON paymesh.webhook_deliveries USING btree (status, next_attempt_at);


--
-- Name: webhook_endpoints_merchant_idx; Type: INDEX; Schema: paymesh; Owner: -
--

CREATE INDEX webhook_endpoints_merchant_idx ON paymesh.webhook_endpoints USING btree (merchant_id);


--
-- Name: bank_accounts bank_accounts_cash_ledger_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_accounts
    ADD CONSTRAINT bank_accounts_cash_ledger_account_id_fkey FOREIGN KEY (cash_ledger_account_id) REFERENCES paymesh.ledger_accounts(account_id);


--
-- Name: bank_statement_lines bank_statement_lines_statement_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statement_lines
    ADD CONSTRAINT bank_statement_lines_statement_id_fkey FOREIGN KEY (statement_id) REFERENCES paymesh.bank_statements(statement_id);


--
-- Name: bank_statements bank_statements_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.bank_statements
    ADD CONSTRAINT bank_statements_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES paymesh.bank_accounts(bank_account_id);


--
-- Name: fund_reservations fund_reservations_release_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_release_journal_entry_id_fkey FOREIGN KEY (release_journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id);


--
-- Name: fund_reservations fund_reservations_reservation_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_reservation_journal_entry_id_fkey FOREIGN KEY (reservation_journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id);


--
-- Name: fund_reservations fund_reservations_reserved_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_reserved_account_id_fkey FOREIGN KEY (reserved_account_id) REFERENCES paymesh.ledger_accounts(account_id);


--
-- Name: fund_reservations fund_reservations_settlement_batch_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_settlement_batch_id_fkey FOREIGN KEY (settlement_batch_id) REFERENCES paymesh.settlement_batches(settlement_batch_id);


--
-- Name: fund_reservations fund_reservations_source_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.fund_reservations
    ADD CONSTRAINT fund_reservations_source_account_id_fkey FOREIGN KEY (source_account_id) REFERENCES paymesh.ledger_accounts(account_id);


--
-- Name: idempotency_requests idempotency_requests_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: idempotency_requests idempotency_requests_operation_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id);


--
-- Name: idempotency_requests idempotency_requests_payment_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id);


--
-- Name: idempotency_requests idempotency_requests_payout_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.idempotency_requests
    ADD CONSTRAINT idempotency_requests_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id);


--
-- Name: journal_entries journal_entries_operation_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_entries
    ADD CONSTRAINT journal_entries_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id);


--
-- Name: journal_entries journal_entries_payout_fk; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_entries
    ADD CONSTRAINT journal_entries_payout_fk FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id);


--
-- Name: journal_entries journal_entries_reversal_of_entry_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_entries
    ADD CONSTRAINT journal_entries_reversal_of_entry_id_fkey FOREIGN KEY (reversal_of_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id);


--
-- Name: journal_lines journal_lines_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_lines
    ADD CONSTRAINT journal_lines_account_id_fkey FOREIGN KEY (account_id) REFERENCES paymesh.ledger_accounts(account_id);


--
-- Name: journal_lines journal_lines_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.journal_lines
    ADD CONSTRAINT journal_lines_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id);


--
-- Name: ledger_accounts ledger_accounts_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.ledger_accounts
    ADD CONSTRAINT ledger_accounts_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: merchant_provider_accounts merchant_provider_accounts_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.merchant_provider_accounts
    ADD CONSTRAINT merchant_provider_accounts_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: merchant_provider_accounts merchant_provider_accounts_provider_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.merchant_provider_accounts
    ADD CONSTRAINT merchant_provider_accounts_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES paymesh.providers(provider_id);


--
-- Name: outbox_events outbox_events_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.outbox_events
    ADD CONSTRAINT outbox_events_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: outbox_events outbox_events_payment_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.outbox_events
    ADD CONSTRAINT outbox_events_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id);


--
-- Name: outbox_events outbox_events_payout_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.outbox_events
    ADD CONSTRAINT outbox_events_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id);


--
-- Name: payment_operations payment_operations_parent_operation_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_operations
    ADD CONSTRAINT payment_operations_parent_operation_id_fkey FOREIGN KEY (parent_operation_id) REFERENCES paymesh.payment_operations(operation_id);


--
-- Name: payment_operations payment_operations_payment_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_operations
    ADD CONSTRAINT payment_operations_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id);


--
-- Name: payment_status_history payment_status_history_payment_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_status_history
    ADD CONSTRAINT payment_status_history_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id);


--
-- Name: payment_status_history payment_status_history_source_inbox_event_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payment_status_history
    ADD CONSTRAINT payment_status_history_source_inbox_event_id_fkey FOREIGN KEY (source_inbox_event_id) REFERENCES paymesh.provider_inbox_events(inbox_event_id);


--
-- Name: payments payments_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payments
    ADD CONSTRAINT payments_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: payout_attempts payout_attempts_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_attempts
    ADD CONSTRAINT payout_attempts_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES paymesh.bank_accounts(bank_account_id);


--
-- Name: payout_attempts payout_attempts_payout_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_attempts
    ADD CONSTRAINT payout_attempts_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id);


--
-- Name: payout_destinations payout_destinations_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payout_destinations
    ADD CONSTRAINT payout_destinations_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: payouts payouts_payout_destination_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payouts
    ADD CONSTRAINT payouts_payout_destination_id_fkey FOREIGN KEY (payout_destination_id) REFERENCES paymesh.payout_destinations(payout_destination_id);


--
-- Name: payouts payouts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.payouts
    ADD CONSTRAINT payouts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES paymesh.fund_reservations(reservation_id);


--
-- Name: provider_attempts provider_attempts_merchant_provider_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_attempts
    ADD CONSTRAINT provider_attempts_merchant_provider_account_id_fkey FOREIGN KEY (merchant_provider_account_id) REFERENCES paymesh.merchant_provider_accounts(merchant_provider_account_id);


--
-- Name: provider_attempts provider_attempts_operation_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_attempts
    ADD CONSTRAINT provider_attempts_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES paymesh.payment_operations(operation_id);


--
-- Name: provider_inbox_events provider_inbox_events_attempt_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_inbox_events
    ADD CONSTRAINT provider_inbox_events_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES paymesh.provider_attempts(attempt_id);


--
-- Name: provider_inbox_events provider_inbox_events_merchant_provider_account_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.provider_inbox_events
    ADD CONSTRAINT provider_inbox_events_merchant_provider_account_id_fkey FOREIGN KEY (merchant_provider_account_id) REFERENCES paymesh.merchant_provider_accounts(merchant_provider_account_id);


--
-- Name: reconciliation_cases reconciliation_cases_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_cases
    ADD CONSTRAINT reconciliation_cases_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES paymesh.journal_entries(journal_entry_id);


--
-- Name: reconciliation_cases reconciliation_cases_payment_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_cases
    ADD CONSTRAINT reconciliation_cases_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES paymesh.payments(payment_id);


--
-- Name: reconciliation_cases reconciliation_cases_payout_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_cases
    ADD CONSTRAINT reconciliation_cases_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES paymesh.payouts(payout_id);


--
-- Name: reconciliation_cases reconciliation_cases_statement_line_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_cases
    ADD CONSTRAINT reconciliation_cases_statement_line_id_fkey FOREIGN KEY (statement_line_id) REFERENCES paymesh.bank_statement_lines(statement_line_id);


--
-- Name: reconciliation_matches reconciliation_matches_journal_line_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_matches
    ADD CONSTRAINT reconciliation_matches_journal_line_id_fkey FOREIGN KEY (journal_line_id) REFERENCES paymesh.journal_lines(journal_line_id);


--
-- Name: reconciliation_matches reconciliation_matches_statement_line_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.reconciliation_matches
    ADD CONSTRAINT reconciliation_matches_statement_line_id_fkey FOREIGN KEY (statement_line_id) REFERENCES paymesh.bank_statement_lines(statement_line_id);


--
-- Name: settlement_batches settlement_batches_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_batches
    ADD CONSTRAINT settlement_batches_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- Name: settlement_items settlement_items_settlement_batch_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_items
    ADD CONSTRAINT settlement_items_settlement_batch_id_fkey FOREIGN KEY (settlement_batch_id) REFERENCES paymesh.settlement_batches(settlement_batch_id);


--
-- Name: settlement_items settlement_items_source_journal_line_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.settlement_items
    ADD CONSTRAINT settlement_items_source_journal_line_id_fkey FOREIGN KEY (source_journal_line_id) REFERENCES paymesh.journal_lines(journal_line_id);


--
-- Name: webhook_deliveries webhook_deliveries_endpoint_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_endpoint_id_fkey FOREIGN KEY (endpoint_id) REFERENCES paymesh.webhook_endpoints(endpoint_id);


--
-- Name: webhook_deliveries webhook_deliveries_event_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_event_id_fkey FOREIGN KEY (event_id) REFERENCES paymesh.outbox_events(event_id);


--
-- Name: webhook_delivery_attempts webhook_delivery_attempts_delivery_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_delivery_attempts
    ADD CONSTRAINT webhook_delivery_attempts_delivery_id_fkey FOREIGN KEY (delivery_id) REFERENCES paymesh.webhook_deliveries(delivery_id);


--
-- Name: webhook_endpoints webhook_endpoints_merchant_id_fkey; Type: FK CONSTRAINT; Schema: paymesh; Owner: -
--

ALTER TABLE ONLY paymesh.webhook_endpoints
    ADD CONSTRAINT webhook_endpoints_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES paymesh.merchants(merchant_id);


--
-- PostgreSQL database dump complete
--

\unrestrict SpODwGXreBJH66GyKBPtNkx5dB8UL7BcsJGLpD1hdvhJcGYboAP7cuiZ4tdfLWX
