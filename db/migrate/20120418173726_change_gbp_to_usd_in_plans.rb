class ChangeGbpToUsdInPlans < ActiveRecord::Migration
  def change
    change_table :plans do |t|
      t.remove :cost_gbp
      # http://stackoverflow.com/questions/5072610/ruby-and-money-in-a-rails-app-how-to-store-money-values-in-the-db
      t.column(:cost_usd, :decimal, :precision => 6, :scale => 2)
    end
  end
end
