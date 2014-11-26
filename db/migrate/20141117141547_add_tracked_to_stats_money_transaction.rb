class AddTrackedToStatsMoneyTransaction < ActiveRecord::Migration
  def change
    add_column :stats_money_transactions, :tracked,            :boolean, :default => false, :null => false
    add_column :stats_money_transactions, :chargeback_tracked, :boolean, :default => false, :null => false
  end
end
