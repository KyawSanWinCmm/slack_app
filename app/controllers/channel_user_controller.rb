#Slack System
#Channel User Controller 
#Authorname-MyoMinNaing@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class ChannelUserController < ApplicationController
  def show
    #check unlogin user
    checkuser
    if session[:s_channel_id].nil?
      redirect_to home_url
    else
      @w_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id")
                      .where("t_user_workspaces.workspaceid = ?", session[:workspace_id])
    
      @c_users = MUser.select("m_users.id, m_users.name, m_users.email, t_user_channels.created_admin")
                      .joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id")
                      .where("t_user_channels.channelid = ?", session[:s_channel_id]).order(created_admin: :desc)
      
      @temp_c_users_id = MUser.select("m_users.id").joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id")
                              .where("t_user_channels.channelid = ?", session[:s_channel_id]).order(created_admin: :desc)
      @c_users_id = Array.new
      @temp_c_users_id.each { |r| @c_users_id.push(r.id) }

      @s_channel = MChannel.find_by(id: session[:s_channel_id])

      #call from ApplicationController for retrieve home data
      retrievehome
    end
  end

  def create
    #check unlogin user
    checkuser
    if session[:s_channel_id].nil?
      redirect_to home_url
    else
      @t_user_channel = TUserChannel.new
      @t_user_channel.message_count = 0
      @t_user_channel.unread_channel_message = 0
      @t_user_channel.created_admin = 0
      @t_user_channel.userid = params[:userid]
      @t_user_channel.channelid = session[:s_channel_id]
      @t_user_channel.save
      redirect_to channeluser_path
    end
  end

  def join
    #check unlogin user
    checkuser

    if session[:s_channel_id].nil?
      redirect_to home_url
    else
      @t_user_channel = TUserChannel.new
      @t_user_channel.message_count = 0
      @t_user_channel.unread_channel_message = 0
      @t_user_channel.created_admin = 0
      @t_user_channel.userid = params[:userid]
      @t_user_channel.channelid = session[:s_channel_id]
      @t_user_channel.save
      
      @m_channel = MChannel.find_by(id: session[:s_channel_id])
      redirect_to @m_channel
    end
  end

  def destroy
    #check unlogin user
    checkuser
    if session[:s_channel_id].nil?
      redirect_to home_url
    else
      TUserChannel.find_by(userid: params[:id], channelid: session[:s_channel_id]).destroy
      redirect_to channeluser_path
    end
  end
end
