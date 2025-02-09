require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"Example", email: "user@example.com", password: "foobar",
                      password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "      "
    assert_not @user.valid?
  end
  test "email should be present" do
    @user.email = "      "
    assert_not @user.valid?
  end
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foot.COM A_US-ER@foot.bar.org first.last@foo.jp alice+bob@baz.cn]
      valid_addresses.each do |valid_address|
        @user.email = valid_address
        assert @user.valid?, "#{valid_address.inspect} should be valid"
      end    
  end
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[ user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?,"#{invalid_address.inspect} should be invalid"
    end
  end
  test "email address should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end
  test "email address should be saved as lowercase" do
    mixed_case_email = "Foo@EXAMple.com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email 
  end

  test "password should be present(nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticate? should return false if user digest is nil" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    pj = users(:pj)
    pj2 = users(:pj2)
    assert_not pj.following?(pj2)
    pj.follow(pj2)
    assert pj.following?(pj2)
    assert pj2.followers.include?(pj)
    pj.unfollow(pj2)
    assert_not pj.following?(pj2)
  end

end

