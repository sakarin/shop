# This migration comes from spree_faq (originally 20090526213550)
class CreateQuestionCategories < ActiveRecord::Migration
  def self.up
    create_table :question_categories do |t|
      t.string  :name
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :question_categories
  end
end
