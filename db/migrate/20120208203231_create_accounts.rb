class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :description
      t.references :user

      t.timestamps
    end
  end
end
