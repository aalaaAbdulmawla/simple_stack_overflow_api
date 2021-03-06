class Api::V1::VotesController < ApplicationController
	before_action :authenticate_with_token!, only: [:vote_up, :vote_down, :remove_vote]
	before_action :check_experience, only: [:vote_up, :vote_down]
	after_action :award_experience, only: [:vote_up, :vote_down]
	before_filter -> { check_if_already_voted true }, only: [:vote_up]
	before_filter -> { check_if_already_voted false }, only: [:vote_down]

	respond_to :json

	api! "Up votes the given resource [auth required]."
	def vote_up
		object = parent.votes.build({user_id: current_user.id, up_flag: true})
		view_vote(object)
	end

	api! "Down votes the given resource [auth required]"
	def vote_down
		object = parent.votes.build({user_id: current_user.id, up_flag: false})
		view_vote(object)
	end


	def view_vote(object)
		if object.save
      render json: object, status: 201, location: [:api, object]
	  else
	    render json: { errors: object.errors }, status: 422
	  end
	end

	api! "Removes the given votes [auth required]"
	def remove_vote
		vote = parent.votes.find_by_user_id(current_user.id)
		if ! vote.nil?
			user = User.find(parent.user_id)
			vote.up_flag ? user.update(experience: user.experience - 5) : user.update(experience: user.experience + 5) 
			vote.destroy
			head 404
		else
			render json: { body: "You didn't vote for this before." }, status: 422
		end
	end


	def show
		respond_with Vote.find(params[:id])
	end




	private
	def parent
    if params[:question_id]
    	Question.find params[:id] 
    elsif params[:answer_id]
    	Answer.find params[:id] 
    elsif params[:comment_id]
    	Answer.find params[:id] 
    end
  end

  def check_if_already_voted(up_flag)
  	if parent.votes.where(user_id: current_user.id).count != 0 
  		vote = parent.votes.where(user_id: current_user.id).first
  		if up_flag == vote.up_flag
  			render json: { body:  "You already voted #{up_flag == true ? "up" : "down"} for this." }, 
  						status: 422
  		end
  	end
  end

  def check_experience
  	unless current_user.experience >= 15
  		render json: { body:  "You can't vote unless your experience is above 15 } for this." }, 
  						status: 422
  	end
  end

  def award_experience
		user = User.find(parent.user_id)
		vote.up_flag ? user.update(experience: user.experience + 5) : user.update(experience: user.experience - 5) 
  end


end
