class RemoveExternalIdFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :external_id
  end

  def down
    add_column :users, :external_id, :string
  end
end
