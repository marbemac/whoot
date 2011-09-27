class ImageProcessor
  extend HerokuResqueAutoScale if Rails.env.production? or Rails.env.staging?
  include Resque::Plugins::UniqueJob

  @queue = :images_queue

  def self.perform(target_model, target_id, image_id, dimensions, style)
    target = Kernel.const_get(target_model).find(target_id)
    target.add_image_version image_id, dimensions, style
    target.save
  end
end