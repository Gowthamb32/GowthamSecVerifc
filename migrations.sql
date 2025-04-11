-- Insert test users (all with password: Password123)
-- First check if any of these users already exist to avoid duplicates
DO $$
BEGIN
    -- Insert Escrow Manager
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'escrow@innocapforge.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'escrow@innocapforge.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu', -- bcrypt hash for 'Password123'
            'Escrow Manager',
            '+1-555-765-4321',
            '1985-05-15',
            'EscrowManager',
            'Verified'
        );
    END IF;

    -- Insert Innovators
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'john@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'john@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'John Doe',
            '+1-555-123-1111',
            '1982-06-15',
            'Innovator',
            'Verified'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarah@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'sarah@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'Sarah Johnson',
            '+1-555-123-2222',
            '1985-08-22',
            'Innovator',
            'Verified'
        );
    END IF;

    -- Insert Investors
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'michael@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'michael@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'Michael Brown',
            '+1-555-123-3333',
            '1975-03-10',
            'Investor',
            'Verified'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'emily@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'emily@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'Emily Chen',
            '+1-555-123-4444',
            '1980-11-05',
            'Investor',
            'Verified'
        );
    END IF;

    -- Insert Pending Approval Users
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'emma@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'emma@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'Emma Johnson',
            '+1-555-123-5555',
            '1990-07-20',
            'Innovator',
            'PendingApproval'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'robert@example.com') THEN
        INSERT INTO users (
            email, password_hash, full_name, phone_number, date_of_birth, role, status
        ) VALUES (
            'robert@example.com',
            '$2b$10$ukrtPFHt9mfz44oyPSJ7XeG57WpqMC8vNsndROZ0U91aTUX5lYzgu',
            'Robert Miller',
            '+1-555-123-6666',
            '1978-09-30',
            'Investor',
            'PendingApproval'
        );
    END IF;
END
$$;

-- Create wallets for users who don't have one
INSERT INTO wallets (user_id, balance)
SELECT u.user_id, 
    CASE 
        WHEN u.email = 'john@example.com' THEN 5000.00
        WHEN u.email = 'sarah@example.com' THEN 3500.00
        WHEN u.email = 'michael@example.com' THEN 150000.00
        WHEN u.email = 'emily@example.com' THEN 200000.00
        ELSE 0.00
    END
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM wallets w WHERE w.user_id = u.user_id)
AND u.email IN ('john@example.com', 'sarah@example.com', 'michael@example.com', 'emily@example.com');

-- Create projects if they don't exist
DO $$
DECLARE
    john_doe_id UUID;
    sarah_johnson_id UUID;
    agri_project_id UUID;
    water_project_id UUID;
