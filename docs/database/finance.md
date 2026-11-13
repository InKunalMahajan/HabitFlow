# Finance Integrity & UX Contract

**Status:** Requirements only; not a financial application.

- Money uses integer minor units and ISO currency codes; never floating-point persisted balances.
- Each posted transaction has at least two postings and postings balance to zero **per currency**.
- Transfers debit one account and credit another; they do not count as income or expense.
- Posted entries are immutable; corrections use reversal and a replacement transaction with an audit trail.
- Balances derive from opening entries and ledger postings; do not display disconnected hardcoded balances.
- Recurring rules propose future transactions, but must not duplicate postings after retries.
- Each posting request needs an idempotency key, authorization checks, atomic transaction, and failure recovery.
- Distinguish draft, pending confirmation, posted, rejected, and reversed states visibly.
- Cross-currency transfers require explicit exchange-rate and rounding policy before support.
- Offline finance may be drafted locally; server confirmation must not be falsely implied.

## Required UX scenarios
Income, expense, same-currency transfer, reversal, insufficient funds policy, duplicate submit, offline pending, conflict, invalid amount, currency mismatch, budget update, export privacy.

**Warning:** The Phase 02D–02H prototypes are simulated and do not establish financial correctness.
