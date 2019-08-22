#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class DirectMessageController < ApplicationController
  def show
    #check unlogin user
    checkuser

    if session[:s_user_id].nil?
      redirect_to home_url
    else
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
  end

  def showthread
    #check unlogin user
    checkuser

    if session[:s_direct_message_id].nil?
      unless session[:s_user_id].nil?
        @user = MUser.find_by(id: session[:s_user_id])
        redirect_to @user
      end
    elsif session[:s_user_id].nil?
      redirect_to home_url
    else
      @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
      if @t_direct_message.nil?
        unless session[:s_user_id].nil?
          @user = MUser.find_by(id: session[:s_user_id])
          redirect_to @user
        else
          redirect_to home_url
        end
      else
        @t_direct_thread = TDirectThread.new
        @t_direct_thread.directthreadmsg = params[:session][:message]
        @t_direct_thread.t_direct_message_id = session[:s_direct_message_id]
        @t_direct_thread.m_user_id = session[:user_id]
        @t_direct_thread.read_status = 0
        @t_direct_thread.save
        MUser.where(id: session[:s_user_id]).update_all(remember_digest: "1")

        redirect_to @t_direct_message
      end
    end
  end

  def deletemsg
    #check unlogin user
    checkuser

    if session[:s_user_id].nil?
      redirect_to home_url
    else
      directthread=TDirectThread.select("id").where(t_direct_message_id: params[:id])

      directthread.each do|directthread|
          TDirectStarThread.where(directthreadid: directthread.id).destroy_all
          TDirectThread.find_by(id: directthread.id).destroy
      end

      TDirectStarMsg.where(directmsgid: params[:id]).destroy_all

      TDirectMessage.find_by(id: params[:id]).destroy

      @user = MUser.find_by(id: session[:s_user_id])
      redirect_to @user
    end
  end

  def deletethread
    #check unlogin user
    checkuser

    if session[:s_direct_message_id].nil?
      unless session[:s_user_id].nil?
        @user = MUser.find_by(id: session[:s_user_id])
        redirect_to @user
      end
    elsif session[:s_user_id].nil?
      redirect_to home_url
    else
      TDirectStarThread.where(directthreadid: params[:id]).destroy_all
      TDirectThread.find_by(id: params[:id]).destroy

      @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
      redirect_to @t_direct_message
    end
  end

end
