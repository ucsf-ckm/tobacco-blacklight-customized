class AddLastActionDateToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :last_action_date, :datetime
  end
end
