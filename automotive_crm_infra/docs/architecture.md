# Architecture Decision Records

## Overview

This document records architectural decisions for the Automotive CRM project.

## ADR-001: Use Frappe Framework v15

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need a stable, long-term supported framework for our automotive CRM.

### Decision

Use Frappe Framework v15 instead of v16.

### Rationale

- v15 is supported until 2027 (LTS)
- v16 is bleeding edge, not recommended for production
- Better stability and community support
- More documentation and examples available

### Consequences

- ✅ Long-term support (2 years)
- ✅ Stable API
- ✅ Large community
- ⚠️ Missing some v16 features (acceptable)

---

## ADR-002: Fork-Based Deployment

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need to customize Frappe/ERPNext while maintaining ability to pull upstream updates.

### Decision

Fork all repositories to our organization and maintain upstream remotes.

### Rationale

- Full control over customizations
- Ability to merge upstream updates
- Team collaboration on our forks
- No dependency on third-party forks

### Consequences

- ✅ Full control
- ✅ Upstream sync possible
- ✅ Team collaboration
- ⚠️ Maintenance overhead (monthly sync)

---

## ADR-003: Custom App Architecture

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need automotive-specific features not available in standard ERPNext.

### Decision

Create `automotive_crm` as a separate Frappe app instead of modifying ERPNext core.

### Rationale

- Upgrade-safe (no core modifications)
- Modular architecture
- Easy to maintain and test
- Follows Frappe best practices

### Consequences

- ✅ Upgrade-safe
- ✅ Clean separation of concerns
- ✅ Easy to test
- ⚠️ Need to use hooks for customization

---

## ADR-004: Railway for Deployment

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need a deployment platform that supports Docker and is cost-effective.

### Decision

Use Railway for deployment instead of Frappe Cloud or traditional VPS.

### Rationale

- Docker-based (full control)
- Usage-based pricing (cost-effective)
- Easy scaling
- Good developer experience

### Consequences

- ✅ Full control over infrastructure
- ✅ Cost-effective for small teams
- ✅ Easy to scale
- ⚠️ Less managed than Frappe Cloud

---

## ADR-005: MariaDB 10.6

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need a reliable, supported database.

### Decision

Use MariaDB 10.6 as the primary database.

### Rationale

- Official Frappe recommendation
- LTS support until 2026
- Good performance
- Compatible with all Frappe features

### Consequences

- ✅ Official support
- ✅ Stable and reliable
- ✅ Good performance
- ⚠️ Need to plan upgrade to 10.11 eventually

---

## ADR-006: Redis for Caching and Queues

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need fast caching and background job processing.

### Decision

Use Redis for both caching and queue management.

### Rationale

- Official Frappe recommendation
- High performance
- Easy to set up
- Good ecosystem

### Consequences

- ✅ Fast caching
- ✅ Reliable queues
- ✅ Easy to monitor
- ⚠️ Need to manage memory

---

## ADR-007: PWA First, Native Later

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need mobile access for the sales team.

### Decision

Implement PWA first, native mobile app later.

### Rationale

- Frappe CRM has built-in PWA support
- Faster to implement
- Lower maintenance cost
- Good enough for most use cases

### Consequences

- ✅ Fast implementation
- ✅ Low maintenance
- ✅ Cross-platform
- ⚠️ Limited offline support (acceptable)

---

## ADR-008: English Only

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need to decide on localization.

### Decision

English only for now, no localization.

### Rationale

- Simpler development
- Faster time to market
- All team members speak English
- Can add later if needed

### Consequences

- ✅ Faster development
- ✅ Simpler codebase
- ⚠️ Limited market (acceptable)

---

## ADR-009: Dual Pricing Model

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need to support both cost-based and customer-specific pricing.

### Decision

Implement dual pricing model with cost sheets and price lists.

### Rationale

- Real-world automotive pricing is complex
- Need cost-based for internal analysis
- Need customer-specific for negotiations
- Both models are common in automotive

### Consequences

- ✅ Flexible pricing
- ✅ Accurate cost analysis
- ✅ Customer-specific pricing
- ⚠️ More complex implementation

---

## ADR-010: ISO 9001 Tracking

**Status:** Accepted  
**Date:** 2026-06-29

### Context

We need to track quality certifications for OEM customers.

### Decision

Include ISO 9001 and other certification tracking in the system.

### Rationale

- Critical for automotive industry
- Many OEMs require certifications
- Need to track expiry dates
- Important for compliance

### Consequences

- ✅ Compliance tracking
- ✅ Better customer management
- ✅ Automated reminders
- ⚠️ Additional fields and logic
