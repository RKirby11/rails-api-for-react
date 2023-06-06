class Submission < ApplicationRecord
    belongs_to :user

    validates :image_url, presence: true, uniqueness: true
    validates :note, presence: true
end
