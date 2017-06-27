class CreateModelBs < ActiveRecord::Migration[5.0]
  def change
    create_table :model_bs do |t|
      t.string :name
      t.references :model_a, foreign_key: true

      t.timestamps
    end
  end
end
