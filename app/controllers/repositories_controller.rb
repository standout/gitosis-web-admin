class RepositoriesController < ApplicationController

  def index
    @repositories = Repository.all
  end

  def show
    @repository = Repository.find_by_name(params[:id])
  end

  def new
    @repository = Repository.new
  end

  def edit
    @repository = Repository.find_by_name(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])

    if @repository.save
      flash[:notice] = 'Repository was successfully created.'
      redirect_to(@repository)
    else
      render :action => "new"
    end
  end

  def update
    @repository = Repository.find_by_name(params[:id])
    if @repository.update_attributes(params[:repository])
      flash[:notice] = 'Repository was successfully updated.'
      redirect_to(@repository)
    else
      render :action => "edit"
    end
  end

  def destroy
    @repository = Repository.find_by_name(params[:id])
    @repository.destroy

    redirect_to(repositories_url)
  end
end
