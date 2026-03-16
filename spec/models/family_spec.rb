require 'rails_helper'

RSpec.describe Family, type: :model do
  describe '新規作成：' do
    describe 'バリデーション：' do
      let(:user) { create(:user) }
      context 'A. バリデーション通過' do
        it '全ての項目が適切に入力されており有効' do
          expect(build(:family, owner: user)).to be_valid
        end
      end

      context 'B1. nameのバリデーションが有効' do
        it 'nameが1文字の場合、有効であること' do
          expect(build(:family, :one_character_name, owner: user)).to be_valid
        end
        it 'nameが50文字の場合、有効であること' do
          expect(build(:family, :fifty_characters_name, owner: user)).to be_valid
        end
        it 'nameが通常の文字列で構成されている場合、有効であること' do
          expect(build(:family, name: '家族ファミリーFamily123', owner: user)).to be_valid
        end
        it 'nameに日本語が使用できること' do
          expect(build(:family, name: '田中家', owner: user)).to be_valid
        end
        it 'nameに英数字が使用できること' do
          expect(build(:family, name: 'Tanaka Family 2024', owner: user)).to be_valid
        end
        it 'nameにハイフンが使用できること' do
          expect(build(:family, name: '田中-佐藤家', owner: user)).to be_valid
        end
        it 'nameにカッコが使用できること' do
          expect(build(:family, name: '田中家（東京）', owner: user)).to be_valid
        end
        it 'nameに中点が使用できること' do
          expect(build(:family, name: '田中・佐藤家', owner: user)).to be_valid
        end
      end

      context 'B2. nameのバリデーションが無効' do
        it 'nameが空であるため無効であること' do
          family = build(:family, :no_name, owner: user)
          expect(family).to be_invalid
          expect(family.errors.full_messages).to include("家族（グループ）名は1文字以上で入力してください")
        end
        it 'nameがnilであるため無効であること' do
          family = build(:family, :nil_name, owner: user)
          expect(family).to be_invalid
          expect(family.errors.full_messages).to include("家族（グループ）名は1文字以上で入力してください")
        end
        it 'nameが空白文字のみであるため無効であること' do
          family = build(:family, :blank_name, owner: user)
          expect(family).to be_invalid
          expect(family.errors.full_messages).to include("家族（グループ）名は1文字以上で入力してください")
        end
        it 'nameが51文字以上であるため無効であること' do
          family = build(:family, :fifty_one_characters_name, owner: user)
          expect(family).to be_invalid
          expect(family.errors.full_messages).to include("家族（グループ）名は50文字以内で入力してください")
        end
        it '特殊記号を使用しているため無効であること' do
          family = build(:family, name: '田中家<script>', owner: user)
          expect(family).to be_invalid
          expect(family.errors.full_messages).to include('家族（グループ）名は日本語、英数字、スペース、ハイフン、カッコ、中点のみ使用できます')
        end
      end
    end

    describe 'アソシエーション：' do
      let!(:user) { create(:user) }
      let!(:family) { create(:family, owner: user) }
      context 'ownerとの関連' do
        it 'Familyがownerを持つこと' do
          expect(family.owner).to be_present
        end
        it 'ownerが正しいUserインスタンスを返すこと' do
          expect(family.owner).to eq user
        end
      end

      context 'usersとの関連' do
        it 'Familyが複数のusersを持てること' do
          user1 = create(:user, family: family)
          user2 = create(:user, family: family)
          
          expect(family.users.count).to eq 2
          expect(family.users).to include(user1, user2)
        end
      end

      context 'childrenとの関連' do
        it 'Familyが複数のchildrenを持てること' do
          child1 = create(:child, family: family)
          child2 = create(:child, family: family)

          expect(family.children.count).to eq 2
          expect(family.children).to include(child1, child2)
        end
      end

      context 'diariesとの関連' do
        let(:child) { create(:child, family: family) }
        let(:emoji) { create(:emoji) }
        it 'Familyが複数のdiariesを持てること' do
          diary1 = create(:diary, user: user, emoji: emoji, family: family, children: [child])
          diary2 = create(:diary, user: user, emoji: emoji, family: family, children: [child])

          expect(family.diaries.count).to eq 2
          expect(family.diaries).to include(diary1, diary2)
        end
      end

      context 'dependent: :destroy' do
        let(:child) { create(:child, family: family) }
        let(:emoji) { create(:emoji) }
        it 'Familyを削除すると、関連するchildrenも削除されること' do
          child
          expect { family.destroy }.to change { Child.count }.from(1).to(0)
        end
        it 'Familyを削除すると、関連するdiariesも削除されること' do
          child
          create_list(:diary, 2, user: user, emoji: emoji, family: family, children: [child])

          expect { family.destroy }.to change { Diary.count }.by(-2)
        end
        it 'Familyを削除しても、ownerは削除されないこと' do
          expect { family.destroy }.not_to change { User.count }
        end
        context 'Owner以外のUserが所属している場合' do
          it 'Familyを削除できないこと' do
            user2 = create(:user, family: family)
            expect { family.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
            expect(Family.find_by(id: family.id)).to be_present
          end
          it '関連するuserは削除されないこと' do
            user2 = create(:user, family: family)
            expect { family.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
            expect(User.find_by(id: user2.id)).to be_present
          end
        end
        
        context 'Ownerのみが所属している場合' do
          it 'Familyを削除できること' do
            expect { family.destroy }.to change { Family.count }.by(-1)
          end
          it 'Ownerは削除されないこと' do
            owner_id = user.id
            family.destroy
            expect(User.find_by(id: owner_id)).to be_present
          end
        end
      end
    end
  end
end
