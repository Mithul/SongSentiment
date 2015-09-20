class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name
      t.references :artist, index: true
      t.string :link

      t.timestamps
    end
  end
end
