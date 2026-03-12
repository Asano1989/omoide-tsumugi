class User < ApplicationRecord
  belongs_to :family, optional: true
  has_one :owned_family, class_name: 'Family', foreign_key: 'owner_id'
  has_one_attached :avatar
  has_many :diaries
  has_many :reactions

  attr_accessor :password, :password_confirmation

  before_save { self.email = self.email.downcase }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true,
                       format: { with: /\A(?=.*[a-zA-Z0-9])[!-~]+\z/,
                                 message: 'は英数字のいずれかを必ず含む、英数字と半角記号のみにしてください' },
length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validate :password_match, on: :create
  validates :name, presence: true, length: { maximum: 50 }
  validate :birthday_cannot_be_in_the_future
  validates :supabase_uid, uniqueness: true, allow_nil: true

  def can_create_family?
    family_id.nil? && owned_family.nil?
  end

  def display_avatar
    avatar.attached? ? avatar : "default-avatar.png"
  end

  def avatar_url
    if avatar.attached?
      # 外部ストレージのURLを返す
      Rails.application.routes.url_helpers.url_for(avatar)
    else
      # デフォルト画像のパスを返す
      ActionController::Base.helpers.asset_path('default-avatar.png')
    end
  end

  private

  def password_match
    return unless password != password_confirmation

    errors.add(:password_confirmation, "がパスワードと一致しません")
  end

  def birthday_cannot_be_in_the_future
    return unless birthday > Date.today

    errors.add(:birthday, "を未来の日付にすることはできません")
  end
end
