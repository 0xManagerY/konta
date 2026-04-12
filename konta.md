# Konta - Moroccan Mini-ERP

## IRON RULES

- Read `.env` for all secrets (never ask user)
- Run Supabase SQL queries via curl:
  ```bash
  curl -X POST "$SUPABASE_URL/rest/v1/rpc/$FUNCTION_NAME" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" \
    -d '{"param": "value"}'
  ```
- Use packages whenever possible instead of writing custom code
- Use built-in Flutter/Dart features to minimize code
- DO NOT OVERENGINEER — keep it simple
- No unnecessary abstractions
- Direct solutions over complex patterns

---

## Overview

Konta is a mobile accounting app designed for Moroccan small businesses and auto-entrepreneurs. It enables users to manage invoices, track expenses, record payments, and generate legally compliant PDF documents — all while working offline. The app enforces Moroccan tax regulations (TVA) and supports bilingual French/Arabic text for all user-facing content.

**Supported Languages:**
- 🇫🇷 French (Français) — Primary
- 🇲🇦 Arabic (العربية) — Secondary

All user-facing text, PDFs, and legal documents are bilingual.

## Language Support

### French
- Primary interface language
- Number-to-words conversion for legal documents
- Full app localization

### Arabic
- RTL (Right-to-Left) layout support
- All labels, buttons, and messages translated
- Bilingual PDF documents (French + Arabic)

### Bilingual Requirements
- [ ] App UI supports language switching
- [ ] PDFs include both French and Arabic text where applicable
- [ ] Date formats adapt to selected language
- [ ] Currency amounts written in words in both languages

## Core Features

### 1. Authentication
- [ ] User registration with email/password
- [ ] User login with persistent session
- [ ] Secure logout with local data cleanup
- [ ] Password reset via email

### 2. Company Management
- [ ] Create and edit company profile
- [ ] Legal status selection (SARL, SARL-AU, AE, SNC)
- [ ] Legal identifiers (ICE, IF, RC, CNSS)
- [ ] Company stamp/logo image upload
- [ ] Auto-entrepreneur mode applies 1% TVA

### 3. Customer Management
- [ ] Add, edit, and delete customers
- [ ] Store customer details (Name, ICE, address, phone, email)
- [ ] Customer list with search functionality
- [ ] Customer invoice history view

### 4. Invoice Management
- [ ] Create quotes (Devis) and invoices (Facture)
- [ ] Multiple line items with description, quantity, unit price
- [ ] TVA rate selection (1%, 10%, 20%)
- [ ] Automatic HT, TVA, TTC calculation
- [ ] Invoice status tracking (Draft, Sent, Paid, Overdue, Cancelled)
- [ ] Due date setting
- [ ] Quote to invoice conversion

### 5. Expense Tracking
- [ ] Record business expenses (date, category, amount)
- [ ] TVA amount tracking for deductible TVA
- [ ] Receipt scanning with device camera
- [ ] OCR extraction of amounts from receipts
- [ ] Expense list with date/category filters

### 6. Payment Tracking
- [ ] Record payments against invoices
- [ ] Payment methods: Espèces, Virement bancaire, Chèque, Effet de commerce
- [ ] Check due date setting
- [ ] Payment reminders before check due dates
- [ ] Payment status per invoice

### 7. Dashboard/Reports
- [ ] Cash flow summary
- [ ] Total revenue (paid invoices)
- [ ] Total expenses
- [ ] Outstanding invoice amounts
- [ ] Owner salary tracking

### 8. PDF Generation
- [ ] Legally compliant PDF invoices and quotes
- [ ] Company header with stamp/logo
- [ ] Customer information section
- [ ] Itemized table with TVA
- [ ] Totals (HT, TVA, TTC)
- [ ] Amount in French words (Total en Lettres)
- [ ] Legal identifiers (ICE, IF, RC, CNSS)
- [ ] Auto-entrepreneur footer when applicable
- [ ] PDF preview before sharing
- [ ] Share via WhatsApp, email, or other apps

### 9. Data Export
- [ ] Monthly accountant export (ZIP)
- [ ] Sales Excel sheet (ventes_YYYY_MM.xlsx)
- [ ] Expenses Excel sheet (depenses_YYYY_MM.xlsx)
- [ ] PDF invoices for the month
- [ ] Receipt images
- [ ] Share ZIP via WhatsApp, email, etc.

## Legal/Business Rules (Morocco)

### TVA Rates
| Rate | Description | Applicable To |
|------|-------------|---------------|
| 20% | Standard rate (Taux normal) | SARL, SARL-AU, SNC |
| 10% | Reduced rate (Taux réduit) | SARL, SARL-AU, SNC |
| 1% | Auto-entrepreneur rate | Auto-entrepreneurs only |