BEGIN
    -- Get user IDs
    SELECT user_id INTO john_doe_id FROM users WHERE email = 'john@example.com';
    SELECT user_id INTO sarah_johnson_id FROM users WHERE email = 'sarah@example.com';
    
    -- Insert Smart Agriculture project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM projects WHERE title = 'Smart Agriculture System') THEN
        INSERT INTO projects (
            innovator_id, title, description, category, status, funding_goal, current_funding,
            sdg_alignment, geo_focus
        ) VALUES (
            john_doe_id,
            'Smart Agriculture System',
            'Sustainable farming using IoT sensors and AI for crop optimization. The Smart Agriculture System helps farmers optimize crop yields while reducing resource usage.',
            'AgriTech',
            'SeekingFunding',
            50000.00,
            15000.00,
            ARRAY['SDG 2', 'SDG 12'], -- Zero Hunger, Responsible Consumption
            'Sub-Saharan Africa'
        ) RETURNING project_id INTO agri_project_id;
    ELSE
        SELECT project_id INTO agri_project_id FROM projects WHERE title = 'Smart Agriculture System';
    END IF;

    -- Insert Clean Water project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM projects WHERE title = 'Clean Water Initiative') THEN
        INSERT INTO projects (
            innovator_id, title, description, category, status, funding_goal, current_funding,
            sdg_alignment, geo_focus
        ) VALUES (
            sarah_johnson_id,
            'Clean Water Initiative',
            'Water purification technology for rural communities using renewable energy. Our system combines multiple filtration technologies with UV sterilization.',
            'CleanTech',
            'PartiallyFunded',
            75000.00,
            56250.00,
            ARRAY['SDG 6', 'SDG 7'], -- Clean Water and Sanitation, Affordable and Clean Energy
            'Southeast Asia and East Africa'
        ) RETURNING project_id INTO water_project_id;
    ELSE
        SELECT project_id INTO water_project_id FROM projects WHERE title = 'Clean Water Initiative';
    END IF;

    -- Insert Solar Micro-Grids project (pending approval) if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM projects WHERE title = 'Solar Micro-Grids') THEN
        INSERT INTO projects (
            innovator_id, title, description, category, status, funding_goal, current_funding,
            sdg_alignment, geo_focus
        ) VALUES (
            john_doe_id,
            'Solar Micro-Grids',
            'Decentralized solar power solutions for off-grid communities. This project aims to develop a modular, scalable solar micro-grid system.',
            'Energy',
            'PendingApproval',
            120000.00,
            0.00,
            ARRAY['SDG 7', 'SDG 13'], -- Affordable and Clean Energy, Climate Action
            'Rural communities in India and Sub-Saharan Africa'
        );
    END IF;
END
$$;

-- Insert milestones for projects if they don't exist
DO $$
DECLARE
    agri_project_id UUID;
    water_project_id UUID;
    agri_milestone1_id UUID;
    agri_milestone2_id UUID;
    water_milestone1_id UUID;
BEGIN
    -- Get project IDs
    SELECT project_id INTO agri_project_id FROM projects WHERE title = 'Smart Agriculture System';
    SELECT project_id INTO water_project_id FROM projects WHERE title = 'Clean Water Initiative';
    
    -- Insert milestones for Smart Agriculture System if they don't exist
    IF NOT EXISTS (SELECT 1 FROM milestones WHERE project_id = agri_project_id AND title = 'Sensor Prototype Development') THEN
        INSERT INTO milestones (
            project_id, title, description, start_date, target_completion_date, 
            funding_required, status
        ) VALUES (
            agri_project_id,
            'Sensor Prototype Development',
            'Develop and test low-cost, solar-powered sensor units that can monitor soil moisture, temperature, and nutrient levels.',
            CURRENT_DATE - INTERVAL '30 days',
            CURRENT_DATE + INTERVAL '60 days',
            10000.00,
            'InProgress'
        ) RETURNING milestone_id INTO agri_milestone1_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM milestones WHERE project_id = agri_project_id AND title = 'AI Algorithm Development') THEN
        INSERT INTO milestones (
            project_id, title, description, start_date, target_completion_date, 
            funding_required, status
        ) VALUES (
            agri_project_id,
            'AI Algorithm Development',
            'Develop machine learning algorithms to analyze sensor data and provide actionable recommendations to farmers.',
            CURRENT_DATE + INTERVAL '20 days',
            CURRENT_DATE + INTERVAL '90 days',
            12500.00,
            'Planned'
        ) RETURNING milestone_id INTO agri_milestone2_id;
    END IF;
    
    -- Insert milestone for Clean Water Initiative if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM milestones WHERE project_id = water_project_id AND title = 'Filtration System Prototype') THEN
        INSERT INTO milestones (
            project_id, title, description, start_date, target_completion_date, 
            funding_required, status
        ) VALUES (
            water_project_id,
            'Filtration System Prototype',
            'Develop and test the multi-stage filtration system to remove contaminants from various water sources.',
            CURRENT_DATE - INTERVAL '15 days',
            CURRENT_DATE + INTERVAL '45 days',
            22500.00,
            'InProgress'
        ) RETURNING milestone_id INTO water_milestone1_id;
    END IF;
    
    -- Insert milestone verification for Smart Agriculture System if it doesn't exist
    IF agri_milestone1_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM milestone_verifications mv 
        JOIN milestones m ON mv.milestone_id = m.milestone_id 
        WHERE m.project_id = agri_project_id AND m.title = 'Sensor Prototype Development'
    ) THEN
        INSERT INTO milestone_verifications (
            milestone_id, submitted_by, status, submission_date
        ) 
        SELECT 
            m.milestone_id, 
            (SELECT user_id FROM users WHERE email = 'john@example.com'),
            'PendingReview',
            CURRENT_TIMESTAMP
        FROM milestones m
        WHERE m.project_id = agri_project_id AND m.title = 'Sensor Prototype Development';
    END IF;
