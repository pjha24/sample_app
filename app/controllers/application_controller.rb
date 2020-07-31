class ApplicationController < ActionController::Base
    include SessionsHelper

    private
    #checks if user is logged in 
    def logged_in_user
        unless logged_in?
        store_location
        flash[:danger] = "Please log in"
        redirect_to login_url
        end
    end
end
