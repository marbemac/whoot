module SoulmateHelper
  def user_nugget(user)
    nugget = {
              'id' => user.id.to_s,
              'term' => user.fullname,
              'score' => 0,
              'data' => {
                      'url' => user_path(user),
                      'location' => user.location.full,
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

    nugget
  end
end