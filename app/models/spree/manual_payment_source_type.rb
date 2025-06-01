module Spree
	class ManualPaymentSourceType < Spree::Base
		has_many :manual_payment_source

		validates :name, presence: true, uniqueness: true
		validates :active, inclusion: { in: [true, false] }
		validates :b1_account_code, presence: true, if: :active?

		scope :active, -> { where(active: true) }

	end
end