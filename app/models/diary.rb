class Diary < ApplicationRecord
  belongs_to :user
  belongs_to :family
  belongs_to :emoji

  has_many :diary_children, dependent: :destroy
  has_many :children, through: :diary_children
  has_many :reactions, dependent: :destroy

  validates :date, :body, :children, presence: true
  validate :date_cannot_be_in_the_future
  validate :body_contains_meaningful_content

  def self.child_combination_options(family)
    return [] unless family

    children = family.children.order(:id)
    options = []

    # 全ての子どもの組み合わせを生成
    (1..children.size).each do |n|
      children.to_a.combination(n).each do |combo|
        label = combo.map(&:name).join("＆")
        value = combo.map(&:id)
        options << [label, value.join(",")]
      end
    end
    options
  end

  private

  def date_cannot_be_in_the_future
    return if date.blank?
    return unless date > Date.today

    errors.add(:date, "を未来の日にすることはできません")
  end

  def body_contains_meaningful_content
    return if body.blank?

    # ひらがな、カタカナ、漢字、英数字が1文字以上含まれているかチェック
    has_meaningful_chars = body.match?(/[ぁ-んァ-ヶー一-龠々a-zA-Z0-9]/)
    errors.add(:body, 'には文字を含めてください') unless has_meaningful_chars
  end
end
