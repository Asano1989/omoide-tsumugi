class Family < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_many :users
  has_many :children, dependent: :destroy
  has_many :diaries, dependent: :destroy

  before_validation :strip_whitespace
  validates :name, presence: true,
                   length: { in: 1..50 },
                   format: {
                     with: /\A[ぁ-んァ-ヶー一-龠々a-zA-Z0-9\s\-()（）・]+\z/,
                     message: 'は日本語、英数字、スペース、ハイフン、カッコ、中点のみ使用できます'
                   }

  private

  def strip_whitespace
    self.name = name&.strip
  end
end
