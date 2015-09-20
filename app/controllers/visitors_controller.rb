class VisitorsController < ApplicationController
	def update_library
	end

	def random_player
		if !current_user
			redirect_to  new_user_session_path
			return
		else
			if current_user.total_score == nil
				current_user.total_score = 0
			end
			if current_user.high_score == nil
				current_user.high_score = 0
			end
			current_user.save
		end
		id = rand(Song.count)
		@song = Song.offset(id).first
		@classification = Classification.new
		if session[:score] == nil
			session[:score] = 0
		end
		@score = session[:score]
		# render :text => @song.to_json
	end
end
