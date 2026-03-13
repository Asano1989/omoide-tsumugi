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
        it '5. nameが全角文字と半角文字を含んでおり有効' do
          expect(build(:user, :mixed_half_width_and_full_width_character_name)).to be_valid
        end
        it '6. nameが全角文字と半角記号を含んでおり有効' do
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
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
        it '4. nameが51文字以上であるため無効' do
          user = build(:user, :too_long_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名は50文字以内で入力してください")
        end
        it '5. nameが半角記号のみであり無効' do
          user = build(:user, :only_half_width_symbol_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
        it '6. nameが全角記号のみであり無効' do
          user = build(:user, :only_full_width_symbol_name)
          user.valid?
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
      end

      context 'C1. emailのバリデーションが有効：' do
        it '1. emailが大文字で入力・保存されても、DB上では小文字で保存されている' do
          user = create(:user, email: 'TEST@EXAMPLE.COM')
          expect(user.reload.email).to eq 'test@example.com'
        end
      end

      context 'C2. emailのバリデーションが無効：' do
        it '1. emailが空であるため無効' do
          user = build(:user, :no_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it '2. emailがnilであるため無効' do
          user = build(:user, :nil_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it '3. 既に存在するemailのデータと被っているため無効' do
          first_user = create(:user)
          user = build(:user, email: first_user.email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
        end
        it '4. emailが1文字しか入力されていないため無効' do
          user = build(:user, :one_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '5. emailが501文字以上入力されたため無効' do
          user = build(:user, :too_long_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスは500文字以内で入力してください")
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '6. emailに空白文字が含まれているため無効' do
          user = build(:user, :contain_blank_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '7. emailが全角文字のみで入力されたため無効' do
          user = build(:user, :only_full_width_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '8. emailが全角文字を含んでいるため無効' do
          user = build(:user, :contain_full_width_character_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '9. emailに@が入っていないため無効' do
          user = build(:user, :except_atmark_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '10. emailが半角記号のみ入力されたため無効' do
          user = build(:user, :only_half_width_symbol_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '11. emailが@、_、.以外の半角記号を含んでいるため無効' do
          user = build(:user, :contain_half_width_symbol_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '12. emailのユーザー名の部分を大文字で登録すると、小文字として一意性が保たれるため無効' do
          create(:user, email: 'test@example.com')
          user = build(:user, email: 'TEST@EXAMPLE.COM')
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
        end
        it '13. @前のユーザー名が記入されていないため無効' do
          user = build(:user, :except_username_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '14. @後のドメイン名が記入されていないため無効' do
          user = build(:user, :except_domain_from_email)
          user.valid?
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
      end

      context 'D1. passwordのバリデーションが有効：' do
        it '1. passwordが6文字であるため有効' do
          expect(build(:user, :six_character_password)).to be_valid
        end
        it '2. passwordに半角記号が含まれているため有効' do
          expect(build(:user, :contain_half_width_symbol_password)).to be_valid
        end
      end

      context 'D2. passwordのバリデーションが無効：' do
        it '1. passwordが6文字未満であるため無効' do
          user = build(:user, :too_short_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードは6文字以上で入力してください")
        end
        it '2. passwordが空白であるため無効' do
          user = build(:user, :blank_character_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードを入力してください")
        end
        it '3. passwordがnilであるため無効' do
          user = build(:user, :nil_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードを入力してください")
        end
        it '4. passwordが空白文字を含むため無効' do
          user = build(:user, :contain_blank_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it '5. passwordが全角文字のみ入力されているため無効' do
          user = build(:user, :only_full_width_character_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it '6. passwordに全角文字が含まれているため無効' do
          user = build(:user, :contain_full_width_character_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it '7. passwordが半角記号のみ入力されているため無効' do
          user = build(:user, :only_half_width_symbol_password)
          user.valid?
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
      end

      context 'E1. password_confirmationのバリデーションが有効：' do
        it '1. password_confirmationがpasswordと一致しているため有効' do
          expect(build(:user, password: 'pass123word', password_confirmation: 'pass123word')).to be_valid
        end
      end

      context 'E2. password_confirmationのバリデーションが無効：' do
        it '1. password_confirmationが未入力のため無効' do
          user = build(:user, :no_password_confirmation)
          user.valid?
          expect(user.errors.details[:password_confirmation]).to include({:error => :blank})
        end
        it '2. password_confirmationがnilのため無効' do
          user = build(:user, :nil_password_confirmation)
          user.valid?
          expect(user.errors.details[:password_confirmation]).to include({:error => :blank})
        end
        it '3. password_confirmationがpasswordと不一致のため無効' do
          user = build(:user, password_confirmation: "passwords" )
          user.valid?
          expect(user.errors.full_messages).to include("パスワード（確認）がパスワードと一致しません")
        end
      end

      context 'F. birthdayのバリデーションが無効：' do
        it '1. birthdayが未来の日付のため無効' do
          user = build(:user, :future_birthday)
          user.valid?
          expect(user.errors.full_messages).to include("誕生日を未来の日付にすることはできません")
        end
      end

      context 'G1. supabase_uidのバリデーションが有効：' do
        it '1. supabase_uidが空白のため有効' do
          expect(build(:user, :no_supabase_uid)).to be_valid
        end
        it '2. supabase_uidがnilのため有効' do
          expect(build(:user, :nil_supabase_uid)).to be_valid
        end
      end

      context 'G2. supabase_uidのバリデーションが無効：' do
        it '1. 既に存在するsupabase_uidのデータと被っているため無効' do
          first_user = create(:user)
          user = build(:user, supabase_uid: first_user.supabase_uid)
          user.valid?
          expect(user.errors.full_messages).to include("Supabase uidはすでに存在します")
        end
      end
    end

    describe 'アソシエーション：' do
      context 'A. 家族グループへの所属' do
        let(:user) { create(:user) }
        let(:family) { create(:family, owner_id: user.id) }
        it '1. Userのfamily_idに、存在するFamilyのIDを設定し、紐づけられたFamilyのオブジェクトが返ってくる' do
          user.family_id = family.id
          expect(user.family).to eq family
        end
        it '2. Userのfamily_idがnilであっても有効となる' do
          expect(build(:user, family_id: nil)).to be_valid
        end
      end

      context 'B. 管理者ユーザーとしての家族グループの紐づけ' do
        let!(:user) { create(:user) }
        let!(:family) { create(:family, owner_id: user.id) }
        it '1. owned_familyでUserが管理者ユーザーとなっているFamilyのオブジェクトが返ってくる' do
          expect(user.owned_family).to eq family
        end
        it '2. いずれの家族グループの管理者ユーザーでない場合、owned_familyでnilが返ってくる' do
          user = create(:user)
          expect(user.owned_family).to be_nil
        end
      end
    end
  end
end