### Auto-Entrepreneur Rules
- All invoices automatically use **1% TVA** (not 0%)
- Required footer on all PDFs: "TVA applicable au taux de 1%, article 91 du CGI"
- TVA is charged and must be declared

### Required Fields on Documents
| Field | Validation |
|-------|------------|
| ICE | Exactly 15 digits |
| IF | Required, non-empty |
| RC | Number + City (e.g., "12345 Casablanca") |
| CNSS | Required, non-empty |

### Payment Methods (Fixed List)
- Espèces (Cash)
- Virement bancaire (Bank transfer)
- Chèque (Check)
- Effet de commerce (Trade bill)

## SuperAdmin Dashboard

The SuperAdmin Dashboard allows the app owner to manage global application settings and constants.

### Access
- Owner-only access via special admin credentials
- Accessible through hidden route or special admin login

### Configurable Constants

#### TVA Rates
- [ ] Add/edit/disable TVA rates
- [ ] Set default TVA rate per legal status
- [ ] Configure effective dates for rate changes

#### Payment Methods
- [ ] Add/edit/disable payment methods
- [ ] Configure payment method icons
- [ ] Set payment method order

#### Expense Categories
- [ ] Add/edit/disable expense categories
- [ ] Configure category icons
- [ ] Set deductible/non-deductible flags

#### Invoice Categories
- [ ] Add/edit/disable invoice categories
- [ ] Configure default products/services
- [ ] Set category-specific TVA rates

### Feature Flags
- [ ] Enable/disable OCR receipt scanning
- [ ] Enable/disable offline mode
- [ ] Enable/disable PDF preview
- [ ] Enable/disable data export
- [ ] Enable/disable Arabic language
- [ ] Enable/disable payment reminders

### Global Settings
- [ ] App maintenance mode toggle
- [ ] Maximum file upload sizes
- [ ] Session timeout duration
- [ ] Minimum app version requirement
- [ ] Announcement banners

### Audit Log
- [ ] Track all SuperAdmin changes
- [ ] View change history with timestamps
- [ ] Filter by admin user, date, setting type

## Supabase Configuration

### Required Tables
- `profiles` — Company information per user
- `clients` — Customer records
- `invoices` — Quotes and invoices
- `invoice_items` — Line items
- `expenses` — Expense records
- `payments` — Payment records
- `owner_salary` — Salary tracking
- `admin_settings` — SuperAdmin configuration
- `audit_log` — SuperAdmin change history

### RLS Policies
All tables use Row Level Security with user isolation: each user can only access their own data. Admin tables have separate admin-only access policies.

### Storage Buckets
- `receipts` — Receipt images (max 300KB per file, images only)
- `logos` — Company logos/stamps (max 500KB per file)

## Implementation Tasks

### Phase 1: Foundation
- [ ] Set up Flutter project with Material 3
- [ ] Configure Supabase authentication
- [ ] Create local SQLite database schema with Drift
- [ ] Build sync engine for offline-first data synchronization

### Phase 2: Core Utilities
- [ ] Implement French number-to-words utility
- [ ] Implement Arabic number-to-words utility
- [ ] Build PDF generation service
- [ ] Add bilingual PDF support

### Phase 3: Authentication & Profile
- [ ] Implement authentication flow (login/register screens)
- [ ] Build company profile setup screen
- [ ] Add language selection on first launch

### Phase 4: Business Features
- [ ] Build customer management screens
- [ ] Build invoice creation and listing screens
- [ ] Build expense tracking with receipt scanning
- [ ] Build payment tracking with check reminders
- [ ] Build dashboard with cash flow summary
- [ ] Build monthly export functionality

### Phase 5: Admin Features
- [ ] Design SuperAdmin dashboard UI
- [ ] Implement TVA rate management
- [ ] Implement payment method management
- [ ] Implement expense category management
- [ ] Implement feature flags system
- [ ] Build audit log viewer

### Phase 6: Localization
- [ ] Complete French translations
- [ ] Complete Arabic translations
- [ ] Implement RTL layout support
- [ ] Test language switching

### Phase 7: Testing & Polish
- [ ] Test offline functionality and sync
- [ ] Test bilingual PDF generation
- [ ] Verify TVA calculations (especially 1% for AE)
- [ ] Performance testing
- [ ] Security audit

---

**Status Legend:**
- `[x]` — DONE
- `[ ]` — TODO
- `[IN_PROGRESS]` — Currently being worked on

*This is a living document. AI agents should update task status as work progresses.*
