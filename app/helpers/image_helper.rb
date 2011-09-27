module ImageHelper
  def default_image_url(object, dimensions, style='default')
    # TODO: WTF does object.default_image return an array with 1 object in it. Return JUST the object. This applies to ALL uses of .first below...
    image = object.default_image.first
    version = if image then image.find_version dimensions, style else nil end

    if version
      response = {url: version.image_url, options: {}}
    else
      # Queue up to process and save this image size for future requests
      Resque.enqueue(ImageProcessor, object.class.to_s, object.id.to_s, image.id.to_s, dimensions, style)
      response = {url: image.original.first.image_url, options: {:width => "#{dimensions[0]}px"}}
    end

    response
  end
end