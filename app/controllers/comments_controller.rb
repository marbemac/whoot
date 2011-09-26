class CommentsController < ApplicationController

  def create
    @comment = current_user.comments.new(params[:comment])

    respond_to do |format|
      if @comment.save
        html = render_to_string :partial => 'teaser', :locals => {:comment => @comment}
        response = {:status => 'OK', :comment => html, :root_id => @comment.post_id, :event => 'comment_created' }
        format.html { redirect_to :root_path, notice: 'Comment was successfully created.' }
        format.json { render json: response, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

end