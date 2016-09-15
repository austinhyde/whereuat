# Where-U-At

[Slides from the talk](https://docs.google.com/presentation/d/1b4Eq61_AaPH-0je0MyfWoqwWFEbvGPfaDmAXn6w5juo/edit?usp=sharing)

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

I made a simple `scripts` script to help out with things:

* Build the docker image: `./scripts build-image`
* Start the server: `./scripts start`
* Stop the server: `./scripts stop`
* Remove the server container: `./scripts rm`
* Build the database schema `./scripts rebuild`
* Run unit tests: `./scripts test`
* Open a psql shell: `./scripts psql`
* Rebuild the schema and rerun tests when a file changes: `./scripts watch`
* Run arbitrary commands on the server: `./scripts exec`
