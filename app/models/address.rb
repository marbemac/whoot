class Address
  include Mongoid::Document

  field :street
  field :city
  field :state_code
  field :zipcode
  field :country

  embedded_in :has_address, :polymorphic => true

end