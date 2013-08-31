class AddPaymentsToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :num_payments, :integer,        default: 0,   null: false
    add_column :identities, :num_chargebacks, :integer,     default: 0,   null: false
    add_column :identities, :earnings, :decimal,            default: 0.0, null: false
    add_column :identities, :chargeback_costs, :decimal,    default: 0.0, null: false
    add_column :identities, :first_payment, :datetime
  end
end
