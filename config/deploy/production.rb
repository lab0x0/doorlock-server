
server ENV["SERVER_ADDRESS"], user: ENV["SERVER_USER"], roles: %w{web app db}
set :stage, :production
set :branch, ENV["BRANCH_NAME"] || :master

