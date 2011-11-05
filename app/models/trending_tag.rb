class TrendingTag
  include Mongoid::Document

  field :name
  field :popularity, :default => 0
  field :city_id

  index(
    [
      [ :city_id, Mongo::ASCENDING ],
      [ :popularity, Mongo::DESCENDING ]
    ]
  )

end