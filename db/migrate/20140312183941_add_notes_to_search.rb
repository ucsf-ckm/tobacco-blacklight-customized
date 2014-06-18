class AddNotesToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :notes, :string
  end
end
