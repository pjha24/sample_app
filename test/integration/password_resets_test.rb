require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear 
    @user = users(:pj)
  end
  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    #Invalid email
    post password_resets_path, params: {password_reset: {email: ""}}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    #Valid Email
    post password_resets_path, params: {password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #Password Reset Form
    user = assigns(:user)
    #Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    #Inactive User
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #Right email Wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    #Right email Right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #Invalid password and confirmation
    patch password_reset_path(user.reset_token), params: {email: user.email, user: {password: "foobar", password_confirmation: "barfoo"}}
    assert_select 'div#error_explanation'
    #Empty password
    patch password_reset_path(user.reset_token), params: {email: user.email, user: {password: "", password_confirmation: ""}}
    assert_select 'div#error_explanation'
    #Valid Password and Confirmation
    patch password_reset_path(user.reset_token), params: {email: user.email, user: {password: "foobar", password_confirmation: "foobar"}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: {password_reset: {email: @user.email}}
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: {email: @user.email, user: {password: "foobar", password_confirmation: "foobar"}}
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body    #searches for "expired" in html body
  end
end
