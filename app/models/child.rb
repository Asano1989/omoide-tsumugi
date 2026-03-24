class Child < ApplicationRecord
  belongs_to :family

  has_many :diary_children, dependent: :destroy
  has_many :diaries, through: :diary_children

  validates :name, presence: true
  validates :birthday, presence: true
  validate :birthday_cannot_be_in_the_future

  private

  def birthday_cannot_be_in_the_future
    return if birthday.blank?
    return unless birthday > Date.today

    errors.add(:birthday, "を未来の日付にすることはできません")
  end
end
