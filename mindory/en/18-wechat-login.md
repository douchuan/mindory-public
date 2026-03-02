# Designing a Robust Account System with WeChat Login: Lessons from a Dangerous Unique Constraint

When building a production-grade account system with WeChat login, it’s tempting to treat soft deletion as a harmless implementation detail.

It’s not.

One specific schema design decision can quietly introduce identity duplication, broken subscriptions, incorrect analytics, and even security loopholes.

This article explains:

- Why `@@unique([appId, openId, isDeleted])` is dangerous
- How it causes identity fragmentation
- Why `@@unique([appId, openId])` is the correct design
- The core principle behind stable identity systems

---

## Context: WeChat Identity Model

In WeChat:

- `openId` is unique **within a single appId**
- `unionId` is unique **across apps** (same user across platforms)

This means:

> `(appId, openId)` represents a stable real-world identity.

Your database must reflect that invariant.

---

# The Dangerous Constraint

```prisma
@@unique([appId, openId, isDeleted])
````

At first glance, this looks harmless.

The idea is:

* Allow one active record
* Allow one soft-deleted record
* Prevent exact duplicates

But this constraint fundamentally changes identity semantics.

---

## What This Constraint Actually Allows

With:

```prisma
@@unique([appId, openId, isDeleted])
```

The database allows:

| appId | openId | isDeleted |
| ----- | ------ | --------- |
| A     | X      | false     |
| A     | X      | true      |

These are considered different records.

Which means:

> The same WeChat identity can exist multiple times.

This is where the problems begin.

---

# Problem 1: Identity Fragmentation

Imagine this sequence:

1. User logs in → creates `UserA`
2. User purchases subscription
3. User account is soft deleted (`isDeleted = true`)
4. User logs in again
5. System creates a new `UserB`

Now:

* `UserA` holds subscription history
* `UserB` is a fresh account
* Both correspond to the same WeChat identity

The system now has two internal users for one real human.

That’s identity fragmentation.

---

# Problem 2: Broken Subscriptions

Since subscription records belong to `UserA`, the newly created `UserB`:

* Has no active plan
* Has no expiration date
* Appears as a free user

From the user’s perspective:

> “I paid. Why is my membership gone?”

From the system’s perspective:

> It created a second account.

This is a business-critical failure.

---

# Problem 3: Analytics Corruption

Analytics tables often reference `userId`.

With identity duplication:

* Daily Active Users become inflated
* Lifetime Value becomes incorrect
* Conversion rates become misleading
* Retention metrics become unreliable

You lose data integrity at the business level.

---

# Problem 4: Security and Ban Evasion

Suppose:

* `UserA` is banned
* `isDeleted = true`
* User logs in again
* System creates `UserB`

The ban is bypassed.

Why?

Because identity was allowed to be re-created.

---

# Problem 5: UnionId Merge Becomes a Nightmare

If you support multiple apps (Desktop, Mobile, SaaS):

* Same person → different openIds
* Same unionId

If identity can be duplicated internally, merging accounts becomes complex:

* Which user is canonical?
* Where do subscriptions move?
* How do you reconcile quotas?
* What about event history?

This complexity is self-inflicted.

---

# Root Cause

The root issue is conceptual:

You treated identity as versioned.

But identity must be stable.

Soft deletion is a **state change**, not an **identity reset**.

---

# The Correct Constraint

```prisma
@@unique([appId, openId])
```

This enforces:

* Only one record per WeChat identity
* No duplicate identity creation
* No accidental fragmentation

With this constraint:

If a user logs in again:

* You must restore the existing record
* You cannot create a new one

That is exactly what you want.

---

# Correct Deletion Strategy

Do NOT delete or recreate identity records.

Instead:

### Deactivate User

```prisma
status = DELETED
deletedAt = now()
```

### On Re-login

* Find existing `(appId, openId)`
* Restore user status
* Keep all historical data intact

Identity remains stable.

State changes.

---

# Identity Systems Must Follow This Rule

External identity providers (WeChat, Google, Apple):

> Identity is immutable.

Your internal system must mirror that immutability.

Allowing identity recreation leads to:

* Business logic corruption
* Financial inconsistencies
* Security loopholes
* Data analytics failure

---

# Final Comparison

### ❌ Dangerous

```prisma
@@unique([appId, openId, isDeleted])
```

Allows identity duplication across deletion states.

---

### ✅ Correct

```prisma
@@unique([appId, openId])
```

Enforces identity stability and prevents fragmentation.

---

# Final Takeaway

In account systems:

* Identity must be unique and permanent.
* Deletion should change status, not recreate identity.
* Financial history must never detach from identity.
* External identity must map to exactly one internal user.

If you design identity correctly early on,

you prevent years of painful migration, data repair, and business risk.

Design it wrong,

and you build instability into the foundation of your system.