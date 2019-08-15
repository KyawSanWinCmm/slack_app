#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TDirectStarThreadController < ApplicationController
  def create
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
      @t_direct_star_thread = TDirectStarThread.new
      @t_direct_star_thread.userid = session[:user_id]
      @t_direct_star_thread.directthreadid = params[:id]
      @t_direct_star_thread.save

      @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
      redirect_to @t_direct_message
    end
  end

  def destroy
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
      TDirectStarThread.find_by(directthreadid: params[:id], userid: session[:user_id]).destroy
      
      @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
      redirect_to @t_direct_message
    end
  end
end
