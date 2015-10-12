Rails.application.routes.draw do
	root 'qr#welcome'
    post '/', to: 'messages#receive'
end
