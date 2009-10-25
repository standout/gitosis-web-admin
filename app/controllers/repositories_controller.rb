class RepositoriesController < ApplicationController

  def index
    @repositories = Repository.all
  end

  def show
    @repository = Repository.find(params[:id])
    @public_keys = @repository.public_keys
  end

  def new
    @repository = Repository.new
  end

  def edit
    @repository = Repository.find(params[:id])
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
    @repository = Repository.find(params[:id])
    if @repository.update_attributes(params[:repository])
      flash[:notice] = 'Repository was successfully updated.'
      redirect_to(@repository)
    else
      render :action => "edit"
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    redirect_to(repositories_url)
  end

  def add_public_key
    @repository = Repository.find(params[:id])
    @public_key = PublicKey.find(params[:public_key_id])
    if @repository.public_keys << @public_key
      flash[:notice] = "PublicKey successfully added."
      redirect_to(@repository)
    end
  end

  def remove_public_key
    @repository = Repository.find(params[:id])
    @permission = Permission.find(:first, :conditions => {:public_key_id => params[:public_key_id], :repository_id => params[:id]})
    if @permission.destroy
      flash[:notice] = "PublicKey successfully removed."
      redirect_to(@repository)
    end
  end

end
