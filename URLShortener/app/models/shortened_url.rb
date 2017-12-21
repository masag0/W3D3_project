# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  short_url  :string           not null
#  long_url   :text             not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :short_url, uniqueness: true, presence: true

  def self.random_code(user, long_url)
    string = SecureRandom::urlsafe_base64(16)
    short = ShortenedUrl.create(short_url: string, long_url: long_url, user_id: user.id)
    until short.valid?
      url = SecureRandom::urlsafe_base64(16)
      short = ShortenedUrl.create(short_url: url, long_url: long_url, user_id: user.id)
    end
  end

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit

  has_many :visitors,
    through: :visits,
    source: :user

    has_many :visitors_distinct,
      -> { distinct },
      through: :visits,
      source: :user

    def num_clicks
      visitors.count
    end

    def num_uniques
      visitors_distinct.count
    end

    def num_recent_uniques
      visits.where('updated_at >= ?', 30.minutes.ago).distinct(:user_id).count
    end
end
