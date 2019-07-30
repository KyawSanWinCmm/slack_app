#Slack System
#change Password Controller 
#Authorname-PyaePhyoeAung@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class ChangePasswordController < ApplicationController
  def new
    #check unlogin user
    checkuser
    
    session.delete(:s_user_id)
    session.delete(:s_channel_id)
    session.delete(:s_direct_message_id)
    session.delete(:s_group_message_id)
    session.delete(:r_direct_size)
    session.delete(:r_group_size)

    #call from ApplicationController for retrieve home data
    retrievehome
  end
end
