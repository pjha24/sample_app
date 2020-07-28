class User < ApplicationRecord
    attr_accessor :remember_token

    before_save {self.email = email.downcase}
    
    validates :name, presence: true,
                    length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence:true,
                    length: {maximum: 255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true


    has_secure_password
    validates :password , presence: true, length: {minimum: 6}
    #returns hash of given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST:
                                                        BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    #returns a random string used as token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    #stores hashed token in db associated with user
    def remember 
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    #check if token of browser matches hashed value in db for that user
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    #clear remember_digest column of a user
    def forget
        update_attribute(:remember_digest, nil)
    end
    
end
