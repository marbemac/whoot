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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invitepost }
    end
  end

  def edit
    @invitepost = Invitepost.find(params[:id])
  end

  def create
    @post = current_user.invite_posts.new(params[:invite_post])
    @post.save_original_image
    @post.save_images

    respond_to do |format|
      if @post.save
        response = { :redirect => root_path }
        format.html { redirect_to :root_path, notice: 'Post was successfully created.' }
        format.json { render json: response, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @invitepost = Invitepost.find(params[:id])

    respond_to do |format|
      if @invitepost.update_attributes(params[:invitepost])
        format.html { redirect_to @invitepost, notice: 'Invitepost was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @invitepost.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invitepost = InvitePost.find_by_encoded_id(params[:id])
    @invitepost.cancel
    @invitepost.save

    flash[:success] = 'Open invite was successfully cancelled.'

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: {:status => 'OK', :redirect => root_path} }
    end
  end
end
