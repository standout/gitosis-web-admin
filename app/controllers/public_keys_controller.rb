class PublicKeysController < ApplicationController

  def index
    @public_keys = PublicKey.all
  end


  def show
    @public_key = PublicKey.find(params[:id])
  end

  def new
    @public_key = PublicKey.new
  end

  def edit
    @public_key = PublicKey.find(params[:id])
  end

  def create
    @public_key = PublicKey.new(params[:public_key])

    if @public_key.save
      flash[:notice] = 'PublicKey was successfully created.'
      redirect_to(@public_key)
    else
      render :action => "new"
    end

  end

  def update
    @public_key = PublicKey.find(params[:id])

    if @public_key.update_attributes(params[:public_key])
      flash[:notice] = 'PublicKey was successfully updated.'
      redirect_to(@public_key)
    else
      render :action => "edit"
    end
  end

  def destroy
    @public_key = PublicKey.find(params[:id])
    @public_key.destroy

    redirect_to(public_keys_url)  
  end
end
