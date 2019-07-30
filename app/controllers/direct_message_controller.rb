#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class DirectMessageController < ApplicationController
  def show
    #check unlogin user
    checkuser

    @t_direct_message = TDirectMessage.new
    @t_direct_message.directmsg = params[:session][:message]
    @t_direct_message.send_user_id = session[:user_id]
    @t_direct_message.receive_user_id = session[:s_user_id]
    @t_direct_message.read_status = 0
    @t_direct_message.save

    session.delete(:r_direct_size)

    MUser.where(id: session[:s_user_id]).update_all(remember_digest: "1")
    
    @user = MUser.find_by(id: session[:s_user_id])
    redirect_to @user
  end

  def showthread
    #check unlogin user
    checkuser

    @t_direct_thread = TDirectThread.new
    @t_direct_thread.directthreadmsg = params[:session][:message]
    @t_direct_thread.t_direct_message_id = session[:s_direct_message_id]
    @t_direct_thread.m_user_id = session[:user_id]
    @t_direct_thread.read_status = 0
    @t_direct_thread.save
    MUser.where(id: session[:s_user_id]).update_all(remember_digest: "1")

    @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
    redirect_to @t_direct_message
  end
end