END
$$;

-- Create investors records if they don't exist
DO $$
DECLARE
    michael_id UUID;
    emily_id UUID;
BEGIN
    -- Get user IDs
    SELECT user_id INTO michael_id FROM users WHERE email = 'michael@example.com';
    SELECT user_id INTO emily_id FROM users WHERE email = 'emily@example.com';
    
    -- Create investor record for Michael if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investors WHERE user_id = michael_id) THEN
        INSERT INTO investors (
            user_id, preferred_sdg, preferred_geo, investment_min, investment_max
        ) VALUES (
            michael_id,
            ARRAY['SDG 2', 'SDG 6', 'SDG 7'], -- Zero Hunger, Clean Water, Clean Energy
            ARRAY['Africa', 'Southeast Asia'],
            5000.00,
            100000.00
        );
    END IF;
    
    -- Create investor record for Emily if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investors WHERE user_id = emily_id) THEN
        INSERT INTO investors (
            user_id, preferred_sdg, preferred_geo, investment_min, investment_max
        ) VALUES (
            emily_id,
            ARRAY['SDG 6', 'SDG 7', 'SDG 13'], -- Clean Water, Clean Energy, Climate Action
            ARRAY['India', 'Southeast Asia', 'Africa'],
            10000.00,
            250000.00
        );
    END IF;
END
$$;

-- Insert investments if they don't exist
DO $$
DECLARE
    michael_investor_id UUID;
    emily_investor_id UUID;
    agri_project_id UUID;
    water_project_id UUID;
BEGIN
    -- Get investor IDs
    SELECT i.investor_id INTO michael_investor_id FROM investors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'michael@example.com';
    SELECT i.investor_id INTO emily_investor_id FROM investors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'emily@example.com';
    
    -- Get project IDs
    SELECT project_id INTO agri_project_id FROM projects WHERE title = 'Smart Agriculture System';
    SELECT project_id INTO water_project_id FROM projects WHERE title = 'Clean Water Initiative';
    
    -- Insert investment for Michael to Agriculture project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investments WHERE investor_id = michael_investor_id AND project_id = agri_project_id) THEN
        INSERT INTO investments (
            investor_id, project_id, amount
        ) VALUES (
            michael_investor_id,
            agri_project_id,
            10000.00
        );
    END IF;
    
    -- Insert investment for Emily to Agriculture project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investments WHERE investor_id = emily_investor_id AND project_id = agri_project_id) THEN
        INSERT INTO investments (
            investor_id, project_id, amount
        ) VALUES (
            emily_investor_id,
            agri_project_id,
            5000.00
        );
    END IF;
    
    -- Insert investment for Michael to Water project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investments WHERE investor_id = michael_investor_id AND project_id = water_project_id) THEN
        INSERT INTO investments (
            investor_id, project_id, amount
        ) VALUES (
            michael_investor_id,
            water_project_id,
            25000.00
        );
    END IF;
    
    -- Insert investment for Emily to Water project if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM investments WHERE investor_id = emily_investor_id AND project_id = water_project_id) THEN
        INSERT INTO investments (
            investor_id, project_id, amount
        ) VALUES (
            emily_investor_id,
            water_project_id,
            31250.00
        );
    END IF;
END
$$;

