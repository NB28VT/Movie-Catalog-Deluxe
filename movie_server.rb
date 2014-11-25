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






# * Visiting `/actors/:id` will show the details for a given actor. This page should contain a list of movies that the actor has starred in and what their role was. Each movie should link to the details page for that movie.


get '/movie_catalog/actors/:id' do
  @id = params[:id]

  # NOT PROTECTED FOR SQL INJECTION
  movie_title_query = "SELECT movies.title FROM movies JOIN cast_members
  ON movies.id = cast_members.movie_id JOIN actors
  ON actors.id = cast_members.actor_id
  WHERE actors.id = #{@id};"

  db_connection do |connection|
    @titles = connection.exec(movie_title_query)
  end




















  erb :actor_info
end




















get '/movie_catalog/movies' do
  query = "SELECT movies.title FROM movies order BY movies.title"

  db_connection do |connection|
    @movies = connection.exec(query)
  end
  erb :movies
end
