class InvitePostsController < PostsController
  before_filter :authenticate_user!

  def index
    @title = "Open Invites"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {} }
    end
  end

  def show
    @post = InvitePost.find_by_encoded_id(params[:id])
    @title = "#{@post.venue.name}" if @post
    @attendees = User.where(:_id.in => @post.attendees)
    comments = Comment.where(:post_id => @post.id, :status => 'Active')
    @comments_with_user = User.join(comments)

    render json: @invitepost
  end

  def edit
    @invitepost = Invitepost.find(params[:id])
  end

  def create
    @post = current_user.invite_posts.new(params[:invite_post])
    @post.save_original_image
    @post.save_images

    if @post.save
      response = { :redirect => invite_post_path(@post) }
      render json: response, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    @invitepost = Invitepost.find(params[:id])

    if @invitepost.update_attributes(params[:invitepost])
      head :ok
    else
      render json: @invitepost.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @invitepost = InvitePost.find_by_encoded_id(params[:id])
    @invitepost.cancel
    if @invitepost.save
      attendees = User.where(:_id.in => @invitepost.attendees)
      attendees.each do |user|
        PostMailer.invite_cancelled(@invitepost.user).deliver if user.id != current_user.id
      end
    end

    flash[:success] = 'Open invite was successfully cancelled.'

    render json: {:status => 'OK', :redirect => root_path}
  end
end
