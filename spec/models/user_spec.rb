require 'rails_helper'

RSpec.describe User, type: :model do
  describe '新規登録：' do
    describe 'バリデーション：' do
      context 'A. バリデーション通過：' do
        it '全ての項目が適切に入力されており有効' do
          expect(build(:user)).to be_valid
        end
      end

      context 'B1. nameのバリデーションが有効：' do
        it '1. nameが1文字のみ入力されており有効' do
          expect(build(:user, :one_character_name)).to be_valid
        end
        it '2. nameが半角スペースを含んでおり有効' do
          expect(build(:user, :contain_blank_name)).to be_valid
        end
        it '3. nameが全角スペースを含んでおり有効' do
          expect(build(:user, :contain_full_width_blank_name)).to be_valid
        end
        it '4. nameが半角文字のみであり有効' do
          expect(build(:user, :only_half_width_character_name)).to be_valid
        end
        it '5. nameが半角記号のみであり有効' do
          expect(build(:user, :only_half_width_symbol_name)).to be_valid
        end
        it '6. nameが全角記号のみであり有効' do
          expect(build(:user, :only_full_width_symbol_name)).to be_valid
        end
        it '7. nameが全角文字と半角文字を含んでおり有効' do
          expect(build(:user, :mixed_half_width_and_full_width_character_name)).to be_valid
        end
        it '8. nameが全角文字と半角記号を含んでおり有効' do
          expect(build(:user, :contain_half_width_symbol_name)).to be_valid
        end
      end

      context 'B2. nameのバリデーションが無効：' do
        it '1. nameが空であるため無効' do
          user = build(:user, :no_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名を入力してください")
        end
        it '2. nameがnilであるため無効' do
          user = build(:user, :nil_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名を入力してください")
        end
        it '3. nameが空白文字のみであるため無効' do
          user = build(:user, :blank_character_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名を入力してください")
        end
        it '4. nameが51文字以上であるため無効' do
          user = build(:user, :too_long_name)
          user.valid?
          expect(user.errors.full_messages).to include("50文字以内で入力してください")
        end
      end
    end
  end
end
