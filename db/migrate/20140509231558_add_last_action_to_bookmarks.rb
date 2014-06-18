class AddLastActionToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :last_action, :string
  end
end
