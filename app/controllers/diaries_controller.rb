class DiariesController < ApplicationController
  # アクションが実施される前に実行するメソッド：
  #   ユーザーがログインしているかチェックする
  before_action :authenticate_user!
  #   ユーザーの属する家族に紐づけられた、かつ自分が書いた日記のみ取得する
  before_action :set_diary, only: [:edit, :update, :destroy]
  #   ユーザーが家族に所属しているかチェックする
  before_action :check_family
  #   ユーザーが所属する家族の子どもの情報が空ではないかチェックする
  before_action :children_presence?, only: [:new, :create, :edit, :update]
  #   日記に紐づいた子どもたちの情報が存在し、idが配列形式で保存されているかどうかチェック
  #   そうでない場合は、日記に紐づいた子どもたちのidを配列形式で保存する
  before_action :process_child_ids, only: [:create, :update]

  # ページング用に、1ページ当たりに表示される日記の件数を定数として宣言
  DIARY_COUNT = 5

  def index
    # 家族に所属している全員の日記を新しい順に表示
    @diaries = current_user.family.diaries.order(date: :desc)
  end

  def show
    # 所属する家族に紐づいた特定の日記を、idをもとに取得する
    @diary = current_user.family.diaries.find(params[:id])

  # 日記が見つからない場合
  rescue ActiveRecord::RecordNotFound
    # メッセージとともに、日記一覧画面へリダイレクトする
    redirect_to diaries_path, alert: '指定された日記が見つからないか、閲覧権限がありません。'
  end

  def new
    # 空のDiaryインスタンスを初期化
    @diary = Diary.new
    # 家族に紐づいた子供たちの情報を取得する
    @children = current_user.family.children
    # 絵文字を全て取得する
    @emojis = Emoji.all
  end

  def create
    # 所属する家族に紐づいた Diary インスタンスを生成する
    @diary = current_user.diaries.build(diary_params.merge(family_id: current_user.family_id))

    # 日記が正常に保存された場合
    if @diary.save
      # メッセージとともに、日記一覧画面へリダイレクトする
      redirect_to diaries_path, notice: '日記を投稿しました。', status: :see_other
    
    # 日記が正常に保存されなかった場合
    else
      # 所属する家族に紐づいた子どもたちの情報を取得する
      @children = current_user.family.children
      # 絵文字を全て取得する
      @emojis = Emoji.all
      # エラーを示すフラッシュメッセージを表示する
      flash.now[:alert] = '日記の投稿に失敗しました。'
      # バリデーションエラーを表示するため新規投稿画面をもう一度出力
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # 所属する家族に紐づいた子どもたちの情報を取得する
    @children = current_user.family.children
    # 絵文字を捨て取得する
    @emojis = Emoji.all
    # 日記に紐づけられた絵文字を取得する
    @emoji = @diary.emoji
  end

  def update
    if @diary.update(diary_params)
      # メッセージとともに、編集更新された日記の詳細画面へリダイレクトする
      redirect_to diary_path(@diary.id), notice: '日記を更新しました。', status: :see_other
    else
      # 所属する家族に紐づいた子どもたちの情報を取得する
      @children = current_user.family.children
      # 絵文字を全て取得する
      @emojis = Emoji.all
      # バリデーションエラーを表示するため編集画面をもう一度出力
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 日記を削除する
    @diary.destroy
    # メッセージとともに、日記一覧画面へリダイレクトする
    redirect_to diaries_path, notice: '日記を削除しました。', status: :see_other
  end

  # date_indexアクション：指定された日付の日記一覧を表示する
  def date_index
    # 日付情報を受け取り、取得する
    @date = params[:date]
    # 指定された日付に一致する日記を投稿順に取得する
    @diaries = current_user.family.diaries.where(date: @date).order(created_at: :asc).page(params[:page]).per(DIARY_COUNT)
  end

  def filter
    # 1. ベースのクエリ
    # 家族に紐づいている日記を、日付降順で取得する
    @diaries = current_user.family.diaries.includes(:children, :emoji).order(date: :desc).page(params[:page]).per(DIARY_COUNT)

    # パラメータの整理
    @target_child_ids = Array.wrap(params[:child_ids]).reject(&:blank?)
    @target_emoji_id = params[:emoji_id].presence

    # 2. 子どもの情報での絞り込み (AND検索)
    if @target_child_ids.present?
      target_diary_ids = DiaryChild.where(child_id: @target_child_ids)
                                   .group(:diary_id)
                                   .having('COUNT(diary_id) = ?', @target_child_ids.size)
                                   .pluck(:diary_id)
      # 絞り込まれたIDで日記をフィルタリング
      @diaries = @diaries.where(id: target_diary_ids)
      @selected_children = current_user.family.children.where(id: @target_child_ids)
    end

    # 3. 絵文字での絞り込み
    if @target_emoji_id.present?
      @diaries = @diaries.where(emoji_id: @target_emoji_id)
      @selected_emoji = Emoji.find_by(id: @target_emoji_id)
    end

    # 4. 何も選択されていない時に日記を表示しない
    return unless @target_child_ids.blank? && @target_emoji_id.blank?

    @diaries = []
  end

  def refresh_emoji
    @diary = Diary.find(params[:id])
    # 独自のレイアウトを使わず、パーシャルだけを返す
    render partial: 'diaries/emoji_list', locals: { diary: @diary }
  end

  private

  def diary_params
    params.require(:diary).permit(:date, :emoji_id, :body, child_ids: [])
  end

  def process_child_ids
    return unless params[:diary][:child_ids].present? && params[:diary][:child_ids].is_a?(String)

    # 文字列を数値の配列に変換してセットする
    params[:diary][:child_ids] = params[:diary][:child_ids].split(',')
  end

  def set_diary
    # ユーザーが所属する家族に紐づいたかつ自分が書いた日記のみを編集・削除可能とするため、それを取得する
    @diary = current_user.family.diaries.where(user_id: current_user.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to diaries_path, alert: '指定された日記が見つからないか、編集権限がありません。'
  end
end
