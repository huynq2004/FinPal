# FinPal Backend Proposal

## Current State
- No backend service present in the repository.
- `lib/` shows local persistence via `sqflite` and some TODO comments referencing backend actions.
- `pubspec.yaml` contains no network/backend SDKs (no `http`, `dio`, `firebase`, etc.).

## Goals
- Cloud sync and backup for user data (multi-device support).
- Authentication and user isolation (Row Level Security or equivalent).
- API for savings goals, transactions, categories, and analytics.
- Future extensibility for webhooks/SMS parsing uploads and notifications.

## Options

### A) Firebase (Firestore/Auth/Cloud Functions)
- Pros: Managed, quick setup, great Flutter support.
- Cons: No SQL, complex security rules at scale, vendor lock-in.

### B) Supabase (Postgres/Auth/Realtime/Storage) — Recommended
- Pros: SQL/Postgres, row-level security via policies, Flutter SDK, easy migrations.
- Cons: Slightly more setup than Firebase, manages DB migrations.

### C) Custom Server (Node/NestJS, FastAPI, Spring Boot)
- Pros: Full control, custom business logic and integrations.
- Cons: More maintenance (hosting, scaling, security, monitoring).

## Recommended Architecture (Supabase)
- Auth: Email/password via Supabase Auth.
- Database (Postgres):
  - `users` (managed by Supabase)
  - `savings_goals` (id, user_id, title, target_amount, deadline, status)
  - `transactions` (id, user_id, amount, currency, category_id, source, created_at, meta)
  - `categories` (id, user_id, name, icon)
- Security: Row Level Security policies ensuring users only access their rows.
- Optional RPC: `compute_savings_progress(user_id)` for summaries.

## Flutter Integration Steps
1. Add dependency:
   ```yaml
   dependencies:
     supabase_flutter: ^2.6.0
   ```
2. Initialize client (e.g., in `main.dart`):
   ```dart
   await Supabase.initialize(
     url: const String.fromEnvironment('SUPABASE_URL'),
     anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
   );
   ```
3. Create services:
   - `lib/data/remote/auth_service.dart`: signUp, signIn, signOut.
   - `lib/data/remote/savings_service.dart`: CRUD for `savings_goals`.
   - `lib/data/remote/transaction_service.dart`: CRUD + batch sync from local `sqflite`.
4. Sync strategy:
   - Keep `sqflite` for offline-first.
   - Background sync job: push local changes to Supabase when online.
   - Conflict rules: last-write-wins or server timestamp precedence.

## Migration Plan
- Phase 1: Set up Supabase project, create tables, enable RLS policies.
- Phase 2: Add Flutter services and minimal UI hooks for sign-in.
- Phase 3: Implement sync for savings goals and transactions.
- Phase 4: Migrate analytics to server-side (optional RPC/Views).

## Next Actions
- Choose backend option.
- If Supabase: provision project, share `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- I can scaffold table SQL, policies, and Flutter services upon approval.
