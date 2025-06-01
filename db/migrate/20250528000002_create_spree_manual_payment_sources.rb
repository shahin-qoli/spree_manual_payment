class CreateSpreeManualPaymentSources < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_manual_payment_sources do |t|
      t.string :from_data, null: false
      t.string :to_data
      t.text :description
      t.datetime :transaction_date
      t.references :manual_payment_source_type
      t.references :user, null: true
      t.references :payment_method
      t.datetime :deleted_at
      t.integer :created_by_id
      t.string :peygiri_number

      t.timestamps
    end

  end
end 