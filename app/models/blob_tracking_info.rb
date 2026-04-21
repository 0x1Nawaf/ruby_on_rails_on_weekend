class BlobTrackingInfo < ApplicationRecord
  belongs_to :user

  validates :data_ref_id, presence: true, uniqueness: true
end
