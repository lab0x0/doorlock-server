Rails.application.routes.draw do
	root 'qr#welcome'
    post '/', to: 'messages#receive'
    # get '/callback' => 'qr#callback'
    # get '/auth' => 'qr#auth'
end
