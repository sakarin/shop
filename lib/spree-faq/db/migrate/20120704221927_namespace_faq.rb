class NamespaceFaq < ActiveRecord::Migration
  def up
    rename_table :questions, :spree_questions
    rename_table :question_categories, :spree_question_categories
  end

  def down
    rename_table :spree_questions, :questions
    rename_table :spree_question_categories, :question_categories

  end
end
