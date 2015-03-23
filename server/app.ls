require! {
	fs
	http
	twitter:Twitter
	express
	request
}

tw = new Twitter {
	consumer_key       : process.env.IKR7GYAZO_CONSUMER_KEY
	consumer_secret    : process.env.IKR7GYAZO_CONSUMER_SECRET
	access_token_key   : process.env.IKR7GYAZO_ACCESS_TOKEN_KEY
	access_token_secret: process.env.IKR7GYAZO_ACCESS_TOKEN_SECRET
}

share = (image, req, res) ->
	tw.post 'media/upload', media: image, (err, media) ->
		if err
			console.error err
			res
				.status 500
				.json message: 'Failed to upload image to Twitter.'
			return
		tw.post 'statuses/update', media_ids: media.media_id_string, (err, tweet) ->
			if err
				console.error err
				res
					.status 500
					.json message: 'Failed to post tweet.'
				return

			url = "http://#{tweet.entities.media[0].display_url}"

			res
				.status 200
				.json message: 'OK', url: url

app = express!

app.post '/share/path', (req, res) ->
	path = req.query.path

	if !path
		res
			.status 400
			.json message: 'No file specified.'
		return

	try
		fs.accessSync path, fs.R_OK
	catch
		res
			.status 400
			.json message: 'The file you specified cannot be opened.'
		return

	image = fs.readFileSync path
	share image, req, res

app.post '/share/url', (req, res) ->
	url = req.query.url

	if !url
		res
			.status 400
			.json message: 'No URL specified.'
		return

	request.get {
		url: url
		encoding: null
	}, (err, response, body) ->
		if err or response.statusCode !== 200
			res
				.status 500
				.json 'Failed to download resource from the URL you specified.'
			return
		share body, req, res

app.listen process.env.IKR7GYAZO_SERVER_PORT
