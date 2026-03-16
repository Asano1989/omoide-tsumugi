require 'rails_helper'

RSpec.describe User, type: :model do
  describe '新規登録：' do
    describe 'バリデーション：' do
      context 'A. バリデーション通過：' do
        it '全ての項目が適切に入力されている場合、有効であること' do
          expect(build(:user)).to be_valid
        end
      end

      context 'B1. nameのバリデーションが有効：' do
        it 'nameが1文字の場合、有効であること' do
          expect(build(:user, :one_character_name)).to be_valid
        end
        it 'nameが半角スペースを含む場合、有効であること' do
          expect(build(:user, :contain_blank_name)).to be_valid
        end
        it 'nameが全角スペースを含む場合、有効であること' do
          expect(build(:user, :contain_full_width_blank_name)).to be_valid
        end
        it 'nameが半角文字のみの場合、有効であること' do
          expect(build(:user, :only_half_width_character_name)).to be_valid
        end
        it 'nameが全角文字と半角文字を含む場合、有効であること' do
          expect(build(:user, :mixed_half_width_and_full_width_character_name)).to be_valid
        end
        it 'nameが全角文字と半角記号を含む場合、有効であること' do
          expect(build(:user, :contain_half_width_symbol_name)).to be_valid
        end
      end

      context 'B2. nameのバリデーションが無効：' do
        it 'nameが空の場合、無効であること' do
          user = build(:user, :no_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名を入力してください")
        end
        it 'nameがnilの場合、無効であること' do
          user = build(:user, :nil_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名を入力してください")
        end
        it 'nameが空白文字のみの場合、無効であること' do
          user = build(:user, :blank_character_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名を入力してください")
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
        it 'nameが51文字以上の場合、無効であること' do
          user = build(:user, :too_long_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名は50文字以内で入力してください")
        end
        it 'nameが半角記号のみの場合、無効であること' do
          user = build(:user, :only_half_width_symbol_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
        it 'nameが全角記号のみの場合、無効であること' do
          user = build(:user, :only_full_width_symbol_name)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("表示名を記号やスペースのみで入力することはできません")
        end
      end

      context 'C1. emailのバリデーションが有効：' do
        it 'emailが大文字で入力・保存されても、DB上では小文字で保存されること' do
          user = create(:user, email: 'TEST@EXAMPLE.COM')
          expect(user.reload.email).to eq 'test@example.com'
        end
      end

      context 'C2. emailのバリデーションが無効：' do
        it 'emailが空の場合、無効であること' do
          user = build(:user, :no_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it 'emailがnilの場合、無効であること' do
          user = build(:user, :nil_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスを入力してください")
        end
        it '既に存在するemailのデータと被っている場合、無効であること' do
          first_user = create(:user)
          user = build(:user, email: first_user.email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
        end
        it 'emailが1文字の場合、無効であること' do
          user = build(:user, :one_character_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailが501文字以上の場合、無効であること' do
          user = build(:user, :too_long_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスは500文字以内で入力してください")
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailに空白文字が含まれる場合、無効であること' do
          user = build(:user, :contain_blank_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailが全角文字のみの場合、無効であること' do
          user = build(:user, :only_full_width_character_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailが全角文字を含む場合、無効であること' do
          user = build(:user, :contain_full_width_character_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailに@が入っていない場合、無効であること' do
          user = build(:user, :except_atmark_from_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailが半角記号のみの場合、無効であること' do
          user = build(:user, :only_half_width_symbol_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailが許可されていない半角記号を含む場合、無効であること' do
          user = build(:user, :contain_half_width_symbol_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it 'emailのユーザー名の部分を大文字で登録した場合、小文字として一意性が保たれるため無効であること' do
          create(:user, email: 'test@example.com')
          user = build(:user, email: 'TEST@EXAMPLE.COM')
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスはすでに存在します")
        end
        it '@前のユーザー名が入力されていない場合、無効であること' do
          user = build(:user, :except_username_from_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
        it '@後のドメイン名が入力されていない場合、無効であること' do
          user = build(:user, :except_domain_from_email)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("メールアドレスの形式が正しくありません")
        end
      end

      context 'D1. passwordのバリデーションが有効：' do
        it 'passwordが6文字の場合、有効であること' do
          expect(build(:user, :six_character_password)).to be_valid
        end
        it 'passwordに半角記号が含まれる場合、有効であること' do
          expect(build(:user, :contain_half_width_symbol_password)).to be_valid
        end
      end

      context 'D2. passwordのバリデーションが無効：' do
        it 'passwordが6文字未満の場合、無効であること' do
          user = build(:user, :too_short_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードは6文字以上で入力してください")
        end
        it 'passwordが空白の場合、無効であること' do
          user = build(:user, :blank_character_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードを入力してください")
        end
        it 'passwordがnilの場合、無効であること' do
          user = build(:user, :nil_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードを入力してください")
        end
        it 'passwordが空白文字を含む場合、無効であること' do
          user = build(:user, :contain_blank_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it 'passwordが全角文字のみの場合、無効であること' do
          user = build(:user, :only_full_width_character_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it 'passwordに全角文字が含まれる場合、無効であること' do
          user = build(:user, :contain_full_width_character_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
        it 'passwordが半角記号のみの場合、無効であること' do
          user = build(:user, :only_half_width_symbol_password)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワードは英数字のいずれかを必ず含む、英数字と半角記号のみにしてください")
        end
      end

      context 'E1. password_confirmationのバリデーションが有効：' do
        it 'password_confirmationがpasswordと一致する場合、有効であること' do
          expect(build(:user, password: 'pass123word', password_confirmation: 'pass123word')).to be_valid
        end
      end

      context 'E2. password_confirmationのバリデーションが無効：' do
        it 'password_confirmationが未入力の場合、無効であること' do
          user = build(:user, :no_password_confirmation)
          expect(user).to be_invalid
          expect(user.errors.details[:password_confirmation]).to include({:error => :blank})
        end
        it 'password_confirmationがnilの場合、無効であること' do
          user = build(:user, :nil_password_confirmation)
          expect(user).to be_invalid
          expect(user.errors.details[:password_confirmation]).to include({:error => :blank})
        end
        it 'password_confirmationがpasswordと不一致の場合、無効であること' do
          user = build(:user, password_confirmation: "passwords" )
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("パスワード（確認）がパスワードと一致しません")
        end
      end

      context 'F. birthdayのバリデーションが無効：' do
        it 'birthdayが未来の日付の場合、無効であること' do
          user = build(:user, :future_birthday)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("誕生日を未来の日付にすることはできません")
        end
      end

      context 'G1. supabase_uidのバリデーションが有効：' do
        it 'supabase_uidが空白の場合、有効であること' do
          expect(build(:user, :no_supabase_uid)).to be_valid
        end
        it 'supabase_uidがnilの場合、有効であること' do
          expect(build(:user, :nil_supabase_uid)).to be_valid
        end
      end

      context 'G2. supabase_uidのバリデーションが無効：' do
        it '既に存在するsupabase_uidのデータと被る場合、無効であること' do
          first_user = create(:user, supabase_uid: 'supabase_uid')
          user = build(:user, supabase_uid: first_user.supabase_uid)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include("Supabase uidはすでに存在します")
        end
      end
    end

    describe 'アソシエーション：' do
      context 'A. 家族グループへの所属' do
        let(:user) { create(:user) }
        let(:family) { create(:family, owner_id: user.id) }
        it 'Userのfamily_idに存在するFamilyのIDを設定した場合、紐づけられたFamilyのオブジェクトが返ってくること' do
          user.family_id = family.id
          expect(user.family).to eq family
        end
        it 'Userのfamily_idがnilであっても、有効となること' do
          expect(build(:user, family_id: nil)).to be_valid
        end
      end

      context 'B. 管理者ユーザーとしての家族グループの紐づけ' do
        let!(:user) { create(:user) }
        let!(:family) { create(:family, owner_id: user.id) }
        it 'owned_familyでUserが管理者ユーザーとなっているFamilyのオブジェクトが返ってくること' do
          expect(user.owned_family).to eq family
        end
        it 'いずれの家族グループの管理者ユーザーでない場合、owned_familyでnilが返ってくること' do
          user = create(:user)
          expect(user.owned_family).to be_nil
        end
      end
    end
  end
end
