require_relative "themoviedb_support"

class MovieHelper
	attr_reader :themoviedb

	def initialize
		@themoviedb = TheMovieDBSupport.new
	end

  def add_crewman(crewman, movie_id)
    person = Person.where(moviedb_id: crewman[:id]).first
    person_id = person.id if person
    
    person_id = DB[:persons].insert(
      name: crewman[:name],
      moviedb_id: crewman[:id],
      profile_url: crewman[:profile_path]) unless person
    
    DB[:crew].insert(
      person_id: person_id,
      movie_id: movie_id,
      job: crewman[:job].to_s)
  end

  def add_production_company(created_movie_id, company)
    prodco = Productioncompany.where(moviedb_id: company['id']).first
    if prodco
      created_movie_id.add_productioncompany(prodco[:id])
    else
      created_movie_id.add_productioncompany(
        name: company['name'],
        moviedb_id: company['id']
      )
    end
  end

  def add_genre(genre, movie_id)
    genre_obj = Genre.first(moviedb_id: genre[:id])
    genre_id = genre_obj.id if genre_obj

    genre_id = DB[:genres].insert(
      name: genre[:name],
      moviedb_id: genre[:id]
    ) unless genre_obj

    DB[:movie_genre].insert(
      genre_id: genre_id,
      movie_id: movie_id
    )
  end

  def add_cast(moviedb_id, movie_id)
    actors = themoviedb.actors(moviedb_id)

    actors.each do |actor|
      actor[:job] = :actor
      add_crewman(actor, movie_id)
    end
  end

  def add_crew(moviedb_id, movie_id)
    crew = themoviedb.crew(moviedb_id)
    crew.each do |crewman|
      add_crewman(crewman, movie_id)
    end
  end

  def add_movie_to_database(movie_id, movieingonrating, imdbrating, episode)
    movie = themoviedb.movie_details(movie_id)
    puts "------------------------- DEBUG --------------"
    p movie
    puts "#{movie.release_date} #{movie.title}"
    puts "----------------------------------------------"
    if movie
      current_movie = Movie.filter(moviedb_id: movie.id).first
      fetched_movie_id = current_movie[:moviedb_id] unless current_movie.nil?
    end

    DB.transaction do
      if fetched_movie_id.nil?
        created_movie_id = Movie.create do |m|
          m.moviedb_id = movie.id
          m.title = movie.title
          m.year = movie.release_date.slice(0..3) if movie.release_date
          m.imdburl = "http://www.imdb.com/title/#{movie.imdb_id}"
          m.movieingonrating = movieingonrating
          m.imdbrating = imdbrating
          m.poster_url = themoviedb.image_url(movie.poster_path)
          m.episode = episode
        end

        movie.production_companies.each do |company|
          add_production_company(created_movie_id, company)
        end

        movie.genres.each do |genre|
          g = genre.inject({}){|new_hash,(key, value)| new_hash[key.to_sym] = value; new_hash}
          add_genre(g, created_movie_id[:id])
        end

        add_cast(movie_id, created_movie_id[:id])
        add_crew(movie_id, created_movie_id[:id])

      end
    end
  end

end