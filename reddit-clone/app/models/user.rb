# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
    validates :username, :session_token, :password_digest, presence: true
    validates :username, :session_token, uniqueness: true 
    validates :password, length: {minimum:6}, allow_nil: true 

    attr_reader :password
    before_validation :ensure_session_token 

    has_many :subs,
        foreign_key: :moderator_id,
        class_name: :Sub,
        dependent: :destroy

    has_many :posts,
        foreign_key: :author_id,
        class_name: :Post,
        dependent: :destroy

    has_many :comments,
        foreign_key: :author_id,
        class_name: :Comment, 
        dependent: :destroy

    has_many :posts_commented_on, 
        through: :comments,
        source: :post


    #SPIRE

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        if user && user.is_password?(password)
            user 
        else 
            nil 
        end 
    end 

    def password=(password)
        self.password_digest = BCrypt::Password.create(password)
        @password = password
    end 

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end 


    def reset_session_token!
        self.session_token = generate_unique_session_token
        self.save!
        self.session_token
    end 

    def ensure_session_token
        self.session_token ||= generate_unique_session_token
    end


    private 

    def generate_unique_session_token
        while true 
            token = SecureRandom::urlsafe_base64
            return token if !User.exists?(session_token: token)
        end 
    end 
end
