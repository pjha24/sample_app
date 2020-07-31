class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    attr_accessor :remember_token, :activation_token, :reset_token

    before_save :downcase_email
    before_create :create_activation_digest
    
    validates :name, presence: true,
                    length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence:true,
                    length: {maximum: 255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true


    has_secure_password
    validates :password , presence: true, length: {minimum: 6}, allow_nil: true #ok to allow nil because has_secure_password 
                                                                                #has an authentication for nil pws
                                                                                #we are allowing nill to allow users to edit
                                                                                #their info without changing their pw
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
    #works with activation and remember tokens
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")                #send grabs the attributed column from user object in db
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)        #compares hashed value in db to unhashed given
    end
    #clear remember_digest column of a user
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    def activate 
        update_columns(activated: true, activated_at: Time.zone.now)        #update columns hits the db once for both attributes and doesnt
                                                                            # run model validations
    end

    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    #sets reset attributes
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    #sends password reset email
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    def feed 
        Micropost.where("user_id=?", id)            #Return all microposts belonging to user
    end


    private
        def downcase_email
            self.email = email.downcase
        end

        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end

end
