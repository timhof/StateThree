class CreatePockets < ActiveRecord::Migration
  def change
    create_table :pockets do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
  end
end
