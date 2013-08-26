class AddSandboxToStatsMoneyTransactions < ActiveRecord::Migration
  def change
    add_column :stats_money_transactions, :sandbox, :boolean, :default => false, :null => false
  end
end
