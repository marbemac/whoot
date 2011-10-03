require 'RMagick'
include Magick

# encoding: utf-8
module Whoot #:nodoc:

  # Include this module to get ACL functionality for root level documents.
  # @example Add ACL support to a document.
  #   require "whoot"
  #   class Person
  #     include Whoot::Acl
  #   end
  module Acl
    extend ActiveSupport::Concern

    included do
      field :permissions, :default => {}
    end

    # @example Check to see if the object with the given MongoId has a given permission on this document
    #   document.has_permission?
    #
    # @param [ Mongoid ] The MongoId of the object requesting permission
    # @param [ String ] The permission to check
    #
    # @return [ bool ]
    def permission?(object_id, permission)
      permissions and permissions.instance_of? BSON::OrderedHash and permissions.has_key?(permission.to_s) and permissions[permission.to_s].include?(object_id)
    end

    # @example Allow the given MongoId to edit & delete this document
    #   document.grant_owner
    #
    # @param [ Mongoid ] The MongoId of the object to grant ownership
    #
    # @return [ bool ]
    def grant_owner(object_id)
      self.grant_permission(object_id, "edit")
      self.grant_permission(object_id, "delete")
    end

    # @example Allow the given MongoId to edit this document
    #   document.grant_edit
    #
    # @param [ Mongoid ] The MongoId of the object to grant permission
    # @param [ String|Array ] The permission(s) to grant
    #
    # @return [ bool ]
    def grant_permission(object_id, permission)
      permission = [permission] unless permission.kind_of?(Array)

      permission.each do |p|
        self.permissions[p] ||= []
        self.permissions[p] << object_id unless self.permissions[p].include?(object_id)
      end
    end

    # @example Revoke the given permission(s) from this document
    #   document.revoke_permission
    #
    # @param [ Mongoid ] The MongoId of the object to revoke permission
    # @param [ String|Array ] The permission(s) to revoke
    #
    # @return [ bool ]
    def revoke_permission(object_id, permission)
      permission = [permission] unless permission.kind_of?(Array)

      permission.each do |p|
        if self.permissions[p]
          self.permissions[p].delete(object_id)
        end
      end
    end
  end

  # Include this module to enable image handling on a document
  # @example Add image handling.
  #   require "whoot"
  #   class Person
  #     include Whoot::Images
  #   end
  module Images
    extend ActiveSupport::Concern

    included do
      embeds_many :images, as: :image_assignable, :class_name => 'ImageSnippet'

      attr_accessible :asset_image
      attr_accessor :asset_image
    end

    def save_images
      self.images.each do |image|
        image.versions.each do |version|
          version.save
        end
      end
    end

    # @example Return the url to the current default image

    # @return AssetImage
    def default_image
      self.images.each do |image|
        image if image.isDefault?
      end
    end

    def add_image_version(image_id, dimensions, style)
      image = self.images.find(image_id)
      if image
        original = image.original.first.image.file
        new_image = Image.from_blob(original.read).first

        case style
          when 'square'
            new_image = new_image.resize_to_fill(dimensions[0], dimensions[1])
          else
            new_image = new_image.resize_to_fit(dimensions[0], dimensions[1])
        end

        upload_type = original.class.name
        if upload_type.include? 'Fog'
          filename = original.attributes[:key].split('/')
          filename = filename[-1]
        else
          filename = original.filename
        end

        tmp_location = "/tmp/d#{dimensions[0]}x#{dimensions[1]}_#{filename}"
        new_image.write tmp_location
        version = AssetImage.new(:isOriginal => false, :resizedTo => "#{dimensions[0]}x#{dimensions[1]}", :style => style, :width => new_image.columns, :height => new_image.rows)
        version.id = image.id
        version.image.store!(File.open(tmp_location))
        image.versions << version
        version.save
      end
    end

    def save_original_image
      if valid? && @asset_image && (@asset_image["image_cache"] != '' || @asset_image["remote_image_url"] != '')
        # Create/attach the news image
        image_snippet = ImageSnippet.new
        image_snippet.user_id = user.id
        image_snippet.add_uploaded_version(@asset_image, true)
        self.images << image_snippet
      end
    end
  end
end
