class QrController < ApplicationController

  def welcome
    if params[:nonce]
      # TODO: Сделать проверку подписи
      render :text => params[:echostr]
    else
      render html: """<b>Wechat Door Lock<b/>""".html_safe
    end

  end

  def auth
      render :text => "<h1>👻 this function is not suppoted any more</h1>"
      # redirect_to auth_client.authorize_url(Rails.application.secrets.app_redirect_url, state)
  end

  def callback
    if state == params[:state]
      user = auth_client.get_token(params[:code])
      current_user = User.find_by_openid(user.openid)

      if !current_user.nil? and current_user.member?
        client = MQTT::Client.connect(Rails.application.secrets.mqtt_server)
        client.publish(Rails.application.secrets.mqtt_topic, 'open', retain=false)
        client.disconnect()
        render :text => "<h1>😜 access allowed</h1>"
      else
        render :text => "<h1>💩 access denied</h1>"
      end

    else
      redirect_to :action => :welcome
    end
    
  end

  private


  def auth_client
    @auth_client ||= SimpleWechat::Client.new(Rails.application.secrets.app_id, Rails.application.secrets.app_secret).get_auth_client
  end

  def state
    session[:state] ||= SecureRandom.hex(3)
  end

  def check_wechat_signature
    array = [Rails.application.secrets.app_token, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end

end