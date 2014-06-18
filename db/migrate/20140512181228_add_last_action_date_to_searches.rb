class AddLastActionDateToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :last_action_date, :datetime
  end
end
