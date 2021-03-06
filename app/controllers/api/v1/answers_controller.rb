class Api::V1::AnswersController < ApplicationController
	before_action :authenticate_with_token!, only: [:create, :update, :verify_answer]
  respond_to :json

  api! "Creates a new answer [auth required]."
	def create
		answer = (Question.find(params[:question_id])).answers.build(answer_params)
		if answer.save
      render json: answer, status: 201, location: [:api, answer]
    else
      render json: { errors: answer.errors }, status: 422
    end
	end

  api! "Updates the given answer [auth required]."
	def update
    answer = current_user.answers.find(params[:id])
    if answer.update(answer_params)
      render json: answer, status: 200, location: [:api, answer]
    else
      render json: { errors: answer.errors }, status: 422
    end
  end

  api! "Shows the given answer."
	def show
		respond_with Answer.find(params[:id])
	end

  api! "Marks the given answer as accepted [auth required]"
  def verify_answer
    answer = Answer.find(params[:id])
    question = current_user.questions.find(answer.question_id)
    if question.answers.where(:accepted_flag => true).count == 0
      user = User.find(question.user_id)
      user.update(experience: user.experience + 2)
    end
    if question.answers.where(accepted_flag: true).size > 0 
      question.answers.where(:accepted_flag => true).each do |ans|
        ans.update(accepted_flag: false)
        user = User.find(ans.user_id)
        user.update(experience: user.experience - 10)
      end
    end
    if answer.accepted_flag == true
      render json: { body: "You verified this answer before." }, status: 422
    elsif answer.update(accepted_flag: true)
      user = User.find(answer.user_id)
      user.update(experience: user.experience + 10)    
      render json: answer, status: 200, location: [:api, answer]
    else
      render json: { errors: answer.errors }, status: 422
    end
  end


	private

  def answer_params
    params.require(:answer).permit(:body).merge(user_id: current_user.id)
  end
end












