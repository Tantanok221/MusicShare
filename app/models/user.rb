class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :playlists, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :user_behavior_logs, dependent: :destroy

  def admin?
    role == "admin"
  end
end
