-- Create extension for UUID generation if not exists
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Add a state transitions table to track all changes
CREATE TABLE IF NOT EXISTS state_transitions (
    transition_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL,
    entity_id UUID NOT NULL,
    from_state VARCHAR(50) NOT NULL,
    to_state VARCHAR(50) NOT NULL,
    performed_by UUID NOT NULL,
    transition_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (performed_by) REFERENCES users(user_id)
);

-- Add indexes for efficient queries
CREATE INDEX IF NOT EXISTS ix_state_transitions_entity_type_entity_id 
    ON state_transitions(entity_type, entity_id);
    
CREATE INDEX IF NOT EXISTS ix_state_transitions_performed_by 
    ON state_transitions(performed_by);
    
CREATE INDEX IF NOT EXISTS ix_state_transitions_transition_time 
    ON state_transitions(transition_time);

-- Create function to record state transitions
CREATE OR REPLACE FUNCTION record_state_transition(
    p_entity_id UUID,
    p_entity_type VARCHAR(20),
    p_from_state VARCHAR(50),
    p_to_state VARCHAR(50),
    p_performed_by UUID,
    p_reason TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_transition_id UUID;
BEGIN
    INSERT INTO state_transitions(
        entity_id,
        entity_type,
        from_state,
        to_state,
        performed_by,
        reason
    ) VALUES (
        p_entity_id,
        p_entity_type,
        p_from_state,
        p_to_state,
        p_performed_by,
        p_reason
    ) RETURNING transition_id INTO v_transition_id;
    
    RETURN v_transition_id;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically track state changes on key tables

-- Users table trigger
CREATE OR REPLACE FUNCTION track_user_state_changes() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        PERFORM record_state_transition(
            NEW.user_id,
            'user',
            OLD.status,
            NEW.status,
            COALESCE(current_setting('app.current_user_id', true)::UUID, NEW.user_id)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_state_change_trigger
AFTER UPDATE ON users
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION track_user_state_changes();

-- Projects table trigger
CREATE OR REPLACE FUNCTION track_project_state_changes() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        PERFORM record_state_transition(
            NEW.project_id,
            'project',
            OLD.status,
            NEW.status,
            COALESCE(current_setting('app.current_user_id', true)::UUID, NEW.innovator_id)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER project_state_change_trigger
AFTER UPDATE ON projects
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION track_project_state_changes();

-- Similar triggers can be created for milestones and escrow tables