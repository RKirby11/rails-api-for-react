Aws.config.update(
  region: ENV['S3_BUCKET_REGION'],
  access_key_id: ENV['S3_ACCESS_KEY_ID'],
  secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
)