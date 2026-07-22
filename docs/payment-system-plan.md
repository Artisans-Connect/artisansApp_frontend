# CraftMatch payments, escrow, and loyalty plan

## Summary

Implement a phased Ghana payment system around hosted checkout, provider-confirmed webhooks, and an internal immutable ledger. Start with a booking deposit held against the job, then release, refund, or apply cancellation deductions after the existing completion/termination flow. Do not launch a cash wallet initially; use refunds to the original payment method and optionally limited in-app booking credit.

This is feasible with both Paystack and Moolre. Paystack has Ghana MoMo acceptance, refunds, and GHS bank/MoMo transfers; Moolre documents hosted payment links, account/wallet balance, collections, and disbursements. Neither should be treated as automatically providing a legally complete independent escrow service. Confirm the intended "held funds" marketplace model, settlement timing, and licensing responsibilities directly with the selected provider and Ghana counsel. [Paystack payments](https://paystack.com/docs/payments/payment-channels/), [Paystack payouts](https://paystack.com/docs/transfers/single-transfers/), [Moolre payment links](https://docs.moolre.com/ai/generate-payment-link.html), [Bank of Ghana licence categories](https://www.bog.gov.gh/fintech-innovation/licence-categories/)

## Key changes

- Adopt Paystack as the initial provider unless Moolre confirms stronger written support for marketplace-held funds, split settlement, refund timing, and MoMo worker payouts. Keep a provider adapter so Moolre can be added later without rewriting job settlement.
- Use provider-hosted checkout opened from the Flutter app, with deep-link return to a "payment pending/confirmed" screen. This is suitable for the app's physical artisan services under Apple and Google store policies. [Apple guideline](https://developer.apple.com/app-store/review/guidelines/), [Google Play payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en)
- Require payment before a job can enter matching. Default to a deposit-only V1, calculated server-side from the accepted pricing policy; create no job dispatch until the backend has independently verified provider success.
- Add payment, payment-event, job-fund, settlement, payout-recipient, payout, refund, dispute, and append-only ledger records. Store GHS in minor units, never floating-point values; all transfers must have idempotency keys and provider references.
- Use the existing cancellation stages and completion approval flow to produce a settlement decision: free cancellation -> full refund; travel/arrival cancellation -> worker compensation plus refund remainder; approved completion -> worker payout minus platform fee; termination/dispute -> funds locked until an authorised resolution.
- Add an admin dispute queue with evidence, reason codes, decision maker, audit trail, partial split capability, and a defined automatic escalation deadline. Never automatically release disputed funds.
- Onboard workers with verified MoMo or bank payout details, confirmation of ownership where supported, payout limits, and manual review for changed payout details or unusual activity.
- Treat the "wallet" as an internal accounting capability, not a cash wallet. V1 supports original-method refunds; optional non-withdrawable booking credit can be used only for future CraftMatch bookings. Do not allow top-ups, peer transfers, cash-out, or interest-bearing balances without a regulated-provider/legal workstream.
- Defer loyalty rewards until payments are stable. If introduced, make points non-cash, non-transferable, earned only after a non-disputed completed job, reversible on refunds/chargebacks, and redeemable only for platform discounts. Do not market points as money or allow withdrawal.
- Update pricing, receipt, terms, privacy notice, cancellation policy, and support flows to show the deposit, platform fee, refund/cancellation rule, payout status, disputes process, and every applicable charge before payment. Ghana's PSP guidance emphasizes transparent fee disclosure and consumer recourse. [BoG transparency guidance](https://www.bog.gov.gh/wp-content/uploads/2022/09/Payment-Service-Providers-Disclosure-and-Transparency-Guidelines-for-D....pdf)

## Interfaces and security

- Add authenticated APIs to initialise/verify a job payment, retrieve payment/settlement state, submit dispute evidence, manage payout recipients, and read ledger-derived history; expose provider webhook endpoints separately.
- Verify every webhook signature, persist and deduplicate every provider event, then verify the transaction server-to-server before changing job funds. Do not trust the mobile return URL or client-reported success. [Paystack webhook guidance](https://paystack.com/docs/payments/webhooks/), [Paystack verification](https://paystack.com/docs/payments/verify-payments/)
- Restrict financial writes to transactional backend functions/service role; add reconciliation jobs that compare internal ledger totals, provider transactions, refunds, transfers, and outstanding held funds daily.
- Document provider outage, duplicate webhook, delayed MoMo authorization, refund failure, payout failure, chargeback, worker payout-detail change, and negative-balance handling before launch.

## Test and acceptance plan

- Test every job path: paid job creation, failed/abandoned checkout, duplicate callbacks, free cancellation, compensated cancellation, completion, partial/full refund, termination, dispute, payout retry, and provider outage recovery.
- Verify that an amount can never be released/refunded/payed out twice, that ledger entries always balance, and that only authorised users/admin roles can view or act on a settlement.
- Run Paystack and Moolre sandbox trials for Ghana MoMo/card collection, hosted redirect/deep links, callback signing, refund delivery, and worker MoMo/bank payout before selecting the production provider.
- Pilot with transaction caps, manual payout/dispute review, daily reconciliation, operational runbooks, and measured outcomes: payment completion rate, refund/payout failure rate, dispute rate, settlement time, and support contacts per completed job.

## Assumptions and defaults

- The target is a Ghana real-money pilot/production path using GHS and Ghana MoMo/bank payouts.
- The initial client payment is a server-calculated booking deposit, not the whole estimated job cost; the exact percentage/minimum is a business-policy decision to set after pricing and provider-fee modelling.
- CraftMatch will use its existing job lifecycle and cancellation calculations as inputs, but payment settlement becomes authoritative only after the new ledger records it.
- Legal/compliance review and a written provider confirmation are release gates, especially if "escrow" means custody of client money or if a withdrawable wallet is later requested.
