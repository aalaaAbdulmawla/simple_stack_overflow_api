class User < ActiveRecord::Base
  ##Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
        # :confirmable, :lockable, :timeoutable 

  ##Associations
  has_many :questions, dependent: :destroy
  has_many :answers,   dependent: :destroy
  has_many :comments,  dependent: :destroy
  has_many :votes,     dependent: :destroy
  has_many :favorite_questions, dependent: :destroy
  has_many :favorites, through: :favorite_questions, source: :question
  has_many :edit_suggestions, dependent: :destroy

  has_many :featured_questions, dependent: :destroy
  has_many :featureds, through: :featured_questions, source: :question

  ##validations
  validates :first_name, :last_name, length: { maximum: 30}
  validates :location, :job, length: { maximum: 65}
  validates :about, length: { maximum: 500}
  validates :auth_token, uniqueness: true
  
  validates :birth_date, date: { before: Proc.new { Time.now - 10.year } }, allow_blank: true

  validate :age_must_be_greater_than_ten

  ##Callbacks
  before_create :generate_authentication_token!

  ##Class methods
  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def age_must_be_greater_than_ten
    if birth_date.present? && age < 10
      errors.add(:age, "can't be less than ten.")
    end
  end    

  def self.tags(user)
   user.questions.flat_map {|q| q.tags}
  end

  private
  def age
    now = Time.now.utc.to_date
    now.year - birth_date.year - (birth_date.to_date.change(:year => now.year) > now ? 1 : 0)
  end

end




























