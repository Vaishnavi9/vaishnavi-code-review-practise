# What each business block does

Proposed learning design. These are logical responsibilities; they can begin as modules in one application. A separate deployment is a later decision. Numbers match [the business diagram](01-business-service-map.md).

## 1. Merchant management

Registers merchants and tracks whether they are active, suspended and enabled for particular payment methods. Authentication and authorization consult this information before allowing an operation; payment eligibility also depends on it. Onboarding happens beforehand, not on every payment request.

## 2. Authentication and authorization

Authentication verifies who is calling; authorization checks what that caller may do for a particular merchant and resource. This block checks merchant status and permissions, then passes an authorized request to payment orchestration. Merchant business permissions are separate from AWS workload permissions.

## 3. Payment-method catalogue

Describes each method's supported customer markets, currencies, amount limits and capabilities, such as refunds or delayed capture. Payment orchestration checks this catalogue together with the merchant's enabled methods. Method eligibility and choosing the actual processing provider are separate decisions.

## 4. Payment orchestration

Owns the payment's state and coordinates acceptance, idempotency and the requested payment operation. It checks catalogue and risk decisions, requests provider submission, and applies validated outcomes. Relevant durable changes drive merchant notifications and financial postings; acceptance alone does not mean money moved.

## 5. Risk and fraud

Evaluates applicable rules using the payment context and returns an allow, reject or review decision with a reason. Payment orchestration uses that decision before permitted processing continues. A risk decision does not itself submit a payment or record settlement.

## 6. Provider integration

Selects an eligible processing route in this initial design and translates the payment into the selected provider's API contract. It submits using a stable operation identity and passes responses into outcome processing; routing may later become its own module. A timeout can leave the outcome unknown, so switching providers or retrying blindly can duplicate an effect.

## 7. Incoming outcome processing

Receives immediate responses or later provider updates, verifies their source where applicable, and handles duplicates or stale information. It supplies validated outcomes to payment orchestration for controlled state transitions. It must durably record incoming updates before acknowledging receipt when loss would matter.

## 8. Merchant notifications

Receives payment-status events and delivers the merchant's configured webhook with controlled retries. Its destination is the merchant backend, not the external payment provider. The merchant must tolerate duplicate notifications; successful webhook delivery is not financial settlement.

## 9. Financial ledger

Records balanced financial entries and obligations with stable identities so duplicate events cannot create duplicate postings. It supplies accounting records to cashflow and reconciliation. Payment status and accounting position are distinct: a captured payment can still be awaiting settlement.

## 10. Settlement and cashflow

Tracks expected, received, reserved and available funds separately by account and currency. It combines ledger records with reconciliation and banking evidence to decide what funds may support a payout. It passes eligible payout instructions to payout management; concurrent reservations must not spend the same available funds twice.

## 11. Reconciliation

Compares internal ledger records against provider reports and bank statements to find matches, missing evidence and differences. It sends supported results or exceptions to settlement and cashflow. A discrepancy creates an investigation or controlled correction; it must not silently overwrite financial history.

## 12. Payout management

Coordinates a payout request, the required funds reservation and a stable instruction to a banking partner. It records the instruction's progress and uses bank outcomes with cashflow to release or complete reservations safely. Its logical boundary can share an application and database with cashflow initially; a separate microservice needs a justified ownership and consistency design.

## External participants

**Merchant backend:** starts payment operations and receives status webhooks. The shopper uses the merchant's checkout; the backend calls our platform on the merchant's behalf.

**External payment provider:** processes the customer's selected payment method and returns immediate or later outcome information. Our provider-integration block communicates with it.

**External banking partner:** executes or reports transfers such as merchant payouts and supplies banking evidence. These are distinct roles, but one organization can supply both payment-provider and banking services.

**Provider reports and bank statements:** external evidence consumed by reconciliation, not another service that we implement.

## Business blocks versus hosting

EKS is an optional AWS hosting technology for our applications. It does not supply merchant-management, payment or cashflow business rules. Likewise a load balancer and an API gateway are supporting infrastructure responsibilities, explained separately from these twelve business blocks.
