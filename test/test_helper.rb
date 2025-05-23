ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # 指定のワーカー数でテストを並列実行する
  parallelize(workers: :number_of_processors)

  # test/fixtures/*.ymlのfixtureをすべてセットアップする
  fixtures :all
  
  # ApplicationHelperをtest環境でも使えるように
  include ApplicationHelper 

  def is_logged_in?
    !session[:user_id].nil? # セッションヘルパーのlogged_in?と同じ
    # testではsession Helperが使えないからここに追加
  end

end
