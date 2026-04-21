class CreateBlobDataStorages < ActiveRecord::Migration[7.2]
  def change
    create_table :blob_data_storages do |t|
      t.string :data_ref_id, null: false, index: { unique: true }
      t.text :data, null: false

      t.timestamps
    end
  end
end
