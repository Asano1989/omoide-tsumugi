class PasswordsController < ApplicationController
  before_action :authenticate_user!

  # メールアドレス入力画面
  def new; end

  # パスワード変更画面
  def edit
  end

  # パスワード更新実行
  def update
    new_password = params[:password]
    password_confirmation = params[:password_confirmation]

    # 1. 簡易的なバリデーション
    if new_password.blank? || new_password != password_confirmation
      flash.now[:alert] = "パスワードが一致しないか、入力されていません。"
      return render :edit
    end

    # 2. SupabaseのAPIを叩いてパスワードを更新
    # ログイン時に保存したクッキー内のトークンを使用
    access_token = cookies[:rails_access_token]
    response = update_supabase_password(access_token, new_password)

    if response[:success]
      redirect_to root_path, notice: "パスワードを正常に更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました: #{response[:error]}"
      render :edit
    end
  end

  private

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
      { success: false, error: body[:msg] || "パスワードの更新に失敗しました。" }
    end
  rescue => e
    logger.error "Password Update Error: #{e.message}"
    { success: false, error: "通信エラーが発生しました。" }
  end
end