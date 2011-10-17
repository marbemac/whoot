module ImageHelper
  def default_image_url(object, dimensions, style='default', createNow=false)
    # make sure dimensions are integers
    dimensions = dimensions.map(&:to_i)
    image = object.default_image
    version = if image then image.find_version dimensions, style else nil end

    if version
      url = version.image_url
    elsif image
      if createNow
        object.add_image_version image.id, dimensions, style
        object.save
        image = object.default_image
        version = if image then image.find_version dimensions, style else nil end
        url = version.image_url
      else
        # Queue up to process and save this image size for future requests
        Resque.enqueue(ImageProcessor, object.class.to_s, object.id.to_s, image.id.to_s, dimensions, style)
        url = image.original.first.image_url
      end
    else
      return false
    end

    if Rails.env.development?
      url = Rails.public_path+url
    end

    url
  end
end