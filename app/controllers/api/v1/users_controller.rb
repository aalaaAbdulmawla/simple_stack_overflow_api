class Api::V1::UsersController < ApplicationController
  # skip_before_filter :authenticate_user!, :only => [:show, :create, :update, :destroy]
	respond_to :json

	def show
		respond_with User.find(params[:id])
	end

	def create
		user = User.new(user_params)
		if user.save
			render json: user, status: 201, location: [:api, user]
		else
			render json: { errors: user.errors }, status: 422
		end
	end

	def update
	  user = User.find(params[:id])

	  if user.update(user_params)
	    render json: user, status: 200, location: [:api, user]
	  else
	    render json: { errors: user.errors }, status: 422
	  end
	end

	def destroy
	  user = User.find(params[:id])
	  user.destroy
	  head 204
	end

	private
	def user_params
		params.require(:user).permit(:email, :password, :password_confiramtion, :first_name,
				:last_name, :job, :location, :about, :birth_date)
	end
end
