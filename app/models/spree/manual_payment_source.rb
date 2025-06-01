module Spree
    class ManualPaymentSource < Spree::Base
  
      acts_as_paranoid
  
      belongs_to :payment_method
      belongs_to :user, class_name: Spree.user_class.to_s, foreign_key: 'user_id',
                        optional: true
      has_many :payments, as: :source
      has_many :orders, through: :payments, class_name: 'Spree::Order'
      belongs_to :manual_payment_source_type, class_name: 'Spree::ManualPaymentSourceType', foreign_key: 'manual_payment_source_type_id'
      belongs_to :created_by, class_name: "::#{Spree.admin_user_class}", foreign_key: 'created_by_id', optional: true

      scope :not_removed, -> { where(deleted_at: nil) }
  

    end
  end