class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :repository_id
      t.integer :public_key_id

      t.timestamps
    end

    add_index :permissions, :repository_id
    add_index :permissions, :public_key_id
    add_index :permissions, [:repository_id, :public_key_id], :unique => true
  end

  def self.down
    drop_table :permissions
  end
end