-- Insert wallet transactions (deposits) if they don't exist
DO $$
DECLARE
    sarah_wallet_id UUID;
    michael_wallet_id UUID;
    deposit_type_id INTEGER;
    pending_status_id INTEGER;
    bank_transfer_id INTEGER;
    crypto_id INTEGER;
BEGIN
    -- Get wallet IDs
    SELECT w.wallet_id INTO sarah_wallet_id FROM wallets w JOIN users u ON w.user_id = u.user_id WHERE u.email = 'sarah@example.com';
    SELECT w.wallet_id INTO michael_wallet_id FROM wallets w JOIN users u ON w.user_id = u.user_id WHERE u.email = 'michael@example.com';
    
    -- Get type, status, and payment method IDs
    SELECT type_id INTO deposit_type_id FROM transaction_types WHERE type_name = 'deposit';
    SELECT status_id INTO pending_status_id FROM transaction_status WHERE status_name = 'pending';
    SELECT method_id INTO bank_transfer_id FROM payment_methods WHERE method_name = 'bank_transfer';
    SELECT method_id INTO crypto_id FROM payment_methods WHERE method_name = 'cryptocurrency';
    
    -- Insert deposit for Sarah if it doesn't exist
    IF sarah_wallet_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM transactions 
        WHERE wallet_id = sarah_wallet_id 
        AND type_id = deposit_type_id 
        AND status_id = pending_status_id
        AND amount = 25000.00
    ) THEN
        INSERT INTO transactions (
            wallet_id, type_id, status_id, amount, payment_method_id, proof_document_path, notes
        ) VALUES (
            sarah_wallet_id,
            deposit_type_id,
            pending_status_id,
            25000.00,
            bank_transfer_id,
            'uploads/receipts/bank_receipt.pdf',
            'Bank transfer from Sarah Johnson'
        );
    END IF;
    
    -- Insert deposit for Michael if it doesn't exist
    IF michael_wallet_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM transactions 
        WHERE wallet_id = michael_wallet_id 
        AND type_id = deposit_type_id 
        AND status_id = pending_status_id
        AND amount = 10000.00
    ) THEN
        INSERT INTO transactions (
            wallet_id, type_id, status_id, amount, payment_method_id, proof_document_path, notes
        ) VALUES (
            michael_wallet_id,
            deposit_type_id,
            pending_status_id,
            10000.00,
            crypto_id,
            'uploads/receipts/crypto_transaction.png',
            'Cryptocurrency transfer from Michael Brown'
        );
    END IF;
END
$$;

-- Insert notifications if they don't exist
DO $$
DECLARE
    john_id UUID;
    sarah_id UUID;
    michael_id UUID;
BEGIN
    -- Get user IDs
    SELECT user_id INTO john_id FROM users WHERE email = 'john@example.com';
    SELECT user_id INTO sarah_id FROM users WHERE email = 'sarah@example.com';
    SELECT user_id INTO michael_id FROM users WHERE email = 'michael@example.com';
    
    -- Insert notification for John if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = john_id AND title = 'New Investment Received') THEN
        INSERT INTO notifications (
            user_id, title, message, read, created_at
        ) VALUES (
            john_id,
            'New Investment Received',
            'Your project "Smart Agriculture System" has received a new investment of $5,000',
            FALSE,
            CURRENT_TIMESTAMP
        );
    END IF;
    
    -- Insert notification for Sarah if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = sarah_id AND title = 'New Investment Received') THEN
        INSERT INTO notifications (
            user_id, title, message, read, created_at
        ) VALUES (
            sarah_id,
            'New Investment Received',
            'Your project "Clean Water Initiative" has received a new investment of $25,000',
            FALSE,
            CURRENT_TIMESTAMP
        );
    END IF;
    
    -- Insert notification for Michael if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = michael_id AND title = 'New Project Match') THEN
        INSERT INTO notifications (
            user_id, title, message, read, created_at
        ) VALUES (
            michael_id,
            'New Project Match',
            'New project matching your investment preferences has been published',
            FALSE,
            CURRENT_TIMESTAMP
        );
    END IF;
END
$$;