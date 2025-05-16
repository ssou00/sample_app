require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do
    get root_path # ルートURLにGETリクエストを送る
    assert_template 'static_pages/home' # 正しいページテンプレートが表示されているかのテスト
    # 各ページへのリンクのテスト
    assert_select "a[href=?]", root_path , count: 3
    # count:2 はlogoとナビゲーションバーの2つのルートURLがあるから
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
                  # ?をcontact_pathに変換  
    # ApplicationHelperのfull_titleヘルパーのテスト
    get contact_path
    assert_select "title", full_title("Contact")

    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
