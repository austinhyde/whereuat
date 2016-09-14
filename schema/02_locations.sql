

CREATE TABLE locations (
  user_id uuid NOT NULL
    PRIMARY KEY
    REFERENCES users (user_id)
    DEFAULT substring(current_user from 17)::uuid,
  updated timestamp with time zone NOT NULL DEFAULT NOW(),
  location geometry(POINT, 4326)
);

GRANT SELECT ON TABLE locations TO whereuat_enduser;
GRANT INSERT, UPDATE (location) ON TABLE locations TO whereuat_enduser;


ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- users can update their own locations
CREATE POLICY locations_own_select ON locations
  FOR SELECT TO whereuat_enduser
  USING (current_user = 'whereuat_enduser_' || user_id);
CREATE POLICY locations_own_insert ON locations
  FOR INSERT TO whereuat_enduser
  WITH CHECK (current_user = 'whereuat_enduser_' || user_id);
CREATE POLICY locations_own_update ON locations
  FOR UPDATE TO whereuat_enduser
  USING (current_user = 'whereuat_enduser_' || user_id);
