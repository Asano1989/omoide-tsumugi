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

  def check_family
    return unless current_user.family_id.blank?

    # 家族に所属していない場合は案内ページにリダイレクト
    redirect_to families_guide_path, alert: '家族への登録が必要です。'
  end

  def children_presence?
    # ユーザーが所属する家族に子供がいない場合
    return unless current_user.family.children.empty?
    redirect_to family_path(current_user.family), alert: "子どもの情報が登録されていないため、日記の操作はできません。"
  end
end
