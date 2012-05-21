module SoulmateHelper
  def user_nugget(user)
    nugget = {
              'id' => user.id.to_s,
              'term' => user.fullname,
              'score' => 0,
              'data' => {
                      'url' => user_path(user),
                      'location' => (user.location ? user.location.full : 'Outer Space, Unknown'),
                      'images' => User.json_images(user)
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