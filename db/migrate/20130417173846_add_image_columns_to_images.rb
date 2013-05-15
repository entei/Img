class AddImageColumnsToImages < ActiveRecord::Migration
  def change
    change_table :images do |t|
      t.has_attached_file :img
    end

  end
end
