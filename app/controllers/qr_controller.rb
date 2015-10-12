class QrController < ApplicationController

  def welcome
    if params[:nonce]
      # TODO: Сделать проверку подписи
      render :text => params[:echostr]
    else
      render html: """<b>Wechat Door Lock<b/>""".html_safe
    end
  end

end
