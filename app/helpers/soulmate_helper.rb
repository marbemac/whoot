module SoulmateHelper
  def user_nugget(user)
    nugget = {
              'id' => user.id.to_s,
              'term' => user.fullname,
              'score' => 0,
              'data' => {
                      'url' => user_path(user),
                      'location' => (user.location ? user.location.full : 'Outer Space, Unknown'),
                      'encoded_id' => user.encoded_id,
              }
    }

    nugget
  end

  def venue_nugget(venue)
    nugget = {
              'id' => venue.id.to_s,
              'term' => venue.name,
              'score' => 0,
              'data' => {
                      'address' => venue.address
              }
    }

    if venue.aliases.length > 0
      nugget['aliases'] = venue.aliases
    end

    nugget
  end

  def tag_nugget(tag)
    nugget = {
              'id' => tag.id.to_s,
              'term' => tag.name,
              'score' => tag.score,
              'data' => {
                      'slug' => tag.slug
              }
    }

    nugget
  end
end