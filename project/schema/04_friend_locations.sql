
CREATE VIEW mutual_friendship AS
  SELECT
    asker_id as friend_a,
    askee_id as friend_b,
    LEAST(a.visibility_radius_m, b.visibility_radius_m) as mutual_distance
  FROM friends
  INNER JOIN users a ON a.user_id = asker_id
  INNER JOIN users b ON b.user_id = askee_id
  WHERE status = 'accepted'
UNION
  SELECT
    askee_id as friend_a,
    asker_id as friend_b,
    LEAST(a.visibility_radius_m, b.visibility_radius_m) as mutual_distance
  FROM friends
  INNER JOIN users a ON a.user_id = askee_id
  INNER JOIN users b ON b.user_id = asker_id
  WHERE status = 'accepted';

-- users can see locations of their friends
-- but only if the user is within their friend's threshold
-- and only if their friend is within the user's threshold
CREATE POLICY locations_mutual ON locations
  FOR SELECT TO whereuat_enduser
  USING (
    user_id IN (SELECT friend_b FROM mutual_friendship)
    AND
    ST_Distance(
      location,
      (SELECT location FROM locations WHERE current_user = 'whereuat_enduser_' || user_id)
    )
    <=
    (SELECT mutual_distance FROM mutual_friendship WHERE friend_a = user_id)
  );
