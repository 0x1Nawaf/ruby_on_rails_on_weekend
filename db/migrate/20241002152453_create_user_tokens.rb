class CreateUserTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :user_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.text :token, null: false
      t.boolean :activated, default: true

      t.timestamps
    end
  end
end
