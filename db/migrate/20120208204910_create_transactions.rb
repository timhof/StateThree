class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :name
      t.string :description
      t.datetime :trans_date
      t.float :amount
      t.references :account
      t.references :user
      t.references :pocket
      t.boolean :active

      t.timestamps
    end
  end
end
