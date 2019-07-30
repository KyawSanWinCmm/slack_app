#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TGroupStarThreadController < ApplicationController
  def create
    #check unlogin user
    checkuser

    @t_group_star_thread = TGroupStarThread.new
    @t_group_star_thread.userid = session[:user_id]
    @t_group_star_thread.groupthreadid = params[:id]
    @t_group_star_thread.save
    
    @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
    redirect_to @t_group_message
  end

  def destroy
    #check unlogin user
    checkuser

    TGroupStarThread.find_by(groupthreadid: params[:id], userid: session[:user_id]).destroy

    @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
    redirect_to @t_group_message
  end
end
