# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  #include CarrierWave::RMagick
  #include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # SET IN THE carrier_wave.rb INITIALIZER ON A PER ENVIRONMENT BASIS
  #storage :file
  #storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env.development?
      "uploads/images/#{model.id}"
    else
      model.id
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  #def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  #end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  #def scale(width, height)
  #  resize_to_fit(width, height)
  #end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
     @name ||= "#{model._public_id.to_i.to_s(36)}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
