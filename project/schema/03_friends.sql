
CREATE TYPE friendship_status AS ENUM ('pending', 'accepted', 'rejected');

CREATE TABLE friends (
  asker_id uuid NOT NULL REFERENCES users (user_id)
    DEFAULT substring(current_user from 17)::uuid,
  askee_id uuid NOT NULL REFERENCES users (user_id),

  status friendship_status NOT NULL DEFAULT 'pending',
  status_time timestamp with time zone NOT NULL DEFAULT NOW(),
  status_by uuid NOT NULL REFERENCES users (user_id)
    CHECK (status_by IN (asker_id, askee_id))
    DEFAULT substring(current_user from 17)::uuid,

  PRIMARY KEY (asker_id, askee_id)
);

GRANT SELECT, INSERT ON TABLE friends TO whereuat_enduser;
GRANT UPDATE (status) ON TABLE friends TO whereuat_enduser;


ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
CREATE POLICY friends_request ON friends
  FOR INSERT TO whereuat_enduser
  WITH CHECK (
    current_user = 'whereuat_enduser_' || asker_id
    AND status = 'pending'
  );

CREATE POLICY users_friends ON users
  FOR SELECT
  TO whereuat_enduser
  USING (
    user_id IN (
      SELECT asker_id FROM friends
      WHERE 'whereuat_enduser_' || askee_id = current_user
        AND status = 'accepted'
    UNION
      SELECT askee_id FROM friends
      WHERE 'whereuat_enduser_' || asker_id = current_user
        AND status = 'accepted'
    )
  );

CREATE POLICY friends_asker ON friends
  FOR SELECT
  TO whereuat_enduser
  USING (current_user = 'whereuat_enduser_' || asker_id);

-- users can read any friend requests directed at them
-- provided it wasn't canceled by the asker
CREATE POLICY friends_askee ON friends
  FOR SELECT
  TO whereuat_enduser
  USING (
    current_user = 'whereuat_enduser_' || askee_id
    AND NOT (status_by = asker_id AND status = 'rejected')
  );

-- both askers and askees are allowed to reject a request at any time
CREATE POLICY friends_reject ON friends
  FOR UPDATE
  TO whereuat_enduser
  USING (substring(current_user from 17) IN (askee_id::text, asker_id::text))
  WITH CHECK (status = 'rejected');
