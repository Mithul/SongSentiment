class ClassificationsController < ApplicationController
  before_action :set_classification, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @classifications = Classification.all
    respond_with(@classifications)
  end

  def show
    respond_with(@classification)
  end

  def new
    @classification = Classification.new
    respond_with(@classification)
  end

  def get_lyric_link
    require 'nokogiri'
    require 'open-uri'
    # require 'net/http'
    artist = params[:artist]
    song = params[:song]
    # result = Net::HTTP.get(URI.parse("http://www.azlyrics.com/lyrics/"+artist+"/"+song+".html"))
    link = "http://www.azlyrics.com/lyrics/"+artist+"/"+song+".html"
    json = {}
    begin
      doc = Nokogiri::HTML(open(link))
      divs = doc.css("body > div.container.main-page > div > div.col-xs-12.col-lg-8.text-center > div:nth-child(9)")
      #puts divs.first.text
      json = {success: true, link: link}
    rescue
      json = {success: false}
    end
    if !json[:success]
      puts 'Checking link' + params[:link]
      link = params[:link]
      json = {}
      begin
        doc = Nokogiri::HTML(open(link))
        divs = doc.css("body > div.container.main-page > div > div.col-xs-12.col-lg-8.text-center > div:nth-child(9)")
        puts divs.first.text
        json = {success: true, link: link}
      rescue Exception => e
        puts e
        json = {success: false}
      end
    end
    render :json => json
  end

  def edit
  end

  def create
    @classification = Classification.new(classification_params)
    @classification.user = current_user
    flash[:notice] = 'Classification was successfully created.' if @classification.save
    # respond_with(@classification)
    if !params[:give_up]
      session[:score] = session[:score]+50
    else
      session[:score] = session[:score]+10
      puts 'gave up'
    end
    if params[:classification][:genre] and params[:classification][:genre].length > 0
      session[:score] = session[:score]+10
    end
    if params[:score].to_i%10==0
      score = params[:score].to_i
      current_user.total_score = current_user.total_score + score
      if score > current_user.high_score
        current_user.high_score = score
      end
      current_user.save
      session[:score] = nil
      puts 'Reseting'
    end
    redirect_to :back
  end

  def update
    flash[:notice] = 'Classification was successfully updated.' if @classification.update(classification_params)
    respond_with(@classification)
  end

  def destroy
    @classification.destroy
    respond_with(@classification)
  end


  def update_song_library
    songs = Dir.glob('**/*.mp3')
    artists = []
    songs1 = []
    # Song.all.map {|s| s.destroy}
    songs.each do |song|
      if song["public/"] != nil
        artist = song.split('/')[-2].split('-').join(' ')
        song_name = song.split('/')[-1][0..-5]
        songs1 << {name: song_name, artist: artist, link: song}
        s = Song.where(:name => song_name).first
        if s == nil
          s = Song.new
          s.name = song_name
          a = Artist.where(:name => artist).first
          if a == nil
            a = Artist.new
            a.name = artist
            a.save
          end
          s.artist = a
        end
        s.link = song[7..-1]  
        s.save
      end
    end

    songs1 = songs1.uniq
    
    render :text => songs1.to_s
  end

  private
    def set_classification
      @classification = Classification.find(params[:id])
    end

    def classification_params
      params.require(:classification).permit(:give_up, :score, :song_name, :artist, :rating, :user_id, :sentiment, :genre, :lyric_link)
    end
end
