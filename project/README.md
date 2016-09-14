# Where-U-At

This is the database schema for a simple application intended to highlight some new (and some old) Postgres features:

* PostGIS
* Row Level Security
* JSON storage and manipulation
* INSERT ON CONFLICT

The app itself is a "social" location-sharing application. Users can:

* Request to be friends with other users
* Share their current location with their friends
* Restrict visibility of their location to only friends within a certain radius

# Building

This project utilizes Docker to streamline a local development deployment. Docker is not required to run this,
but that's what I'm documenting here.

1. Build the images: `docker-compose build`
2. Launch postgres, make sure it's good: `docker-compose up -d db && docker-compose logs` (^C when satisfied)
3. Run unit tests: `docker-compose run --rm test`


# Developing

1. Launch postgres as above
2. Run unit tests by watching the tests directory: `docker-compose run --rm test watch -h db -p 5432 -u admin -w secret -d whereuat -t '/test/*.sql'`
