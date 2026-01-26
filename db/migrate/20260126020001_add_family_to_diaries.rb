class AddFamilyToDiaries < ActiveRecord::Migration[7.1]
  def change
    # null: true（NULLを許可）でカラムを追加
    add_reference :diaries, :family, foreign_key: true
  
    # 既存の日記データに、投稿したユーザーの family_id を流し込む（データマイグレーション）
    up_only do
      Diary.find_each do |diary|
        # ユーザーが家族に所属している場合のみ、その family_id をセット
        if diary.user.family_id
          diary.update_column(:family_id, diary.user.family_id)
        end
      end
    end

    # 最後に NULL を禁止する制約をつける
    change_column_null :diaries, :family_id, false
  end
end
