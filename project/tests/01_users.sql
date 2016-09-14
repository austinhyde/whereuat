BEGIN;
CREATE EXTENSION "uuid-ossp";

CREATE OR REPLACE FUNCTION test_user()
RETURNS SETOF TEXT AS $$
DECLARE
  id uuid;
  rolename name;
BEGIN
  -- 1. Users can create accounts
  SET SESSION AUTHORIZATION whereuat_userreg;
  id := uuid_generate_v4();
  SELECT create_enduser_role(id) INTO rolename;
  RETURN NEXT has_role(rolename);

  RETURN NEXT lives_ok(format('INSERT INTO users
    (user_id, username, email, password, visibility_radius_m)
  VALUES
    (%L, ''starbuck'', ''kthrace@bsg.net'', ''thisisalegithash'', 1000)', id));


  -- 2. Users can see and update their own accounts
  SET SESSION AUTHORIZATION whereuat_app;
  EXECUTE format('SET ROLE %I', rolename);
  RETURN NEXT is(current_user, rolename);
  RETURN NEXT is(username, 'starbuck') FROM users;

  UPDATE users SET visibility_radius_m = 500 WHERE user_id = id;
  RETURN NEXT is(visibility_radius_m, 500) FROM users;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM runtests();
ROLLBACK;
