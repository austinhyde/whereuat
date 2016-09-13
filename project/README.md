# Where-U-At

This is a very simple application intended to highlight some new (and some old) Postgres features:

* PostGIS
* Row Level Security
* JSON storage and manipulation
* INSERT ON CONFLICT

The app itself is a "social" location-sharing application. Users can:

* Request to be friends with other users
* Share their current location with their friends
* Restrict visibility of their location to only friends within a certain radius

# Building the App

The application utilizes docker to streamline a local development deployment. Docker is not required to run this,
but that's what I'm documenting here.

1. Build the images: `docker-compose build`
2. Launch postgres, make sure it's good: `docker-compose up -d db && docker-compose logs` (^C when satisfied)
3. Launch the app: `docker-compose up -d app && docker-compose logs`
