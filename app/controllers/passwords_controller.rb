class PasswordsController < ApplicationController
  # メールアドレス入力画面
  def new; end

  # リセットメール送信リクエスト
  def create
    email = params[:email]
    response = send_reset_email(email)

    if response[:success]
      redirect_to login_path, notice: "パスワード再設定用のメールを送信しました"
    else
      flash.now[:alert] = "エラー: #{response[:error]}"
      render :new
    end
  end

  # パスワード変更画面
  def edit; end

  # パスワード更新実行
  def update
    new_password = params[:password]
    password_confirmation = params[:password_confirmation]
    # 明示的に params から取る
    access_token = params[:access_token].presence || cookies[:rails_access_token]

    # バリデーション
    if new_password.blank? || new_password != password_confirmation
      flash.now[:alert] = "パスワードが一致しないか、入力されていません"
      return render :edit, status: :unprocessable_entity
    end

    if access_token.blank?
      flash.now[:alert] = "トークンが見つかりません。メールのリンクからやり直してください"
      return render :edit, status: :unprocessable_entity
    end

    response = update_supabase_password(access_token, new_password)

    if response[:success]
      cookies.delete(:rails_access_token)
      redirect_to login_path, notice: "パスワードを更新しました。新しいパスワードでログインしてください"
    else
      flash.now[:alert] = "エラー: #{response[:error]}"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def send_reset_email(email)
    # Supabaseのパスワードリカバリ用エンドポイント
    redirect_url = CGI.escape(edit_password_url)
    url = URI("#{ENV['SUPABASE_URL']}/auth/v1/recover?redirect_to=#{redirect_url}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["apikey"] = ENV['SUPABASE_SERVICE_ROLE_KEY']
    request["Authorization"] = "Bearer #{ENV['SUPABASE_SERVICE_ROLE_KEY']}"
    request["Content-Type"] = "application/json"

    request.body = { email: email }.to_json

    response = http.request(request)
    body = JSON.parse(response.body).with_indifferent_access

    if ['200', '201'].include?(response.code)
      { success: true }
    else
      { success: false, error: body[:msg] || body[:error_description] || "メール送信に失敗しました" }
    end
  rescue StandardError => e
    logger.error "Supabase Recover Error: #{e.message}"
    { success: false, error: "通信エラーが発生しました" }
  end

  def update_supabase_password(token, new_password)
    url = URI("#{ENV['SUPABASE_URL']}/auth/v1/user")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Put.new(url) # 更新なのでPUTメソッド
    request["apikey"] = ENV['SUPABASE_SERVICE_ROLE_KEY']
    request["Authorization"] = "Bearer #{token}" # ユーザーのトークンを渡す
    request["Content-Type"] = "application/json"

    request.body = { password: new_password }.to_json

    response = http.request(request)
    body = JSON.parse(response.body).with_indifferent_access

    if response.code == "200"
      { success: true }
    else
      { success: false, error: body[:msg] || "パスワードの更新に失敗しました" }
    end
  rescue StandardError => e
    logger.error "Password Update Error: #{e.message}"
    { success: false, error: "通信エラーが発生しました" }
  end
end
