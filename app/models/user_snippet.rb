# Embeddable user snippet that holds useful (denormalized) user info
class UserSnippet
  include Mongoid::Document

  field :username
  field :first_name
  field :last_name
  field :public_id

  embedded_in :user_assignable, polymorphic: true

  # Return the users username instead of their ID
  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.fullname.parameterize}"
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  class << self
    def convert_for_api(snippet)
      {
              :id => snippet.id,
              :username => snippet.username,
              :first_name => snippet.first_name,
              :last_name => snippet.last_name,
              :public_id => snippet.public_id.to_i
      }
    end
  end
end