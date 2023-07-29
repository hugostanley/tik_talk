class AddReadReceiptToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :read_receipt, :datetime
  end
end
