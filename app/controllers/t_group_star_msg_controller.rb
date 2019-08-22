#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TGroupStarMsgController < ApplicationController
  def create
    #check unlogin user
    checkuser

    if session[:s_channel_id].nil?
      redirect_to home_url
    elsif MChannel.find_by(id: session[:s_channel_id]).nil?
      redirect_to home_url
    else
      @t_group_star_msg = TGroupStarMsg.new
      @t_group_star_msg.userid = session[:user_id]
      @t_group_star_msg.groupmsgid = params[:id]
      @t_group_star_msg.save
      
      @m_channel = MChannel.find_by(id: session[:s_channel_id])

      redirect_to @m_channel
    end
  end

  def destroy
    #check unlogin user
    checkuser

    if session[:s_channel_id].nil?
      redirect_to home_url
    elsif MChannel.find_by(id: session[:s_channel_id]).nil?
      redirect_to home_url
    else
      TGroupStarMsg.find_by(groupmsgid: params[:id], userid: session[:user_id]).destroy
        
      @m_channel = MChannel.find_by(id: session[:s_channel_id])
      redirect_to @m_channel
    end
  end
end
