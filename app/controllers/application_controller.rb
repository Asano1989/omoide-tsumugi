class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    # セッションにIDがあれば、そのユーザーをDBから探す（結果を@current_userにキャッシュ）
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    # current_user が存在すれば true を返す
    !!current_user
  end

  def authenticate_user!
    # ログインしていない場合はログイン画面へ飛ばす
    return if logged_in?

    redirect_to login_path, alert: "ログインが必要です。"
  end
end
