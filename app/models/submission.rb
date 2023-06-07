class Submission < ApplicationRecord
    belongs_to :user

    validates :image_url, presence: true, uniqueness: true
    validates :note, presence: true

    def presigned_image_url()
        s3 = Aws::S3::Resource.new(
            region: ENV['AWS_REGION'], 
            access_key_id: ENV['AWS_ACCESS_KEY_ID'], 
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
        )
        obj = s3.bucket(ENV['AWS_BUCKET']).object(self.image_url)
        return obj.presigned_url(:get, expires_in: 3600)
    end
end
