class AddDueOnToStatements < ActiveRecord::Migration
  def change
    add_column :statements, :due_on, :date
    add_index :statements, :due_on
  end
end
