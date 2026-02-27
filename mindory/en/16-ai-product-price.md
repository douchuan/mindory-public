# Designing a Growth-Phase Pricing Model for an AI Product

## 1. Background

Mindory is an AI-powered product built to deliver real cognitive value to users.  
At this stage, the priority is **growth**, not short-term profit maximization.

However, growth does not mean burning money blindly.

A sustainable growth-phase pricing system must:

- Keep entry barriers low
- Ensure non-negative gross margin
- Control infrastructure risks
- Scale predictably
- Increase long-term valuation potential
- Remain attractive for future acquisition

This document outlines a structured pricing strategy designed specifically for the growth phase of an AI-native product.

---

# 2. Growth-Phase Principles

Early-stage AI/SaaS pricing is fundamentally different from mature SaaS pricing.

## Priority Order in Growth Phase

1. User scale  
2. Retention  
3. Usage depth  
4. Data asset accumulation  
5. Monetization  
6. Profit  

Profit is not the top priority — but **sustainable unit economics is mandatory**.

The strategic direction is:

> Low ARPU × Large Scale × Positive Gross Margin

The goal is not maximizing margin per user.  
The goal is building a scalable economic system.

---

# 3. Understanding the Real Cost Structure

It is misleading to calculate sustainability using:

```

Budget ÷ Cost per call = Max calls

```

AI product cost includes much more than model inference:

- Model inference cost
- Server & compute cost
- Storage
- Logging & analytics
- Monitoring systems
- Payment gateway fees
- Customer support
- Abuse & fraud losses

If you only calculate token cost, you overestimate profitability.

A healthy pricing model must absorb **total operational cost**, not just API expense.

---

# 4. The Core Risk: Heavy Users

AI usage distribution is highly skewed:

- 70–90% light users
- 5–20% moderate users
- 1–5% heavy users

Heavy users can destroy margins if unlimited access is offered at a low price.

Therefore, pricing must include structural safeguards:

- Per-request token cap
- Daily quota
- Monthly quota
- Fair usage policy
- Rate limiting
- Abuse detection

The goal is not restriction.  
The goal is **predictable cost control**.

Without guardrails, even a low-cost model can be exploited.

---

# 5. Recommended Growth-Phase Pricing Structure

A three-layer funnel model is recommended.

---

## Tier 1: Free Plan (Acquisition Layer)

**Goal:** Maximize onboarding and habit formation

Example structure:

- 10–20 interactions per day  
  or  
- 100 interactions per month  

Characteristics:

- Enables product habit
- Encourages experimentation
- Lowers psychological barrier
- Accepts minimal margin

This tier functions as marketing infrastructure.

---

## Tier 2: Basic Subscription (Core Growth Layer)

Example:

```

9 RMB / month

```

Includes:

- 800–1200 interactions per month  
  or  
- Defined token quota  
- Fair usage policy  

Why this works:

- Most users never hit the ceiling
- Revenue partially comes from unused capacity
- Predictable cost envelope
- High conversion potential

This is the primary revenue engine.

---

## Tier 3: Pro Plan (Heavy User Layer)

Example:

```

29 RMB / month

```

Includes:

- High or soft-unlimited quota
- Larger context window
- Priority processing
- Faster response

Purpose:

- Absorb heavy users safely
- Increase ARPU
- Protect margins of lower tiers
- Prevent system abuse

---

# 6. Alternative: Token-Based Model

Instead of counting interactions, pricing can be based on token quotas.

Example:

Free:
- 20,000 tokens / month

Basic (9 RMB):
- 200,000 tokens / month

Pro (29 RMB):
- 1,000,000 tokens / month

Advantages:

- Directly aligned with infrastructure cost
- Model-agnostic
- Transparent cost control
- Easier scaling as models evolve

Token-based models provide precision and flexibility.

---

# 7. Unit Economics Framework

Sustainable growth requires:

```

LTV > CAC

```

More specifically:

```

ARPU × Retention Months > Total User Cost

```

Example:

- Monthly cost per user: 1.8 RMB  
- Subscription price: 9 RMB  
- Average retention: 3 months  

Then:

```

LTV = 9 × 3 = 27 RMB
Total Cost = 1.8 × 3 = 5.4 RMB
Gross Profit = 21.6 RMB

```

This is healthy unit economics.

Growth-phase pricing must be evaluated at the **lifetime level**, not per-call level.

---

# 8. Pricing Strategy for Acquisition Goals

If the long-term objective includes strategic acquisition, buyers evaluate:

- DAU / MAU
- Growth rate
- Retention curves
- Paid conversion rate
- Usage depth
- Engagement frequency
- Data infrastructure maturity

They do not focus solely on short-term profit.

The optimal strategy becomes:

> Moderate profit + High growth velocity

Not:

> Maximum margin at low scale

---

# 9. Risk Control Mechanisms

AI systems must include structural cost protections:

- Per-request token cap
- Daily user quota
- Monthly quota
- Rate limiting
- Prompt injection protection
- Context truncation logic
- Anomaly detection

Unbounded AI systems eventually collapse under abuse.

Scalability is not just infrastructure — it is policy design.

---

# 10. Evolution Path (0 → 100K → 1M Users)

### Early Stage
- Focus on onboarding
- Accept thinner margins
- Validate retention
- Improve product-market fit

### Growth Stage
- Optimize pricing tiers
- Introduce advanced features
- Improve ARPU
- Reduce churn

### Scale Stage
- Refine segmentation
- Introduce enterprise tier
- Increase lifetime value
- Expand monetization channels

Pricing must evolve alongside user scale.

---

# 11. A Common Mistake: Engineer-Driven Cost-Back Pricing

While designing the pricing model, I initially made a very typical mistake:

> I calculated model cost per request, then reverse-engineered the price from infrastructure cost.

The logic looked like this:

```

Cost per interaction ≈ 0.0057 RMB
5 RMB budget ÷ 0.0057 ≈ 877 calls

```

It appears rational and mathematically correct.

But this is **classic engineer thinking**, not product thinking.

---

## Why Cost-Back Pricing Is a Trap

Cost-back pricing assumes:

- Pricing should be derived from infrastructure expense.
- Usage limits should be calculated from budget tolerance.
- Profitability equals (Price − Cost).

This works in manufacturing.

It does not work in growth-stage SaaS or AI products.

Users do not buy:

- Tokens
- API calls
- GPU seconds

They buy:

- Outcomes
- Time saved
- Cognitive leverage
- Identity enhancement
- Emotional relief

Pricing must reflect **perceived value**, not raw cost.

---

## The Real Pricing Question

The correct questions are:

- What is the product worth to the user?
- What price minimizes friction?
- What maximizes paid conversion?
- What keeps LTV > CAC?
- What supports long-term scale?

Cost defines the **floor**.  
Value defines the **ceiling**.

Growth-phase pricing exists in between.

---

## Strategic Shift

Instead of asking:

> “How many calls can 5 RMB buy?”

The correct framing is:

> “What pricing model maximizes sustainable user growth?”

This shift moves pricing from:

- Engineering calculation  
to  
- Business system architecture  

From:

- Cost accounting  
to  
- Economic design  

---

# 12. Conclusion

Mindory’s growth-phase pricing should:

- Keep entry barrier low
- Ensure positive unit economics
- Control heavy-user risk
- Enable predictable infrastructure scaling
- Increase long-term valuation
- Support acquisition attractiveness

This is not about calculating how many times 5 RMB can be spent.

It is about designing:

> A scalable economic system for an AI product.

Growth pricing is not a number.

It is infrastructure.