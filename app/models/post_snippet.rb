class PostSnippet
  include Mongoid::Document

  field :night_type
  field :created_at, :type => Date

  embedded_in :user

end