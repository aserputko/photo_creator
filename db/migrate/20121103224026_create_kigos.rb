class CreateKigos < ActiveRecord::Migration
  def change
    create_table :kigos do |t|
      t.string :uuid
      t.string :kigo_id
      t.integer :ha_id

      t.timestamps
    end
  end
end
