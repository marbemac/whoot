class UploadsController < ApplicationController
  def create
    uploader = ImageUploader.new
    uploader.cache!(params[:file])
    render :json => {:image_location => uploader.cache_name, :image_path => uploader.current_path}
  end
end