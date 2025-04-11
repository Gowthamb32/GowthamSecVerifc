-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Innovator', 'Investor', 'EscrowManager')),
    status VARCHAR(20) NOT NULL DEFAULT 'PendingVerification' CHECK (status IN ('PendingVerification', 'PendingApproval', 'Verified', 'Rejected', 'Suspended')),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reset_token VARCHAR(255),
    reset_token_expires TIMESTAMP WITH TIME ZONE,
    verification_notes TEXT
);

-- Create wallets table
CREATE TABLE IF NOT EXISTS wallets (
    wallet_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create projects table
CREATE TABLE IF NOT EXISTS projects (
    project_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    innovator_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PendingApproval',
    funding_goal DECIMAL(15,2) NOT NULL,
    current_funding DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    sdg_alignment TEXT[] NOT NULL,
    geo_focus TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create milestones table
CREATE TABLE IF NOT EXISTS milestones (
    milestone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(project_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    target_completion_date DATE NOT NULL,
    actual_completion_date DATE,
    funding_required DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Planned',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    related_entity_type VARCHAR(50),
    related_entity_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create documents table
CREATE TABLE IF NOT EXISTS documents (
    document_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id),
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('DRIVING_LICENSE', 'PASSPORT', 'NATIONAL_ID')),
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 