require 'submail'
class Api::V1::PasscodesController < ApplicationController
  def create
      message_config = {}
      message_config["appid"] = "10241"
      message_config["appkey"] = "1cb904dd53fe7a6dcf908921469a3a1d"
      message_config["signtype"] = "md5"
      
      messagexsend = MessageXSend.new(message_config)
      messagexsend.add_to(params[:phone_number])
      messagexsend.set_project("yy0u4")
      messagexsend.add_var("passcode", params[:passcode][:code])
      puts messagexsend.message_xsend()
  end
  
  private
  def passcode_params
      params.require(:passcode).permit(:phone_number)
  end
end
