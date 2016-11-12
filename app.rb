
require "sinatra"
require 'sinatra/activerecord'
set :database, {adapter: "sqlite3", database: "./db/doorlock.sqlite3"}

# require 'pry'
require 'nokogiri'
require 'wechat/adapter'
require 'rotp'

require "./lib/message_info.rb"
require "./lib/message_parser.rb"
require "./models/user.rb"
require "./models/users.rb"

def current_user
   User.find_by_openid(@message.options[:to_user])
end

get "/" do
  if params[:signature]
    array = [ENV['APP_TOKEN'], params[:timestamp], params[:nonce]].sort
    if params[:signature] == Digest::SHA1.hexdigest(array.join)
      params[:echostr]
    else
      status 418
      body "Forbidden"
    end
  else
    status 200
    body "OK"
  end
end

post "/" do

  if params[:signature]
    array = [ENV['APP_TOKEN'], params[:timestamp], params[:nonce]].sort
    if params[:signature] == Digest::SHA1.hexdigest(array.join)
      params[:echostr]
    else
      status 418
      body "Forbidden"
    end
  else

    @message = MessageParser.parse(request.body.read)

    if current_user && current_user.admin?

      case @message.options[:content]
      when /^users.*/i
        all_users = User.all
        @sending_text = "id   name\n\n" + all_users.map{|u| "#{u.id}. #{u.name}" }.join("\n") + "\n\ntotal users: #{all_users.count}"
      when /^adduser\s\S+\s\S+/i
        openid = (@message.options[:content].match /(\w*)\s(\S+)\s(\S+)/)[2]
        name = (@message.options[:content].match /(\w*)\s(\S+)\s(\S+)/)[3]
        new_user = User.new(openid: openid, name: name)

       if User.find_by_openid(openid)
         @sending_text = "😧 user already exists"
       elsif new_user.valid?
         new_user.save
         @sending_text = "👌 user has added"
        else
          @sending_text = "😧"
        end
      when /^deluser\s\d+/i
        id = (@message.options[:content].match /(\w*)\s(\d+)/)[2]
        user = User.find(id.to_i)
        if user.nil?
          @sending_text = "😧 user doesn't exist"
        elsif !user.admin? || current_user.type == 'Users::SuperUser'
          user.destroy
          @sending_text = "👌 user deleted"
        else
          @sending_text = "😧 can't delete admin"
        end
      when /^help.*/i
        @sending_text = "COMMANDS\n\nNOT MEMBERS:\n• membership - how to become a member\n\nMEMBERS:\n• key - get a key for the doorlock\n\nADMINS:\n• users - list all users\n• adduser - add a new user\n 👉 example: adduser o8POWszdG1T0ZEVYv5qWrZxO0BAM 肖红\n• deluser - delete a user\n 👉 example: deluser 1"
      else
        @sending_text = "💩 听不懂"
      end

      elsif current_user && current_user.member?

        case @message.options[:content]
        when /^membership.*/i
          @sending_text = "This is your wechat id ☝️\n\n#{@message.options[:to_user]}\n\nPlease copy it and send to administrator"
        when /^key.*/i
          totp = ROTP::TOTP.new(ENV['TOTP_TOKEN'])
          @sending_text = "🔑 " + totp.at(Time.now + 5) + "#"
        when /^help.*/i
          @sending_text = "COMMANDS\n\nNOT MEMBERS:\n• membership - how to become a member\n\nMEMBERS:\n• key - get a key for the doorlock"
        else
          @sending_text = "💩 听不懂"
        end

    else # not members

      case @message.options[:content]
      when /^membership.*/i
        @sending_text = "This is your wechat id ☝️\n\n#{@message.options[:to_user]}\n\nPlease copy it and send to administrator"
      when /^help.*/i
        @sending_text = "COMMANDS\n\nNOT MEMBERS:\n• membership - how to become a member\n\nMEMBERS:\n• key - get a key for the doorlock"
      else
        @sending_text = "💩 听不懂"
      end
    end

    erb :text, :format => :xml

  end

end
