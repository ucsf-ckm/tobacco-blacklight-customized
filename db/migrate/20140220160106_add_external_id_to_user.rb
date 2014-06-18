class AddExternalIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :external_id, :string
  end
end
