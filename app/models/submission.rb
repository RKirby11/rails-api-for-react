class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :daily_word, foreign_key: :daily_word_id

  validates :image_url, presence: true, uniqueness: true
  validates :note, presence: true
  
  def presigned_image_url
      obj = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET_NAME']).object(image_url)
      return obj.presigned_url(:get, expires_in: 3600)
  end
end
