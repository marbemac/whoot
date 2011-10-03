# Embeddable image snippet that holds useful (denormalized) image info
class ImageSnippet
  include Mongoid::Document

  field :status, :default => 'Active'
  field :isDefault, :default => true
  field :user_id
  embeds_many :versions, :class_name => 'AssetImage'

  embedded_in :image_assignable, polymorphic: true

  def add_uploaded_version(params, isOriginal=false)
    params.merge!( {:isOriginal => isOriginal} )
    version = AssetImage.new(params)
    version.id = id
    if params[:image_cache]
      version.image.store! params[:image_cache]
    end
    self.versions << version
  end

  def find_version dimensions, style
    versions.where(:resizedTo => "#{dimensions[0]}x#{dimensions[1]}", :style => style).first
  end

  def original
    versions.each do |version|
      version if version.isOriginal
    end
  end


end