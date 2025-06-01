class CreateSpreeManualPaymentSourceTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_manual_payment_source_types do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true
      t.string :card_number
      t.string :account_number
      t.string :b1_account_code
      t.string :banK_name
      t.integer :account_type

      t.timestamps
    end

    add_index :spree_manual_payment_source_types, :name, unique: true
    add_index :spree_manual_payment_source_types, :active
  end
end 