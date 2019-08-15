#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TGroupStarThreadController < ApplicationController
  def create
    #check unlogin user
    checkuser

    if session[:s_group_message_id].nil?
      unless session[:s_channel_id].nil?
        @m_channel = MChannel.find_by(id: session[:s_channel_id])
        redirect_to @m_channel
      end
    elsif session[:s_channel_id].nil?
      redirect_to home_url
    else
      @t_group_star_thread = TGroupStarThread.new
      @t_group_star_thread.userid = session[:user_id]
      @t_group_star_thread.groupthreadid = params[:id]
      @t_group_star_thread.save
      
      @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
      redirect_to @t_group_message
    end
  end

  def destroy
    #check unlogin user
    checkuser

    if session[:s_group_message_id].nil?
      unless session[:s_channel_id].nil?
        @m_channel = MChannel.find_by(id: session[:s_channel_id])
        redirect_to @m_channel
      end
    elsif session[:s_channel_id].nil?
      redirect_to home_url
    else
      TGroupStarThread.find_by(groupthreadid: params[:id], userid: session[:user_id]).destroy

      @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
      redirect_to @t_group_message
    end
  end
end
