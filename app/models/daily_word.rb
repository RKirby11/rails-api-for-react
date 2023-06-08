class DailyWord < ApplicationRecord
    has_many :submissions

    validates :word, presence: true
    validates :date, presence: true, uniqueness: true
end
