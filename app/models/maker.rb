class Maker < ActiveRecord::Base
  rolify
  rolify
  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :jerries

  validates :name, presence: true
  validates :email, presence: true

  # ------------- Cancan # https://github.com/ryanb/cancan/wiki/ability-for-other-users
  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end
  # .Cancan

  def locale
    self[:locale] || 'en'
  end

  def self.create_with_omniauth(auth)
    create! do |maker|
      maker.provider = auth[:provider]
      maker.uid = auth[:uid]
      maker.password = Devise.friendly_token[0,20]
      maker.email = auth[:info][:name]
      maker.set_name auth[:info][:name]
    end
  end

  def set_name(email)
    if email
      self.name = email.split('@')[0][0..6] + '-' + rand(36**3).to_s(36)
      #=> 'myname-h9k' if email == 'myname@xmail.com' 
    else
      self.name = rand(36**5).to_s(36)
      #=> 'f8lk2'
    end
  end
end
