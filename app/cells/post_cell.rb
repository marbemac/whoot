class PostCell < Cell::Rails

  include ActionController::Caching
  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  def create
    @user = current_user
    @my_post = Post.current_post(@user)
    @venues = Venue.where(:status => 'Active', :city_id => @user.location.id).order(:slug, :asc)
    render
  end

  def feed
    @user = current_user
    @my_post = Post.current_post(@user)
    @posts = Post.following_feed(current_user, session[:feed_filters], true)

    venue_ids = []
    tag_ids = []
    @posts.each do |post|
      unless !post.venue || venue_ids.include?(post.venue.id)
        venue_ids << post.venue.id
      end
      unless !post.tag || tag_ids.include?(post.tag.id)
        tag_ids << post.tag.id
      end
    end

    @trending_venues = Venue.near(@user.location.coordinates.reverse, 20).where(:popularity.gt => 0).order_by([[:popularity, :desc]]).limit(5).to_a
    @my_trending_venues = Venue.where(:_id => {"$in" => venue_ids}, :popularity.gt => 0).order_by([[:popularity, :desc]]).limit(5)
    @trending_tags = TrendingTag.where(:city_id => @user.location.id).order_by([[:popularity, :desc]]).limit(5)
    @my_trending_tags = Tag.where(:_id => {"$in" => tag_ids}, :popularity.gt => 0).order_by([[:popularity, :desc]]).limit(5)

    render
  end
end