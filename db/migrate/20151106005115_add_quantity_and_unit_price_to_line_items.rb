class AddQuantityAndUnitPriceToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :quantity, :integer
    add_column :line_items, :unit_price, :decimal, precision: 10, scale: 3
  end
end
