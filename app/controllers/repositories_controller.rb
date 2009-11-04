class RepositoriesController < ApplicationController

  def index
    @repositories = Repository.all
  end

  def show
    @repository = Repository.find(params[:id])
    @public_keys = @repository.public_keys
    @delete_notice = delete_notice
  end

  def new
    @repository = Repository.new
  end

  def edit
    flash[:notice] = rename_notice
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])

    if @repository.save
      flash[:notice] = 'Repository was successfully created.'
      redirect_to(new_repository_public_key_path(@repository))
    else
      render :action => "new"
    end
  end

  def update
    @repository = Repository.find(params[:id])
    if @repository.update_attributes(params[:repository])
      flash[:notice] = rename_notice + "<br />Repository config was successfully updated."
      redirect_to(@repository)
    else
      render :action => "edit"
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy
    flash[:notice] = delete_notice + "<br />Repository config was successfully updated."    

    redirect_to(repositories_url)
  end

  def add_public_key
    @repository = Repository.find(params[:id])
    @public_key = PublicKey.find(params[:public_key_id])
    if @repository.public_keys << @public_key
      flash[:notice] = "Public key was successfully added to repository."
      redirect_to(@repository)
    end
  end

  def remove_public_key
    @repository = Repository.find(params[:id])
    @permission = Permission.find(:first, :conditions => {:public_key_id => params[:public_key_id], :repository_id => params[:id]})
    if @permission.destroy
      flash[:notice] = "Public key was successfully removed from repository."
      redirect_to(@repository)
    end
  end

private

  def rename_notice
    '<b>Gitosis is not able to rename repositories without manual changes.</b><br />
     You will need to rename the folder manually on the gitosis server.'
  end

  def delete_notice
    '<b>Gitosis is not able to fully delete repositories without manual changes.</b><br />
     You will need to delete the folder manually on the gitosis server.'
  end
end