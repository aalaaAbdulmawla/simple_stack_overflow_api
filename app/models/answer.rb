class Answer < ActiveRecord::Base
	##Associations
	belongs_to :user
	belongs_to :question
	has_many :comments, as: :commentable
	has_many :votes, as: :votable

	#Validations
	validates :body, presence: :true
	validates :body, length: { maximum: 1000 }
end
