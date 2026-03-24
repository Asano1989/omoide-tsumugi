class ApplicationController < ActionController::Base
  # current_user と logged_in? の2つのメソッドをビューでも使用できるように宣言
  helper_method :current_user, :logged_in?

  def current_user
    # クライアントのクッキーに保存されたセッションデータに[:user_id]があれば、DBでそのユーザーを探した結果を
    # @current_user にキャッシュし、同一リクエスト内での重複したDB検索を防ぐ
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    # ログインしているかどうかを真偽値で返す
    # !!：否定演算子を2つ利用し、nil や false で false が、それ以外では true が返るようにしている
    !!current_user
  end

  def authenticate_user!
    # ユーザーがログイン中の場合、メソッドを終了して呼び出し元に戻る
    return if logged_in?

    # ログインしていない場合は、メッセージとともにログイン画面へリダイレクトする
    redirect_to login_path, alert: "ログインが必要です。"
  end

  def check_family
    # ログイン中のユーザーの family_id が空でない（家族に所属している）場合、メソッドを終了して呼び出し元に戻る
    return unless current_user.family_id.blank?

    # 家族に所属していない場合は、メッセージとともに家族の案内ページへリダイレクトする
    redirect_to families_guide_path, alert: '家族への登録が必要です。'
  end

  def children_presence?
    # ToDo：メソッド名を check_children_presence または require_children に修正すること

    # ログイン中のユーザーが所属する家族の子どもの情報が空でない場合、メソッドを終了して呼び出し元に戻る
    return unless current_user.family.children.empty?

    # 所属する家族に子どもの情報がない場合は、メッセージとともに家族情報の画面へリダイレクトする
    redirect_to family_path(current_user.family), alert: "子どもの情報が登録されていないため、日記の操作はできません。"
  end
end
