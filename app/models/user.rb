class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  after_save :create_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :user_tokens
  has_many :blob_tracking_infos



  private
  def create_token
    self.user_tokens.create!
  end
end
