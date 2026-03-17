require 'rails_helper'

RSpec.describe Diary, type: :model do
  describe 'バリデーション：' do
    let(:user) { create(:user) }
    let(:family) { create(:family, owner: user) }
    context 'A. バリデーション通過' do
      it '全ての項目が適切に入力されており有効' do
        diary = create(:diary, family_instance: family)
        expect(diary).to be_valid
      end
    end

    context 'B. dateのバリデーション' do
      it 'dateがnilの場合、無効であること' do
        diary = build(:diary, :nil_date, family_instance: family)
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('日付を入力してください')
      end
      it 'dateが不正な日付形式の場合、nilとして扱われること' do
        diary = build(:diary, :invalid_date, family_instance: family)
        expect(diary.date).to be_nil
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('日付を入力してください')
      end
      it 'dateが未来の日付の場合、無効であること' do
        pending 'バリデーション実装後に追加予定'
        # diary = build(:diary, :future_date)
        # expect(diary).to be_invalid
        # expect(diary.errors.full_messages).to include('')
      end
      it 'dateが日付データである場合、有効であること' do
        diary = create(:diary, date: Date.parse('2000-01-01'), family_instance: family)
        expect(diary).to be_valid
      end
    end

    context 'C. bodyのバリデーション' do
      it 'bodyが0文字の場合、無効であること' do
        diary = build(:diary, :zero_character_body, family_instance: family)
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('本文を入力してください')
      end
      it 'bodyがnilの場合、無効であること' do
        diary = build(:diary, :nil_body, family_instance: family)
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('本文を入力してください')
      end
      it 'bodyが空白文字の場合、無効であること' do
        pending 'バリデーション実装後に追加予定'
        # diary = build(:diary, :blank_character_body, family_instance: family)
        # expect(diary).to be_invalid
        # expect(diary.errors.full_messages).to include('')
      end
      it 'bodyが通常の文字列の場合、有効であること' do
        diary = create(:diary, body: '適切な文字列', family_instance: family)
        expect(diary).to be_valid
      end
    end

    context 'D. childrenのバリデーション' do
      it 'childrenがnilの場合、無効であること' do
        diary = build(:diary, :without_children, family_instance: family)
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('子どもの情報を入力してください')
      end
      it 'childrenに1人の子どもが指定された場合、有効であること' do
        expect(create(:diary, family_instance: family)).to be_valid
      end
      it 'childrenに2人の子どもが指定された場合、有効であること' do
        expect(create(:diary, :with_two_children, family_instance: family)).to be_valid
      end
    end

    context 'E. 複数項目の確認' do
      it '必須項目（date、body、children）がすべてnilの場合、無効であること' do
        diary = build(:diary, :nil_required_fields, family_instance: family)
        expect(diary).to be_invalid
        expect(diary.errors.full_messages).to include('日付を入力してください')
        expect(diary.errors.full_messages).to include('本文を入力してください')
        expect(diary.errors.full_messages).to include('子どもの情報を入力してください')
      end
    end
  end

  describe 'アソシエーション：' do
    let(:user) { create(:user) }
    let(:family) { create(:family, owner: user) }
    context 'A. Userとの関連' do
      it 'DiaryがUserを持つこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect(diary.user).to eq(user)
      end
      it 'Userがnilでも保存できること（optional: true の確認）' # do
        # diary = create(:diary, user: nil)
        # diary.save!
        # expect(diary).to be_valid
      # end
    end

    context 'B. Familyとの関連' do
      it 'DiaryがFamilyを持つこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect(diary.family).to eq(family)
      end
    end

    context 'C. Emojiとの関連' do
      it 'DiaryがEmojiを持つこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect(diary.emoji).to be_present
      end
    end

    context 'D. childrenとの関連' do
      it 'Diaryが複数のchildrenを持てること' do
        diary = create(:diary, :with_two_children, user: user, family_instance: family)
        expect(diary.children.count).to eq(2)
      end
    end

    context 'E. reactionsとの関連' do
      it 'Diaryが複数のreactionを持てること' do
        diary = create(:diary, user: user, family_instance: family)
        create_list(:reaction, 3, diary: diary)
        expect(diary.reactions.size).to eq(3)
      end
    end

    context 'F. dependent: :destroyの確認' do
      it 'Diaryを削除すると、関連するDiaryChildrenも削除されること' do
        diary = create(:diary, user: user, family_instance: family)
        expect(diary.diary_children.count).to eq(1)
        expect { diary.destroy }.to change { DiaryChild.count }.from(1).to(0)
      end
      it 'Diaryを削除すると、関連するreactionsも削除されること' do
        diary = create(:diary, user: user, family_instance: family)
        create_list(:reaction, 2, diary: diary)
        expect { diary.destroy }.to change { Reaction.count }.by(-2)
      end
      it 'Diaryを削除しても、Userは削除されないこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect { diary.destroy }.not_to change { User.count }
      end
      it 'Diaryを削除しても、Emojiは削除されないこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect { diary.destroy }.not_to change { Emoji.count }
      end
      it 'Diaryを削除しても、Childは削除されないこと' do
        diary = create(:diary, user: user, family_instance: family)
        expect { diary.destroy }.not_to change { Child.count }
      end
      it 'Familyを削除すると、関連するDiaryも削除されること' do
        diary = create(:diary, user: user, family_instance: family)
        expect(diary.family).to eq(family)
        expect { family.destroy }.to change { Diary.count }.by(-1)
      end
    end
  end

  describe 'クラスメソッド：' do
    context 'A. child_combination_optionsメソッド' do
      let(:family) { create(:family) }
      
      context '基本的な動作' do
        it '子どもが1人の場合、1つの組み合わせが返ること' do
          child = create(:child, name: '太郎', family: family)
          
          result = Diary.child_combination_options(family)
          expect(result).to eq([['太郎', child.id.to_s]])
        end
        
        it '子どもが2人の場合、3つの組み合わせが返ること' do
          child1 = create(:child, name: '太郎', family: family)
          child2 = create(:child, name: '花子', family: family)
          
          result = Diary.child_combination_options(family)
          expect(result.size).to eq(3)
        end
        
        it '子どもが3人の場合、7つの組み合わせが返ること' do
          create_list(:child, 3, family: family)
          
          result = Diary.child_combination_options(family)
          expect(result.size).to eq(7)
        end
      end
      
      context 'エッジケース' do
        it 'Familyがnilの場合、空の配列が返ること' do
          result = Diary.child_combination_options(nil)
          expect(result).to eq []
        end
        
        it '子どもが0人の場合、空の配列が返ること' do
          expect(family.children.count).to eq(0)
          
          result = Diary.child_combination_options(family)
          expect(result).to eq []
        end
      end
      
      context 'フォーマットの検証（3人の子どもの場合）' do
        let!(:child1) { create(:child, name: '太郎', family: family) }
        let!(:child2) { create(:child, name: '花子', family: family) }
        let!(:child3) { create(:child, name: '次郎', family: family) }
        let(:result) { Diary.child_combination_options(family) }
        
        it 'ラベルが子どもの名前を＆で結合した形式になっていること' do
          expect(result[3][0]).to eq("太郎＆花子")
          expect(result[4][0]).to eq("太郎＆次郎")
          expect(result[5][0]).to eq("花子＆次郎")
          expect(result[6][0]).to eq("太郎＆花子＆次郎")
        end
        
        it 'バリューが子どもの id をカンマ区切りにした文字列になっていること' do
          expect(result[3][1]).to eq("#{child1.id},#{child2.id}")
          expect(result[4][1]).to eq("#{child1.id},#{child3.id}")
          expect(result[5][1]).to eq("#{child2.id},#{child3.id}")
          expect(result[6][1]).to eq("#{child1.id},#{child2.id},#{child3.id}")
        end
        
        it '生成される組み合わせの順序がidの昇順であること' do
          expect(result[0][1].to_i).to eq(child1.id)
          expect(result[1][1].to_i).to eq(child2.id)
          expect(result[2][1].to_i).to eq(child3.id)

          expect(result[3][1]).to eq("#{child1.id},#{child2.id}")
          expect(result[4][1]).to eq("#{child1.id},#{child3.id}")
          expect(result[5][1]).to eq("#{child2.id},#{child3.id}")

          expect(result[6][1]).to eq("#{child1.id},#{child2.id},#{child3.id}")
        end
        
        it 'すべての組み合わせが正しく生成されること' do
          expected = [
            [child1.name, child1.id.to_s],
            [child2.name, child2.id.to_s],
            [child3.name, child3.id.to_s],
            ["#{child1.name}＆#{child2.name}", "#{child1.id},#{child2.id}"],
            ["#{child1.name}＆#{child3.name}", "#{child1.id},#{child3.id}"],
            ["#{child2.name}＆#{child3.name}", "#{child2.id},#{child3.id}"],
            ["#{child1.name}＆#{child2.name}＆#{child3.name}", "#{child1.id},#{child2.id},#{child3.id}"]
          ]
          
          expect(result).to eq(expected)
        end
      end
    end
  end
end
