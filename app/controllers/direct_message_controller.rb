class DirectMessageController < ApplicationController
  def show
    @t_direct_message = TDirectMessage.new
    @t_direct_message.directmsg = params[:session][:message]
    @t_direct_message.send_user_id = session[:user_id]
    @t_direct_message.receive_user_id = session[:s_user_id]
    @t_direct_message.read_status = 0
    @t_direct_message.save

    @user = MUser.find_by(id: session[:s_user_id])
    redirect_to @user
    
  end

  def showthread
    @t_direct_thread = TDirectThread.new
    @t_direct_thread.directthreadmsg = params[:session][:message]
    @t_direct_thread.t_direct_message_id = session[:s_direct_message_id]
    @t_direct_thread.m_user_id = session[:user_id]
    @t_direct_thread.read_status = 0
    @t_direct_thread.save

    @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
    redirect_to @t_direct_message
  end
end
