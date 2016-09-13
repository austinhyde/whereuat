ALTER TABLE users
  ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends
  ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations
  ENABLE ROW LEVEL SECURITY;

-- userreg is always allowed to create users
CREATE POLICY users_userreg ON users
  FOR INSERT
  TO whereuat_userreg
  USING (true);

-- users can see their own info
CREATE POLICY users_own ON users
  FOR SELECT
  TO whereuat_enduser
  USING (current_user == 'whereuat_enduser_' || user_id);

-- users can see their friends' info
CREATE POLICY users_friends ON users
  FOR SELECT
  TO whereuat_enduser
  USING (
    user_id IN (
      SELECT asker_id FROM friends
      WHERE 'whereuat_enduser_' || askee_id == current_user
        AND status == 'accepted'
    UNION
      SELECT askee_id FROM friends
      WHERE 'whereuat_enduser_' || asker_id == current_user
        AND status == 'accepted'
    )
  );

-- users can read friend requests they sent
CREATE POLICY friends_asker ON friends
  FOR SELECT
  TO whereuat_enduser
  USING (current_user == 'whereuat_enduser_' || asker_id);

-- users can read any friend requests directed at them
CREATE POLICY friends_askee ON friends
  FOR SELECT
  TO whereuat_enduser
  USING (current_user == 'whereuat_enduser_' || askee_id);


-- users can create friend requests for anyone
CREATE POLICY friends_request ON friends
  FOR INSERT
  TO whereuat_enduser
  WITH CHECK (
    current_user == 'whereuat_enduser_' || asker_id
    AND status == 'requested'
  );

-- users can respond to friend requests directed at them
CREATE POLICY friends_response ON friends
  FOR UPDATE
  TO whereuat_enduser
  USING (current_user == 'whereuat_enduser_' || askee_id)
  WITH CHECK (
    -- ensure they set valid values back!
    current_user == 'whereuat_enduser_' || askee_id
    AND status != 'requested'
  );


-- users can see their own locations
CREATE POLICY locations_own ON locations
  FOR SELECT
  USING (current_user == 'whereuat_enduser_' || user_id);

-- users can update their own locations
CREATE POLICY locations_update ON locations
  FOR INSERT, UPDATE
  USING (current_user == 'whereuat_enduser_' || user_id);

-- users can see locations of their friends
-- but only if the user is within their friend's threshold
-- and only if their friend is within the user's threshold
CREATE POLICY locations_friends ON locations
  FOR SELECT
  USING (
    user_id == (SELECT)
  );
