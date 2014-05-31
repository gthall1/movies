require 'sinatra'
require 'pry'
require 'pg'
require 'shotgun'

############ Methods ###############

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

  yield(connection)

  ensure
    connection.close
  end
end

###################################

#points to index.html.erb in actors
get '/actors' do
  query = "SELECT name FROM actors ORDER BY actors.name"

  actors_name = db_connection do |conn|
    conn.exec(query)
  end
  @actors = actors_name.to_a

erb :'/actors/index.html'
end


get '/movies' do
  query = "SELECT movies.title AS title, genres.name AS genre, studios.name AS studio, movies.year AS year FROM movies
          JOIN genres ON movies.genre_id = genres.id
          JOIN studios ON movies.studio_id = studios.id"

  movie_name = db_connection do |conn|
    conn.exec(query)
  end
  @movies = movie_name.to_a

erb :'/movies/index.html'
end

get '/movies/:movie' do
  movie = params[:movie]
    query = "SELECT movies.title AS title, genres.name AS genre, studios.name AS studio, cast_members.character AS character, actors.name AS actor, movies.year AS year FROM movies
          JOIN genres ON movies.genre_id = genres.id
          JOIN studios ON movies.studio_id = studios.id
          JOIN cast_members ON movies.id = cast_members.movie_id
          JOIN actors ON cast_members.actor_id = actors.id WHERE movies.title = '#{params[:movie]}';"
movie_name = db_connection do |conn|
    conn.exec(query)
  end
  @movies = movie_name.to_a

erb :'/movies/show.html'
end


get '/actors/:actor' do
  actor = params[:actor]
  query = "SELECT actors.name AS actor, movies.title AS movies, cast_members.character AS cast FROM movies
           JOIN genres ON movies.genre_id = genres.id
           JOIN studios ON movies.studio_id = studios.id
           JOIN cast_members ON movies.id = cast_members.movie_id
           JOIN actors ON cast_members.actor_id = actors.id WHERE actors.name = '#{params[:actor]}';"

           actors_name = db_connection do |conn|
          conn.exec(query)
         end
         @actors = actors_name.to_a
erb :'/actors/show.html'
end
