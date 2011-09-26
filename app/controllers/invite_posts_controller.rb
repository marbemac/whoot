class InvitePostsController < PostsController
  before_filter :authenticate_user!

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {} }
    end
  end

  def show
    @post = InvitePost.find_by_encoded_id(params[:id])
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
    params[:invite_post][:venue].merge!(:coordinates => params[:invite_post][:venue][:coordinates].split(' '))
    @post = current_user.invite_posts.new(params[:invite_post])

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
    @invitepost = Invitepost.find(params[:id])
    @invitepost.destroy

    respond_to do |format|
      format.html { redirect_to inviteposts_url }
      format.json { head :ok }
    end
  end
end
