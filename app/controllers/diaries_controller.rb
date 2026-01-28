class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: [:edit, :update, :destroy]
  before_action :check_family
  before_action :children_presence?, only: [:new, :create, :edit, :update]
  before_action :process_child_ids, only: [:create, :update]

  DIARY_COUNT = 5

  def index
    @diaries = current_user.family.diaries.order(date: :desc)
  end

  def show
    @diary = current_user.family.diaries.find(params[:id])
rescue ActiveRecord::RecordNotFound
    redirect_to diaries_path, alert: '指定された日記が見つからないか、閲覧権限がありません。'
  end

  def new
    @diary = Diary.new
    @children = current_user.family.children
    @emojis = Emoji.all
  end

  def create
    @diary = current_user.diaries.build(diary_params.merge(family_id: current_user.family_id))

    if @diary.save
      redirect_to diaries_path, notice: '日記を投稿しました。', status: :see_other
    else
      @children = current_user.family.children
      @emojis = Emoji.all
      flash.now[:alert] = '日記の投稿に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @children = current_user.family.children
    @emojis = Emoji.all
    @emoji = @diary.emoji
  end

  def update
    if @diary.update(diary_params)
      redirect_to diary_path(@diary.id), notice: '日記を更新しました。', status: :see_other
    else
      @children = current_user.family.children
      @emojis = Emoji.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to diaries_path, notice: '日記を削除しました。', status: :see_other
  end

  def date_index
    @date = params[:date]
    # 指定された日付に一致する日記を取得
    @diaries = current_user.family.diaries.where(date: @date).order(created_at: :asc).page(params[:page]).per(DIARY_COUNT)
  end

  def filter
    # 1. ベースのクエリ
    @diaries = current_user.family.diaries.includes(:children, :emoji).order(date: :desc).page(params[:page]).per(DIARY_COUNT)

    # パラメータの整理
    @target_child_ids = Array.wrap(params[:child_ids]).reject(&:blank?)
    @target_emoji_id = params[:emoji_id].presence

    # 2. 子供での絞り込み (AND検索ロジック)
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
    # current_userから辿り、現在の家族かつ自分が書いた日記のみ編集・削除可能とする
    @diary = current_user.family.diaries.where(user_id: current_user.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to diaries_path, alert: '指定された日記が見つからないか、編集権限がありません。'
  end
end
