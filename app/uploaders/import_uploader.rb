class ImportUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file

  attr_reader :current_id
  def generate_id
    @current_id = SecureRandom.uuid
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/import/#{current_id}"
  end
end
