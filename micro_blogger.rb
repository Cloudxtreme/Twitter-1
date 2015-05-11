require 'jumpstart_auth'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class MicroBlogger 
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "This tweet is too long."
		end
	end

	def run
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when "t" then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_friends(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		puts message
		message = "d @#{target} #{message}"
		screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name }
		if screen_names.include?(target)
			tweet(message)
		else
			puts "You can only DM people who are following you."
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << @client.user(follower).screen_name
		end 
		return screen_names
	end

	def spam_my_followers(message)
		followers_list.each do |x|
			dm(x, message)
		end
	end

	def everyones_last_tweet
		friends = @client.friends
		friends.each do |friend|
			last_message = friend.status.text
			puts "#{friend.screen_name} tweeted:"
			puts last_message
			puts ""
		end
	end

	blogger = MicroBlogger.new
	blogger.run
end