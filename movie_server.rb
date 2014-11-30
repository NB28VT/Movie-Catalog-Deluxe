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

  @page = params[:page].to_i
  if @page > 1
    @offset = "OFFSET #{((@page - 1)* 20)}"
  end



  query = "SELECT actors.name, actors.id FROM actors ORDER BY actors.name LIMIT 20 #{@offset};"

  db_connection do |connection|
    @actors = connection.exec_params(query)
  end

  erb :actors
end

get '/movie_catalog/actors/:id' do
  @id = params[:id]

  actors_movies_query = "SELECT movies.title, actors.name,
  cast_members.character, movies.id AS movie_id FROM movies     JOIN cast_members
  ON movies.id = cast_members.movie_id JOIN actors
  ON actors.id = cast_members.actor_id
  WHERE actors.id = $1;"

  db_connection do |connection|
    @actor_info = connection.exec(actors_movies_query, [@id])
  end

  @actor_info.to_a.each do |actor|
    @actor_name = actor["name"]
  end

  erb :actor_info
end



get '/movie_catalog/movies' do
  @order = params[:order]
  @page = params[:page].to_i
  if @page > 1
    @offset = "OFFSET #{((@page - 1)* 20)}"
  end



  query = "SELECT movies.title, movies.id AS id,
  movies.year, movies.rating,
  studios.name AS studio, genres.name AS genre
  FROM movies
  JOIN studios ON movies.studio_id = studios.id
  LEFT OUTER JOIN genres ON movies.genre_id = genres.id
  ORDER BY movies.#{@order} LIMIT 20 #{@offset};"

  db_connection do |connection|
    @movies = connection.exec(query)
  end
  erb :movies
end

get '/movie_catalog/movies/:id' do
  @id = params[:id]

  query = "SELECT movies.title, genres.name AS genre, studios.name as studio
  FROM movies
  JOIN studios ON movies.studio_id = studios.id
  LEFT OUTER JOIN genres ON movies.genre_id = genres.id
  WHERE movies.id = $1;"

  cast_query = "SELECT actors.name AS name, cast_members.character AS character,
  actors.id AS id
  FROM actors
  JOIN cast_members ON cast_members.actor_id = actors.id
  JOIN movies ON cast_members.movie_id = movies.id
  WHERE movies.id = $1;"

  db_connection do |connection|
    @movie_data = connection.exec_params(query, [@id])
  end



  db_connection do |connection|
    @cast_data = connection.exec_params(cast_query, [@id])
  end

  erb :movie_info

end
