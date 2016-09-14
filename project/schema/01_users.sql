CREATE TABLE users (
  user_id uuid PRIMARY KEY,
  username varchar(50) NOT NULL UNIQUE,
  email varchar(100) NOT NULL,
  password varchar(100) NOT NULL,
  created timestamp with time zone NOT NULL DEFAULT NOW(),
  visibility_radius_m int
);

GRANT INSERT ON TABLE users TO whereuat_userreg;
GRANT SELECT (user_id, username, email, created, visibility_radius_m)
  ON TABLE users TO whereuat_enduser;
GRANT UPDATE (email, password, visibility_radius_m) ON TABLE users TO whereuat_enduser;

-- userreg: can only create users
CREATE FUNCTION create_enduser_role(user_id uuid)
RETURNS name
SECURITY DEFINER AS $$
BEGIN
  EXECUTE format(
    'CREATE ROLE %I IN ROLE whereuat_enduser ROLE whereuat_app',
    'whereuat_enduser_' || user_id
  );
  RETURN 'whereuat_enduser_' || user_id;
END;
$$ LANGUAGE PLPGSQL;

GRANT EXECUTE ON FUNCTION create_enduser_role(uuid) TO whereuat_userreg;
GRANT INSERT ON TABLE users TO whereuat_userreg;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- userreg is always allowed to create users
CREATE POLICY users_userreg ON users
  FOR INSERT TO whereuat_userreg
  WITH CHECK (true);

-- users can see their own info
CREATE POLICY users_own ON users
  FOR SELECT TO whereuat_enduser
  USING (current_user = 'whereuat_enduser_' || user_id);
-- users can update their own info
CREATE POLICY users_own_update ON users
  FOR UPDATE TO whereuat_enduser
  USING (current_user = 'whereuat_enduser_' || user_id);
