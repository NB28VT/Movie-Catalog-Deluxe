require 'sinatra'
require 'pry'
require 'pg'
require 'sinatra/reloader'



def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/movie_catalog' do
  erb :index
end

get '/movie_catalog/actors' do
  # refactor into seperate method later
  query = "SELECT actors.name, actors.id FROM actors ORDER BY actors.name;"

  db_connection do |connection|
    @actors = connection.exec(query)
  end

  erb :actors
end

get '/movie_catalog/actors/:id' do
  @id = params[:id]

  # NOT PROTECTED FOR SQL INJECTION
  actors_movies_query = "SELECT movies.title, actors.name, cast_members.character, movies.id AS movie_id FROM movies JOIN cast_members
  ON movies.id = cast_members.movie_id JOIN actors
  ON actors.id = cast_members.actor_id
  WHERE actors.id = #{@id};"

  db_connection do |connection|
    @actor_info = connection.exec(actors_movies_query)
  end

  erb :actor_info
end



get '/movie_catalog/movies' do
  query = "SELECT movies.title, movies.id AS id FROM movies order BY movies.title;"

  db_connection do |connection|
    @movies = connection.exec(query)
  end
  erb :movies
end


# * Visiting `/movies/:id` will show the details for the movie. This page should contain information about the movie (including genre and studio) as well as a list of all of the actors and their roles. Each actor name is a link to the details page for that actor.

get '/movie_catalog/movies/:id' do
  @id = params[:id]
  # BREAK QUERIES START WITH MOVIE INFO

  query = "SELECT movies.title, genres.name AS genre, studios.name as studio
  FROM movies
  JOIN studios ON movies.studio_id = studios.id
  LEFT OUTER JOIN genres ON movies.genre_id = genres.id
  WHERE movies.id = #{@id};"

  cast_query = "SELECT actors.name AS name, cast_members.character AS character,
  actors.id AS id
  FROM actors
  JOIN cast_members ON cast_members.actor_id = actors.id
  JOIN movies ON cast_members.movie_id = movies.id
  WHERE movies.id = #{@id};"

  db_connection do |connection|
    @movie_data = connection.exec(query)
  end



# NEED TO ADD THIS TO VIEWS
  db_connection do |connection|
    @cast_data = connection.exec(cast_query)
  end

  erb :movie_info

end
