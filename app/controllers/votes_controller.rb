class VotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_post = NormalPost.find(params[:id])
    if target_post
      target_post.add_voter(current_user)
      if target_post.save
        pusher_publish(target_post.user_id.to_s, 'voted', {:user_id => target_post.user_id.to_s, :votes => target_post.votes, :post_id => target_post.id.to_s})
        pusher_publish(target_post.user_id.to_s+'_private', 'notification', {:content => "#{current_user.fullname} +1'd your post."})
      end
      response = {:json => {:status => 'ok', :target => '.vb-'+target_post.id.to_s, :toggle_classes => ['voteB', 'unvoteB', 'btn'], :update_target => '.v-'+target_post.id.to_s, :update_value => target_post.votes}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target post not found!'}, :status => 404}
    end

    respond_to do |format|
      format.json { render response }
    end
  end

  def destroy
    target_post = NormalPost.find(params[:id])
    if target_post
      target_post.remove_voter(current_user)
      target_post.save
      response = {:json => {:status => 'ok', :target => '.vb-'+target_post.id.to_s, :toggle_classes => ['voteB', 'unvoteB'], :update_target => '.v-'+target_post.id.to_s, :update_value => target_post.votes}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target post not found!'}, :status => 404}
    end

    respond_to do |format|
      format.json { render response }
    end
  end

  def ajax
    post = NormalPost.find(params[:post_id])
    voters = User.where(:_id.in => post.voters)
    html = render_to_string :partial => 'voters', :locals => {:voters => voters}
    response = {:status => 'OK', :content => html }
    render json: response, status: 200
  end

end