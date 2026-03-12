class User < ApplicationRecord
  belongs_to :family, optional: true
  has_one :owned_family, class_name: 'Family', foreign_key: 'owner_id'
  has_one_attached :avatar
  has_many :diaries
  has_many :reactions

  attr_accessor :password, :password_confirmation

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validate :password_match, on: :create
  validates :name, presence: true

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
end
