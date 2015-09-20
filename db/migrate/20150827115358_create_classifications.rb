class CreateClassifications < ActiveRecord::Migration
  def change
    create_table :classifications do |t|
      t.string :song_name
      t.string :artist
      t.integer :rating
      t.references :user, index: true
      t.string :sentiment
      t.string :genre
      t.string :lyric_link

      t.timestamps
    end
  end
end
