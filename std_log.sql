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
CREATE INDEX IF NOT EXISTS ix_state_transitions_entity_type_entity_id ON state_transitions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS ix_state_transitions_performed_by ON state_transitions(performed_by);
CREATE INDEX IF NOT EXISTS ix_state_transitions_transition_time ON state_transitions(transition_time);