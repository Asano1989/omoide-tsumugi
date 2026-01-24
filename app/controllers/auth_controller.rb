require 'net/http'
require 'json'

class AuthController < ApplicationController
  def signup
    @user = User.new
  end

  def create_signup
    @user = User.new(signup_params)

    # 1. Rails側でのバリデーション（パスワード一致確認など）
    if @user.valid?
      # 2. Supabaseにユーザーを作成しに行く
      supabase_response = signup_to_supabase(@user.email, @user.password)

      if supabase_response[:success]
        @user.supabase_uid = supabase_response[:uid]

        # passwordはattr_accessorのため、saveしてもDBには保存されない
        if @user.save
          # 3. ログイン状態にする
          session[:user_id] = @user.id
          redirect_to root_path, notice: "ユーザー登録が完了しました"
        else
          # Rails DB保存失敗時
          flash.now[:alert] = "ユーザー登録に失敗しました"
          render :signup, status: :unprocessable_entity
        end
      else
        # Supabase側でのエラー
        flash.now[:alert] = "エラー: #{supabase_response[:error]}"
        render :signup, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "ユーザー登録に失敗しました"
      render :signup, status: :unprocessable_entity
    end
  end

  def login; end

  def create_login
    email = params[:session][:email]
    password = params[:session][:password]

    # 1. Supabaseへ認証リクエストを送る
    auth_response = authenticate_with_supabase(email, password)

    if auth_response[:success]
      # 2. 認証成功：Supabaseから返ったUIDでRails側のユーザーを特定
      user = User.find_by(supabase_uid: auth_response[:uid])

      if user
        # 3. Railsのセッションに情報を保存
        session[:user_id] = user.id
        # 必要に応じてJWTもクッキーに保存
        cookies[:rails_access_token] = {
          value: auth_response[:token],
          expires: 1.hour.from_now,
          httponly: true # JSから触らせない
        }

        redirect_to diaries_path, notice: "ログインしました。"
      else
        # SupabaseにはいるがRails DBにいない場合
        redirect_to signup_path, alert: "ユーザー情報が見つかりません。登録を行ってください。"
      end
    else
      # 認証失敗
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません。"
      render :login, status: :unauthorized
    end
  end

  def destroy
    # Railsのセッションを空にする
    reset_session

    # クッキーの削除
    cookies.delete(:rails_access_token, path: '/')

    @current_user = nil
    redirect_to root_path, notice: "ログアウトしました。", status: :see_other
  end

  def set_cookie
    # 1. JWTトークンをクッキーにセットする処理 (現状の実装)
    cookies[:rails_access_token] = {
      value: auth_params[:jwt_token],
      expires: 1.hour.from_now,
      path: '/',
      # secure: Rails.env.production?, # 環境設定に応じて
      same_site: :lax
    }

    render json: { status: 'success', message: 'ログインしました。', redirect_url: root_path }, status: :ok
  end

  private

  def auth_params
    params.require(:auth).permit(:jwt_token)
  end

  # Supabase Auth API を叩くメソッド
  def signup_to_supabase(email, password)
    url = URI("#{ENV['SUPABASE_URL']}/auth/v1/signup")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["apikey"] = ENV['SUPABASE_SERVICE_ROLE_KEY']
    request["Authorization"] = "Bearer #{ENV['SUPABASE_SERVICE_ROLE_KEY']}"
    request["Content-Type"] = "application/json"

    # ユーザー作成のためのBody
    request.body = { email: email, password: password }.to_json

    response = http.request(request)
    body = JSON.parse(response.body).with_indifferent_access

    if response.code == "200" || response.code == "201"
      uid = body[:user] ? body[:user][:id] : body[:id]

      if uid.present?
        { success: true, uid: uid }
      else
        { success: false, error: "UIDがレスポンスに含まれていません" }
      end
    else
      { success: false, error: body[:msg] || body[:error_description] || "登録に失敗しました" }
    end
  end

  def signup_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :birthday, :avatar)
  end

  # Supabaseのログインエンドポイントを叩く
  def authenticate_with_supabase(email, password)
    url = URI("#{ENV['SUPABASE_URL']}/auth/v1/token?grant_type=password")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["apikey"] = ENV['SUPABASE_SERVICE_ROLE_KEY']
    request["Content-Type"] = "application/json"
    request.body = { email: email, password: password }.to_json

    response = http.request(request)
    body = JSON.parse(response.body)

    if response.code == "200"
      {
        success: true,
        uid: body["user"]["id"],
        token: body["access_token"]
      }
    else
      { success: false }
    end
  rescue => e
    logger.error "エラー: #{e.message}"
    { success: false }
  end
end
