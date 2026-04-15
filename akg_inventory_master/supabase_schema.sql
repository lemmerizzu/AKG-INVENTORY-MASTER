-- ==============================================================================
-- AKG MASTER ERP - SUPABASE (POSTGRESQL) SCHEMA v2
-- Single Source of Truth — Ledger, Traceability, Offline-Sync, Multi-User
-- ==============================================================================

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 0. EXTENSIONS                                                              │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 1. USER PROFILES (linked to Supabase auth.users)                           │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'warehouse', 'driver');

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'warehouse',
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 2. MASTER: Customers                                                       │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    is_ppn BOOLEAN DEFAULT FALSE,
    term_days INT DEFAULT 14,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 3. MASTER: Items (Gas Types / Cylinder Categories)                         │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    base_price NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 4. Customer Specific Pricelists                                            │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE customer_pricelists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    item_id UUID REFERENCES items(id) ON DELETE CASCADE,
    custom_price NUMERIC(15, 2) NOT NULL,
    UNIQUE(customer_id, item_id)
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 5. Cylinder Assets: Per-Tube Traceability                                  │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE asset_status AS ENUM ('AVAILABLE_FULL', 'RENTED', 'AVAILABLE_EMPTY', 'MAINTENANCE');

CREATE TABLE cylinder_assets (
    barcode VARCHAR(100) PRIMARY KEY,
    item_id UUID REFERENCES items(id),
    status asset_status DEFAULT 'AVAILABLE_FULL',
    current_customer_id UUID REFERENCES customers(id),
    cycle_count INT DEFAULT 0,
    last_action_date TIMESTAMP WITH TIME ZONE
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 6. Transaction Documents (Headers)                                         │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE mutation_code AS ENUM ('IN', 'OUT', 'OTHER');
CREATE TYPE input_mode AS ENUM ('BULK', 'RESERVE');
CREATE TYPE doc_status AS ENUM ('DRAFT', 'COMPLETED', 'VOID');

CREATE TABLE transaction_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sys_doc_number VARCHAR(100) UNIQUE NOT NULL,
    po_reference VARCHAR(100),
    mutation mutation_code NOT NULL,
    input_mode input_mode NOT NULL DEFAULT 'BULK',
    customer_id UUID REFERENCES customers(id),
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
    shipping_address TEXT,
    status doc_status DEFAULT 'DRAFT',
    geo_latitude DOUBLE PRECISION,
    geo_longitude DOUBLE PRECISION,
    device_created_at TIMESTAMP WITH TIME ZONE,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 7. Immutable Inventory Ledger (Transaction Detail Lines)                   │
-- │    NO UPDATE / DELETE — corrections use VOID + reversal document           │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE inventory_ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES transaction_documents(id) ON DELETE RESTRICT,
    cylinder_barcode VARCHAR(100) REFERENCES cylinder_assets(barcode),
    item_id UUID REFERENCES items(id),
    is_barcode_audited BOOLEAN DEFAULT TRUE,
    qty INT NOT NULL,
    rental_price NUMERIC(15, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 8. Delivery Orders (Surat Jalan)                                           │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE delivery_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    do_number VARCHAR(100) UNIQUE NOT NULL,
    document_id UUID REFERENCES transaction_documents(id) ON DELETE RESTRICT,
    delivery_date TIMESTAMP WITH TIME ZONE NOT NULL,
    driver_id UUID REFERENCES user_profiles(id),
    recipient_name VARCHAR(255),
    recipient_signature_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 9. Invoices (Faktur Penagihan)                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE invoice_status AS ENUM ('DRAFT', 'SENT', 'PARTIAL_PAID', 'PAID', 'OVERDUE', 'VOID');

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id),
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal NUMERIC(15, 2) NOT NULL DEFAULT 0,
    ppn_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status invoice_status DEFAULT 'DRAFT',
    created_by UUID REFERENCES user_profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE invoice_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
    document_id UUID REFERENCES transaction_documents(id),
    item_id UUID REFERENCES items(id),
    description TEXT,
    qty INT NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    line_total NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 10. Payment Records (Catatan Pembayaran)                                   │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE payment_method AS ENUM ('CASH', 'TRANSFER', 'GIRO', 'OTHER');

CREATE TABLE payment_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE RESTRICT,
    payment_date DATE NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    method payment_method NOT NULL DEFAULT 'CASH',
    reference_number VARCHAR(100),
    notes TEXT,
    recorded_by UUID REFERENCES user_profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 11. System Audit Log (Who did what, when)                                  │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id),
    action VARCHAR(50) NOT NULL,        -- e.g., 'CREATE', 'VOID', 'UPDATE_PRICE'
    target_table VARCHAR(100) NOT NULL, -- e.g., 'transaction_documents'
    target_id UUID,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 12. Offline Sync Queue (Per-device pending operations)                     │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TYPE sync_status AS ENUM ('PENDING', 'SYNCING', 'SYNCED', 'FAILED');

CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(255) NOT NULL,
    operation VARCHAR(10) NOT NULL,     -- 'INSERT', 'UPDATE'
    target_table VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    status sync_status DEFAULT 'PENDING',
    retry_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    synced_at TIMESTAMP WITH TIME ZONE
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ 13. Document Templates (Editable Invoice/DO layouts)                       │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE TABLE document_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name VARCHAR(100) NOT NULL,        -- "Faktur Penjualan", "Surat Jalan"
    company_name VARCHAR(255) NOT NULL,
    company_legal_name VARCHAR(255) NOT NULL,
    company_address TEXT,
    company_phone VARCHAR(50),
    company_email VARCHAR(100),
    company_logo_path TEXT,
    document_title VARCHAR(100) NOT NULL,        -- "FAKTUR PENJUALAN"
    number_prefix VARCHAR(20) DEFAULT '',
    number_format VARCHAR(100) DEFAULT '{SEQ}',
    label_subtotal VARCHAR(100) DEFAULT 'Harga Jual',
    label_discount VARCHAR(100) DEFAULT 'Potongan Harga',
    label_down_payment VARCHAR(100) DEFAULT 'Uang Muka Diterima',
    label_tax_base VARCHAR(100) DEFAULT 'Dasar Pengenaan Pajak',
    label_tax VARCHAR(100) DEFAULT 'PPN 11%',
    label_grand_total VARCHAR(100) DEFAULT 'Jumlah yang Harus Dibayarkan',
    tax_percentage NUMERIC(5, 4) DEFAULT 0.11,
    bank_accounts JSONB DEFAULT '[]'::jsonb,     -- Array of {bank_name, account_number, account_holder}
    footer_note TEXT,
    customer_service_label VARCHAR(100),
    customer_service_contact VARCHAR(100),
    signatory_city VARCHAR(100),
    signatory_name VARCHAR(100),
    signatory_title VARCHAR(100),
    show_unit_column BOOLEAN DEFAULT TRUE,
    show_po_field BOOLEAN DEFAULT TRUE,
    show_npwp_field BOOLEAN DEFAULT TRUE,
    show_period_notes BOOLEAN DEFAULT TRUE,
    show_reference_notes BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ INDEXES                                                                    │
-- └─────────────────────────────────────────────────────────────────────────────┘
CREATE INDEX idx_cylinder_status     ON cylinder_assets(status);
CREATE INDEX idx_cylinder_customer   ON cylinder_assets(current_customer_id);
CREATE INDEX idx_ledger_doc          ON inventory_ledger(document_id);
CREATE INDEX idx_ledger_barcode      ON inventory_ledger(cylinder_barcode);
CREATE INDEX idx_doc_customer        ON transaction_documents(customer_id);
CREATE INDEX idx_doc_date            ON transaction_documents(transaction_date);
CREATE INDEX idx_invoice_customer    ON invoices(customer_id);
CREATE INDEX idx_invoice_status      ON invoices(status);
CREATE INDEX idx_payment_invoice     ON payment_records(invoice_id);
CREATE INDEX idx_audit_user          ON audit_logs(user_id);
CREATE INDEX idx_audit_target        ON audit_logs(target_table, target_id);
CREATE INDEX idx_sync_status         ON sync_queue(status);
CREATE INDEX idx_sync_device         ON sync_queue(device_id);

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ ROW LEVEL SECURITY (Supabase Best Practice)                                │
-- └─────────────────────────────────────────────────────────────────────────────┘
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
