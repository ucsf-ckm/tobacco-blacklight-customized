class AddNumfoundToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :numfound, :integer
  end
end
