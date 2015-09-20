class AddTotalScoreAndHighScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_score, :integer
    add_column :users, :high_score, :integer
  end
end
