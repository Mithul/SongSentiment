
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

join_all
# billboard