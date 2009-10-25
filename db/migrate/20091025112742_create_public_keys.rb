class CreatePublicKeys < ActiveRecord::Migration
  def self.up
    create_table :public_keys do |t|
      t.string :description
      t.string :email
      t.text :source   

      t.timestamps
    end
  end

  def self.down
    drop_table :public_keys
  end
end
