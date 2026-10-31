# Payment platform: business-service map

Proposed learning design · 31 October 2026. These are responsibilities, not a claim that twelve separately deployed services are required. The application does not implement this entire design yet.

Open this Markdown file in preview to see the diagram. The AWS mapping is in [02-aws-service-map.md](02-aws-service-map.md).

## Business flow

[Open the diagram](01-business-service-map.md)


Solid arrows show calls or information hand-offs as labelled. Dotted arrows show event delivery. This is a responsibility map, not one synchronous request or a diagram of money physically moving. Responses and storage mechanisms are omitted here for readability.

## What each block owns

| Number | Block | Responsibility |
|---|---|---|
| 1 | Merchant management | Registration, active/suspended status, configuration and enabled methods. |
| 2 | Authentication and authorization | Verify the caller and its permission to act for this merchant and operation. |
| 3 | Payment-method catalogue | Markets, currencies, amount rules and supported capabilities. |
| 4 | Payment orchestration | Durable acceptance, idempotency, payment state and coordination of capture, void and refund. |
| 5 | Risk and fraud | Applicable risk checks and auditable decisions. |
| 6 | Provider integration | Provider-specific request translation, submission and response interpretation. |
| 7 | Incoming outcome processing | Authenticate provider updates, deduplicate and validate state transitions. |
| 8 | Merchant notifications | Deliver status webhooks with controlled retries. |
| 9 | Financial ledger | Record balanced financial entries and obligations with stable operation identities. |
| 10 | Settlement and cashflow | Track expected, received, reserved and available funds by currency and account. |
| 11 | Reconciliation | Compare internal records with provider/bank evidence; investigate differences. |
| 12 | Payout management | Reserve eligible funds, submit a stable transfer instruction and track its outcome. |

## Read these boundaries correctly

- Merchant onboarding happens before payment processing. Checking a merchant on a payment request does not register the merchant again. An initiated registration alone does not authorize a payment.
- The customer uses the merchant's checkout and, when needed, completes authentication with the selected payment method. This diagram starts at the merchant backend.
- A successful authentication check does not grant access to every merchant's payments. Authorization checks the merchant, resource and operation.
- Payment acceptance, authorization, capture, settlement and payout are different milestones. An accepted request does not prove that money moved.
- A provider timeout can mean an unknown outcome. Reconcile or query using the original identity before submitting a new instruction.
- Ledger, cashflow and reconciliation record and reason about money. External providers and banking partners carry out the actual transfers.
- The financial-event arrow does not permit losing or duplicating ledger effects: durable hand-off, duplicate-safe application and balanced postings are required design details for later lessons.

## Next focus: cashflow and liquidity

Follow blocks 9 → 10 → 12, using block 11 as independent evidence. A synthetic example: receiving a capture notification does not automatically make those funds available for payout. Track expected settlement, confirmed receipt, reservations, fees and currency separately. Define the payout invariant before adding implementation or infrastructure.

Optional later responsibilities include disputes/chargebacks, operational cases, audit, reporting and compliance integrations. They are not implemented or expanded in this first map.
