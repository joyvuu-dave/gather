class AddLastInvoiceIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :last_invoice_id, :integer, index: true
    add_foreign_key :accounts, :invoices, column: :last_invoice_id
  end
end
