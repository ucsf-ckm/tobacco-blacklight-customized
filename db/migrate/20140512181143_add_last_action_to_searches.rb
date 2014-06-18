class AddLastActionToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :last_action, :string
  end
end
