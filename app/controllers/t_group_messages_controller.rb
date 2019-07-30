#Slack System
#Direct Message Controller 
#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class TGroupMessagesController < ApplicationController
  def show
    #check unlogin user
    checkuser

    session[:s_group_message_id] =  params[:id]

    #call from ApplicationController for retrieve group thread data
    retrieve_group_thread

    #call from ApplicationController for retrieve home data
    retrievehome
  end
end
