module Families
  class FamiliesController < ApplicationController
    before_action :authenticate_user!
    before_action :check_family, only: [:show, :edit, :update, :destroy]
    before_action :set_family, only: [:edit, :update, :destroy]
    before_action :authorize_owner, only: [:edit, :update, :destroy]

    def new
      redirect_to root_path, alert: "すでに家族に所属しているため、新しく作成することはできません。" unless current_user.can_create_family?

      @family = Family.new
    end

    def create
      service = FamilyRegistrationService.new(current_user, family_params)
      family = service.execute

      if family
        redirect_to family_path(family), notice: '家族を作成しました。', status: :see_other
      else
        flash.now[:alert] = '家族の作成に失敗しました。'
        render :new, status: :unprocessable_entity
      end
    end

    def show
      return unless current_user.family.present?

      @family = current_user.family
      @members = @family.users
    end

    def edit
      @members = @family.users
    end

    def update
      if @family.update(family_params)
        redirect_to family_path(@family), notice: '家族名を更新しました。', status: :see_other
      else
        # バリデーションエラー時は編集画面を再表示
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # 条件1：家族のメンバーが自分（管理者）以外にいないこと
      return redirect_to family_path(@family), alert: '自分以外のメンバーがいる場合は家族を削除できません。' if @family.users.count > 1

      # 条件2：子どもの情報が一つも存在していないこと
      return redirect_to family_path(@family), alert: '子どもの情報がある場合は家族を削除できません。' if @family.children.count.positive?

      ActiveRecord::Base.transaction do
        # 1. ユーザーの family_id を空にする
        current_user.update!(family_id: nil)
        # 2. 家族レコードを削除
        @family.destroy!
      end

      redirect_to root_path, notice: '家族を削除しました。', status: :see_other
    rescue StandardError
      redirect_to family_path(@family), alert: '家族の削除に失敗しました。'
    end

    private

    def set_family
      @family = Family.find_by(owner_id: current_user.id)
    end

    # オーナー以外は編集できないようにする
    def authorize_owner
      if current_user.family.present?
        if @family.nil?
          redirect_to root_path, alert: '家族（グループ）の情報を取得できませんでした。'
        elsif @family.owner_id != current_user.id
          redirect_to root_path, alert: '編集権限がありません。'
        end
      else
        redirect_to root_path, alert: '家族（グループ）の情報がありません。'
      end
    end

    def family_params
      params.require(:family).permit(:name)
    end
  end
end
