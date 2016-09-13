CREATE EXTENSION postgis;

CREATE TABLE users (
  user_id uuid PRIMARY KEY,
  username varchar(50) NOT NULL UNIQUE,
  email varchar(100) NOT NULL,
  password varchar(100) NOT NULL,
  created timestamp with time zone NOT NULL DEFAULT NOW(),
  visibility_threshold_m int
);

CREATE TYPE friendship_status AS ENUM ('pending', 'accepted', 'rejected');

CREATE TABLE friends (
  asker uuid NOT NULL
    REFERENCES users (user_id)
    DEFAULT substring(current_user from 17),
  askee uuid NOT NULL REFERENCES users (user_id),

  status friendship_status NOT NULL DEFAULT 'pending',
  status_time timestamp with time zone NOT NULL DEFAULT NOW(),
  status_by uuid NOT NULL
    REFERENCES users (user_id)
    CHECK (status_by IN (asker, askee))
    DEFAULT substring(current_user from 17),

  PRIMARY KEY (asker, askee)
);

CREATE TABLE locations (
  user_id uuid NOT NULL
    PRIMARY KEY
    REFERENCES users (user_id)
    DEFAULT substring(current_user from 17),
  updated timestamp with time zone NOT NULL DEFAULT NOW(),
  location geometry(POINT, 4326)
);
