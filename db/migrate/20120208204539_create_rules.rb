class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :name
      t.string :comp_type
      t.float :comp_amount
      t.string :comp_string
      t.date :comp_date
      t.string :comp_action
      t.references :account
      t.string :type
      t.references :user
      t.integer :rank
      t.references :pocket

      t.timestamps
    end
  end
end
