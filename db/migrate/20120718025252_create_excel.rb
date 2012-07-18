class CreateExcel < ActiveRecord::Migration
  def change
    create_table :spree_excels do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.timestamps
    end
  end


end
