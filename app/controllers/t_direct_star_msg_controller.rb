#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TDirectStarMsgController < ApplicationController
  def create
    #check unlogin user
    checkuser

    if session[:s_user_id].nil?
      redirect_to home_url
    else
      @t_direct_star_msg = TDirectStarMsg.new
      @t_direct_star_msg.userid = session[:user_id]
      @t_direct_star_msg.directmsgid = params[:id]
      @t_direct_star_msg.save

      @s_user = MUser.find_by(id: session[:s_user_id])
      redirect_to @s_user
    end
  end

  def destroy
    #check unlogin user
    checkuser

    if session[:s_user_id].nil?
      redirect_to home_url
    else
      TDirectStarMsg.find_by(directmsgid: params[:id], userid: session[:user_id]).destroy

      @s_user = MUser.find_by(id: session[:s_user_id])
      redirect_to @s_user
    end
  end
end
