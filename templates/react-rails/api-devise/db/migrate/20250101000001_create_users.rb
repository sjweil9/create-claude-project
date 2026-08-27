class CreateUsers < ActiveRecord::Migration[{{RAILS_MIGRATION_VERSION}}]
  def change
    create_table :users do |t|
      ## Database authenticatable (Devise)
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
