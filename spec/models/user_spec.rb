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
        # it '4. nameが51文字以上であるため無効' do
        #   nameに文字数制限のバリデーションを付けること
        #   user = build(:user, :too_long_name)
        #   user.valid?
        #   expect(user.errors.full_messages).to include("50文字以内で入力してください")
        # end
      end

      context 'C. emailのバリデーションが無効：' do
        it 'emailが空であるため無効' do
          user = build(:user, :no_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it 'emailがnilであるため無効' do
          user = build(:user, :nil_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it '既に存在するemailのデータと被っているため無効' do
          first_user = create(:user)
          user = build(:user, email: first_user.email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
        end
=begin
        it 'emailが1文字しか入力されていないため無効' do
          user = build(:user, :one_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailが1000文字以上入力されたため無効' do
          user = build(:user, :thousand_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailに空白文字が含まれているため無効' do
          user = build(:user, :contain_blank_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailが全角文字のみで入力されたため無効' do
          user = build(:user, :only_full_width_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailが全角文字を含んでいるため無効' do
          user = build(:user, :contain_full_width_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailに@が入っていないため無効' do
          user = build(:user, :except_atmark_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailが半角記号のみ入力されたため無効' do
          user = build(:user, :only_half_width_symbol_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailが@、_、.以外の半角記号を含んでいるため無効' do
          user = build(:user, :contain_half_width_symbol_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it 'emailのユーザー名の部分を大文字で登録すると、小文字として一意性が保たれるため無効' do
          # emailに case_sensitive: false を設定し、エラーメッセージを確認すること
          create(:user, email: 'test@example.com')
          user = build(:user, email: 'TEST@EXAMPLE.COM')
          user.valid
          expect(user.errors.full_messages).to include("")
        end
        it '@前のユーザー名が記入されていないため無効' do
          user = build(:user, :except_username_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
        it '@後のドメイン名が記入されていないため無効' do
          user = build(:user, :except_domain_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("")
        end
=end
      end
    end
  end
end
