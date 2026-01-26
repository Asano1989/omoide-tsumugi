class AddFamilyToDiaries < ActiveRecord::Migration[7.1]
  def change
    add_reference :diaries, :family, null: false, foreign_key: true
  end
end
