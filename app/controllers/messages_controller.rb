class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :parse_message_and_get_current_user

  def receive
    
    # key
    if @message.options[:message_type] == :text and @message.options[:content].downcase == 'key' and current_user.member?

      totp = ROTP::TOTP.new(Rails.application.secrets.totp_token)
      @sending_text = "🔑 " + totp.at(Time.now + 5) + "#"
      render :template => "messages/text", :formats => :xml

    # unsubscribe/unsubscribe
    elsif @message.options[:message_type] == :event and  (@message.options[:event] == :subscribe or @message.options[:event] == :unsubscribe)

      # TODO: токен надо хранить в файле pstore yaml, убрать копипаст
      api = Wechat::Adapter::WechatAPI.new(Rails.application.secrets.app_id, Rails.application.secrets.app_secret)
      count = (api.get 'user/get')['count']

      client = MQTT::Client.connect(Rails.application.secrets.mqtt_server)
      msg =  "counter:#{count}"
      client.publish(Rails.application.secrets.mqtt_topic, msg, retain=false)
      client.disconnect()

      head 200

    # adduser
    elsif @message.options[:message_type] == :text and (@message.options[:content].downcase =~ /^adduser\s\S+/) != nil and current_user.admin?

      openid = (@message.options[:content].match /(\w*)\s(\S+)/)[2]

      if User.find_by_openid(openid).nil?

        # TODO: токен надо хранить в файле pstore yaml, убрать копипаст
        api = Wechat::Adapter::WechatAPI.new(Rails.application.secrets.app_id, Rails.application.secrets.app_secret)
        user = api.get 'user/info', {openid: openid}

        if user['subscribe'] == 1
          new_user = User.new(openid: openid, name: user['nickname'])

          if new_user.valid?
            new_user.save
            @sending_text = "👌 user has added"
            render :template => "messages/text", :formats => :xml
          else
            @sending_text = "😧"
            render :template => "messages/text", :formats => :xml
          end
          
        else
          @sending_text = "😧 user should follow wechat account"
          render :template => "messages/text", :formats => :xml
        end

      else

        @sending_text = "😧 user already exists"
        render :template => "messages/text", :formats => :xml

      end


    # users
    elsif @message.options[:message_type] == :text and (@message.options[:content].downcase =~ /^users.*/) != nil and current_user.admin?
      all_users = User.all
      @sending_text = "id   name\n\n" + all_users.map{|u| "#{u.id}. #{u.name}" }.join("\n") + "\n\ntotal users: #{all_users.count}"
      render :template => "messages/text", :formats => :xml

    # deluser
    elsif @message.options[:message_type] == :text and (@message.options[:content].downcase =~ /^deluser\s\d+/) != nil and current_user.admin?

      openid = (@message.options[:content].match /(\w*)\s(\d+)/)[2]

      old_user = User.find_by_id(openid.to_i)

      if !old_user.nil?

        if !old_user.admin?

          old_user.destroy

          @sending_text = "👌 user has deleted"
          render :template => "messages/text", :formats => :xml              

        else
    
          @sending_text = "😧 you can not delete admin"
          render :template => "messages/text", :formats => :xml          
        
        end

      else
        @sending_text = "😧 no such user"
        render :template => "messages/text", :formats => :xml
      end

    # help
    elsif @message.options[:message_type] == :text and (@message.options[:content].downcase =~ /^help.*/) != nil and current_user.admin?
      @sending_text = <<-eos
Commands: 

users - list all users

adduser - add a new user 
👉 example: adduser o8POWszdG1T0ZEVYv5qWrZxO0BAM  

deluser - delete a user
👉 example: deluser 1
      eos

      render :template => "messages/text", :formats => :xml

    else
      head 200
    end

  end


  private

  def parse_message_and_get_current_user
    parse_message
    current_user
    check_access
  end

  def parse_message
    @message = MessageParser.parse(request.body.read)
  end

  def current_user
    User.find_by_openid(@message.options[:to_user])
  end

  def check_access
    # membership
    if @message.options[:message_type] == :text and (@message.options[:content].downcase =~ /^membership.*/) != nil

      @sending_text = <<-eos
This is your wechat id ☝️

#{@message.options[:to_user]} 

Please copy it and send to 👉 #{Rails.application.secrets.admin} 
      eos

      render :template => "messages/text", :formats => :xml
    else 
      @sending_text = "💩 access denied"
      render :template => "messages/text", :formats => :xml if current_user.nil?
    end
    # TODO: добавить проверку на suspended
  end

end