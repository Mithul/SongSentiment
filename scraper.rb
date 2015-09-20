
require 'nokogiri'
require 'open-uri'

def wiki
	# while true
	artists = []
	page = "&page=#{i}"
	query = "?type=artist"
	link = "https://en.wikipedia.org/wiki/List_of_best-selling_music_artists_in_the_United_States"
	puts link
	# `wget #{link}`
	# f = File.open('index.html'+query)
	# `rm index.html#{query}`
	doc = Nokogiri::HTML(open(link))
	divs = doc.css("tr td:nth-child(2) a")
	puts '*'*100
	puts divs
	artists = divs.map{|d| d.text}
	puts artists
	f=File.open("artist.dat","w")
	f.write(artists.to_s)
	f.close
	# end
end

def billboard
	artists = []
	i=0
	year = 2014
	# while true
	begin
		while year>1958
			i=0
			while i<5
				page = "?page=#{i}"
				if i == 0 
					link = "http://www.billboard.com/artists/top-100/" + year.to_s
				else
					link = "http://www.billboard.com/artists/top-100/" + year.to_s+'/'+page
				end
				puts link
				`wget #{link} -O index.html`
				f = File.open('index.html')
				`rm index.html`
				doc = Nokogiri::HTML(f.read)
				divs = doc.css("article header h1 a")
				#block-system-main > div > div > div.view-content.masonry > article:nth-child(2) > header > h1 > a
				puts '*'*100
				# puts divs
				artists = (artists + divs.map{|d| d.text}).uniq
				puts artists.to_s
				puts artists.count
				i= i+1
			end
			year = year - 1
		end
	rescue Exception => e
		puts e
		# break
	end
	f=File.open("artist_billboard.dat","w")
	f.write(artists.to_s)
	f.close
	# end
end

def join_all
	files = ['artist.dat',"artist_billboard.dat"]
	artists = []
	files.each do |file|
		f = File.open file,"r"
		x=f.read
		y=eval x
		artists = (artists+y).uniq
	end
	f=File.open("artist_final.dat","w")
	f.write(artists.to_s)
	f.close
	puts artists.count.to_s + ' Artists found'
end



def get_artist_songs

	divs = []
	artist_songs = {}
	domain = "https://en.wikipedia.org"
	link = "/w/index.php?title=Category:Songs_by_artist&subcatuntil=Anderson%2C+John%0AJohn+Anderson+%28musician%29+songs#mw-subcategories"
	puts link
	# `wget #{link}`
	# f = File.open('index.html'+query)
	# `rm index.html#{query}`
	doc = Nokogiri::HTML(open(domain+link))
	nxt = doc.css("#mw-subcategories > a:nth-child(3)")
	puts nxt
	divs = divs + doc.css("#mw-subcategories > div > div > div > ul > li > div > div.CategoryTreeItem > a")

	begin
		i = 0
		while true
			link = nxt[0]['href']
			doc = Nokogiri::HTML(open(domain+link))
			nxt = doc.css("#mw-subcategories > a:nth-child(4)")
			puts link
			divs = divs + doc.css("#mw-subcategories > div > div > div > ul > li > div > div.CategoryTreeItem > a")
			puts '*'*50+i.to_s+'*'*50
			i = i+1
		end

	rescue Exception => e
		puts e
	end

	puts '*'*100
	#puts divs
	t=[]
	divs.each do |artist_link|
		if t.count >=4
			t.each do |th|
				th.join
			end
			t=[]
		end
		t<<Thread.new{
			artist = artist_link.text[0..-7].gsub(/\(.+?\)/, '')
			artist_songs[artist] = []

			begin
				link = artist_link['href']
				doc = Nokogiri::HTML(open(domain+link))
				songs = doc.css("#mw-pages > div > div > div > ul > li > a")
				artist_songs[artist] = songs.map{|s| s.text.gsub(/\(.+?\)/, '')}
			rescue Exception => e
				puts e
			end
		}
		puts '*'*20+artist_link.text[0..-7]+'*'*20
	end
	t.each do |th|
		th.join
	end
	puts artist_songs.to_s
	puts artist_songs.keys.count
	f=File.open("artist_final.dat","w")
	f.write(artist_songs.to_s)
	f.close

end


def filter
	f=File.open("artist_final.dat","r")
	temp = f.read
	artist_songs = eval temp
	songs = 0
	artist_songs.each do |artist,song|
		songs = songs + song.count
	end
	puts songs
	puts artist_songs['Coldplay']
#	artist_songs.delete('Lists of songs by recording a')
#	f=File.open("artist_final.dat","w")
#	f.write(artist_songs.to_s)
#	f.close

end

def youtube_dl file

	require 'fileutils'
	require 'uri'
	f=File.open(file,"r")
	temp = f.read
	artist_songs = eval temp
	domain = "https://www.youtube.com"
	folder = ""
	t = []
	artist_songs.each do |artist,songs|
		if t.count > 4
			t.each do |th|
				th.join
			end
			t=[]
		end
		#t << Thread.new{
		if songs.count > 0
			folder = artist.split(' ').join('-')
			FileUtils::mkdir_p folder
		end
		songs.each do |song|
			begin
				query = URI.escape(artist + song).split("'").join('%27')
				puts query
				link = "https://www.youtube.com/results?search_query=#{query}"
				doc = Nokogiri::HTML(open(link))
				song_link = domain  +doc.css("li > div > div > div.yt-lockup-content > h3 > a")[0]['href']
				puts song_link
				`youtube-dl --extract-audio --audio-format mp3 #{song_link} -o #{folder+'/'+song.split(' ').join('\ ').split("'").join('')+'.mp3'}`
			rescue
			end
		end
		#}
	end

end

def splitter
	f=File.open("artist_final.dat","r")
	temp = f.read
	artist_songs = eval temp
	artist_songs.keys.each do |a|
		puts a+" Air"
		if a["Dick and Dee"] != nil
			break
		else
			artist_songs.delete(a)
		end
	end

	f=File.open("new.dat","w")
	f.write(artist_songs.to_s)
	f.close
end

def downloaded_list
	songs = Dir.glob('**/*.mp3')
	puts songs.to_s
	artists = []
	songs1 = []
	songs.each do |song|
		artist = song.split('/')[0].split('-').join(' ')
		song_name = song.split('/')[-1]
		songs1 << {name: song_name, artist: artist, link: song}
	end

	songs1 = songs1.uniq
	
	puts songs1
end

downloaded_list
#splitter
#youtube_dl "new.dat"
#filter 
#get_artist_songs
#join_all
# billboard
