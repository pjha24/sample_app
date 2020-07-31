require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:pj)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    #invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'     #corrent pagination link
    #valid submission
    content = "Micropost working"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: content}}
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body 
    #Deleting a post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    #going to a different user to check delete links
    get user_path(users(:pj2))
    assert_select 'a', text: 'delete', count: 0
  end
end
