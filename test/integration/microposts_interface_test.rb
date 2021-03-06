require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get create_micropost_path
    #エラーメッセージが出るかどうか
    post microposts_path, params: { micropost: { content: "" } }
    assert_select 'div#error_explanation'
    # 無効な送信した時投稿が増えていないか
    get create_micropost_path
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    get root_path(@user)
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
    # 有効な送信
    content = "This micropost really ties the room together"
    title = "Sample Title"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,title: title } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'button', text: '削除'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  test "micropost home" do
    log_in_as(@user)
    get root_path
    assert_select "div.idea > .title"
    assert_select "div.idea > ul.user"
    assert_select "div.idea > div.detail"
    assert_select "div.idea > div.judge"
  end
end
