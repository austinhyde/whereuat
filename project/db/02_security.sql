-- endusers: represent actual users of the application
CREATE ROLE whereuat_enduser;

GRANT SELECT
  ON TABLE users
  TO whereuat_enduser;
GRANT UPDATE (email, password, visibility_threshold_m)
  ON TABLE users
  TO whereuat_enduser;

GRANT SELECT
  ON TABLE locations
  TO whereuat_enduser;
GRANT INSERT, UPDATE (location)
  ON TABLE locations
  TO whereuat_enduser;

GRANT SELECT, INSERT
  ON TABLE friends
  TO whereuat_enduser;
GRANT UPDATE (status)
  ON TABLE friends
  TO whereuat_enduser;

-- userreg: can only create users
CREATE FUNCTION create_enduser_role(user_id uuid)
RETURNS void
SECURITY DEFINER
LANGUAGE PLPGSQL AS $$
BEGIN
  EXECUTE format(
    'CREATE ROLE %I IN ROLE enduser ROLE whereuat_app',
    'whereuat_enduser_' || user_id
  );
END;
$$;

GRANT EXECUTE
  ON FUNCTION create_enduser_role(uuid)
  TO whereuat_userreg;
GRANT INSERT ON TABLE users
  TO whereuat_userreg;
