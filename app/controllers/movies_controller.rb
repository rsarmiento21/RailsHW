class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :sortby)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.order(:id)
    @all_ratings = Movie.ratings
    @sortby = nil
    redirect = false
    
    if params.has_key?(:sortby)
      @sortby = params[:sortby]
      session[:sortby] = @sortby
    elsif params.has_key?(:sortby)
      @sortby = session[:sortby]
      redirect = true
    end
    
    
    
    @ratings = {"G" => "1", "PG" => "1", "PG-13" => "1", "R" => "1"}
    if params.has_key?(:ratings)
      @ratings = params[:ratings]
      session[:ratings] = @ratings
    elsif session.has_key?(:ratings)
      @ratings = session[:ratings]
      redirect = true
    end
    
    @movies = @movies.where("rating in (?)", @ratings.keys)
    
    if(@sortby == "title")
      @movies = @movies.order(:title)
    elsif @sortby == "rating"
      @movies = @movies.order(:rating)
    elsif @sortby == "release"
      @movies = @movies.order(:release_date)
    end
    
    if redirect
      flash.keep
      redirect_to movies_path({:category => @category, :sort => @sort, :ratings => @ratings})
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
