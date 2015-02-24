require 'json'
require 'pry'
require 'mustache'
require 'sinatra'
require 'active_record'
require './db/connection.rb'
require './db/active_record_init.rb'
require 'twilio-ruby'

get '/' do
	tags = Tag.all.to_a
	posts = Post.all.to_a.sort_by! {|k| k[:votes]}.reverse!
	

 Mustache.render(File.read('./views/home.html'), {tags: tags, posts: posts})
	
end

get '/add_tag' do
 	tags = Tag.all.to_a
 	Mustache.render(File.read('./views/add_tag.html'), {tags: tags})
	
end

get '/add_post' do
	 tags = Tag.all.to_a
	 Mustache.render(File.read('./views/add_post.html'), {tags: tags} )
	 
end

post '/add_tag' do

	Tag.create(tag_name: params['tag_name'], description: params['description'])

	redirect '/'
end

post '/add_post' do
	Post.create(title: params['title'], tagline: params['tagline'], link: params['link'], votes: 0, total_comments: 0)
	tags = Tag.find_by(tag_name: params['tag_id'])
	posts = Post.find_by(title: params['title'])

	#update posts tag_id after matching it from tags table 
	posts.tag_id = tags['id']
	posts.save
	
	#twilio and sendgrid
	# iterate through subscriptions, find the numbers and emails with matching tag_id, send message to them

	matching_subscriptions = Subscription.where(tag_id: tags['id']).to_a
	matching_phones = matching_subscriptions.map{|x| x[:phone]}
	matching_emails = matching_subscriptions.map{|x| x[:email]}

	matching_phones.each do |user_number|
		account_sid = "AC6a4960df58f6d0e0dca29dfa29212f9e"
		auth_token = "f9fb5747eebf6b8c4eedeead75596f44"
		@client = Twilio::REST::Client.new account_sid, auth_token
		message = @client.account.messages.create(
			:body => "FYI: On Own You, the #{params['tag_id']} section has a new tool posted. Come check it out!",
			:to => "#{user_number}",
			:from => "+15128139258"
		)
	end

 	redirect '/'
end

get '/posts/:id/comments' do 
	posts = Post.find_by(id: params[:id])
	comments_all = Comment.all.to_a
	# find by only returns one, so have to loop through the full array to match post id
	comments = []
	comments_all.each do |comment|
		if comment[:post_id] == params[:id].to_i
			comments.push(comment)
		end
	end

	tags = Tag.all.to_a

	Mustache.render(File.read('./views/view_comments.html'), {comments: comments, posts: posts, tags: tags})

end

post "/posts/:id/comments/new" do
	Comment.create(body: params['body'], user_id: params['user_id'], post_id: params[:id])
	posts = Post.find_by(id: params[:id])
	posts.total_comments += 1
	posts.save
	
	# double quote for this because interpolation won't work with singles quotes
	redirect "/posts/#{params[:id]}/comments"
end

get '/tags/:id' do
	posts_all = Post.all.to_a
	#filter posts down just to the ones associated with that tag
	posts = []
	posts_all.each do |post|
		if post[:tag_id] == params[:id].to_i
			posts.push(post)
		end
	end
	tags = Tag.all.to_a
	tag_subscribe = Tag.find(params[:id])    ## have to create a new variable for the subscribe hyperlink to route correctly

 	Mustache.render(File.read('./views/view_tag.html'), {tags: tags, posts: posts, tag_subscribe: tag_subscribe})
 
end

get '/tags/:id/subscribe' do
	tags = Tag.all.to_a
	Mustache.render(File.read('./views/subscribe.html'), {tags: tags})

end

post '/tags/:id/subscribe' do
	tags = Tag.find(params[:id])
	full_name = params['full_name'].downcase!
	Subscription.create({full_name: full_name, email: params['email'], phone: params['phone'], tag_id: tags.id})

	redirect "/tags/#{params[:id]}"
end


get "/posts/:id/upvote" do
	posts = Post.find_by(id: params[:id])
	posts.votes += 1
	posts.save
	
	redirect '/'
end


