class CreateSpreeManualPayments < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_manual_payments do |t|
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :reference_number
      t.text :notes
      t.string :status, default: 'pending'
      t.datetime :paid_at


      t.timestamps
    end

    add_index :spree_manual_payments, :reference_number
    add_index :spree_manual_payments, :status
  end
end

