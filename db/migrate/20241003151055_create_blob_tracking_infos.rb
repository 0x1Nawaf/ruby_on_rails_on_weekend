class CreateBlobTrackingInfos < ActiveRecord::Migration[7.2]
  def change
    create_table :blob_tracking_infos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :mimetype, null: false
      t.integer :size, null: false
      t.string :data_ref_id, null: false, index: { unique: true }
      t.string :storing_type, null: false
      t.text :path, null: false

      t.timestamps
    end
  end
end
