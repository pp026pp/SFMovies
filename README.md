SFMovies
========

A service that shows on a map where movies have been filmed in San Francisco. This is one of the challenges in https://github.com/uber/coding-challenge-tools/blob/master/coding_challenge.md.

It is hosted on https://pp026pp-sfmovies-uber.herokuapp.com/

Features
--------
 - Allow users to search for movies and show on a map where the movie has been filmed in San Francisco.
 - Typeahead for movie titles
 - Ranked typeahead list based on search frequency

----------


Backend
-------

##Stack
 - **Web Framework: Ruby on Rails.** I chose RoR because I had more
   experience with it comparing to Django and Node.js.
 - **Database: Postgresql**. I chose a relational database over nosql
   because the data schema of this app is very relational and we need to
   join tables to serve the requests. I chose Postgresql over MySQL
   because I'm hosting heroku and it supports Postgresql better than
   MySQL.
 - **Caching & Synchronization: Redis**. I use Redis to cache the movie data
   models. I'm also using Redis to broadcast a change to the prefix
   trie, which I will explain later.
 - **Server: Puma**. I chose Puma because it natually use multiple threads
   to serve incoming requests. It cost a lot less memory and has fast
   speed. Another reason I picked puma is that I have a prefix trie
   storing in memory. If I choose web servers that create new processes
   to serve requests(e.g. unicorn), then each process needs a copy of
   prefix trie in memory which is not efficient.

##Structure

###Tables

 - Movies: store all movies information including title, release_year, director...
 - Locations: store all locations information, which is just location address.
 - FilmedAt: store relations between movies and locations. If movie A was filmed at location B, there will be a row in FilmedAt table to store the movie_id and location_id
 - Full schema can be found in **db/schema.rb**. Migrations can be found in **db/migrate/**
db/seeds.rb is used to populate the database. Raw data is downloaded from the challenge page and is located at **db/data.csv**

### Models
All models located at **app/models**.

 - Movie: added associations to Locations model. Also defined find_by_title method which reads from Redis by default. If not found, then read the database and save it to Redis for next use.
 - Location: added associations to Movies model.
 - FilmedAt: added associations to Locations and Movies models.

###Prefix Trie

 - File: **lib/prefix_trie.rb**
 - When the server starts up, a prefix trie for the movie titles will be
   built in memory. This Trie adds a feature to store top N searches for
   each prefix based on search frequency. When user types in the search
   box, the server will look up the prefix string in the trie and return
   top N searches for that prefix string. When user types 'enter' in the
   search box, the server will look up the movie with that title and
   update the frequency and corresponding Trie Nodes with updated "top N
   searches".
 - I need to make sure the trie is thread safe because we have both read
   and write operations on it. Right now I'm using a simple mutex for
   the purpose instead of a read-write-lock because there's no standard
   read-write-lock in ruby library and I didn't have enough time to
   implement one. The Prefix Trie also works for multiple workers on
   multiple processes. In multi-process case, each worker will have a
   separate copy of the trie. To keep them synchronized, I publish a
   message using Redis whenever one of the Trie instance updates. Other
   instances will receive the Redis message and update the trie
   accordingly.

###Routes
 - File: **config/routes.rb**
 - **/api/v1/movies/autocomplete/:query** => autocomplete api for a search input, this returns a list of movie suggestions
 - **/api/v1/movies/search** => search a movie based on its title, this returns info for a movie including its filmed locations.
 - **/** => root Path, serves the app

###Controllers

 - Movies Controller
- **app/controllers/api/v1/movies_controller.rb**

- This controller serves the movies requests, the corresponding respond template is under **app/views/api/v1/movies/**

 - Main Controller
- **app/controllers/main_controller.rb**
- This controller serves the root path of the path, the corresponding html is **app/views/main/index.html.erb**. Detailed explanation will be listed in front end section.

###Server config
 - **config/puma.rb** (Currently used the Procfile) For this app, the server will spawn one worker process with 10-25 threads.
 - **config/unicorn.rb** (Not used but tried)


----------

Front End
-----------

I used Backbone.js for front end MVC because it is recommended but I had no prior experience with it so I'm not sure whether I'm using it in the correct way or not.

Backbone.js file locations:

 - Views: **app/assets/javascripts/views/**
 - Models: **app/assets/javascripts/models/**
 - Collections: **app/assets/javascripts/collections/**
 - Templates: **app/assets/templates/**
 - App file: **app/assets/javascripts/sfmovies**

##Views
- Searchbox View: Used Twitter's typeahead.js pluggin. When user types, it will hit the /api/v1/movies/autocomplete/ end point, fetch the result and show them.
- Map View: I used google map for the map display. When user searches a movie, the related locations will be returned and markers will be added to the map. I'm letting the front end to get the geo location according to the addressed returned from server because the amount of the locations returning each time is relatively small.
- Movie Info View: The view that display movie info. It will be populated each time user do a successful search

##Models
- Movie: stores the movie information including locations returned from the server.
- Location: stores the location information. (Just the address)

## Collections
- Locations: stores the locations parsed from movie model

##CSS
Located in **app/assets/stylesheets/main.css**
