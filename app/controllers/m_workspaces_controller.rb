#Slack System
#Direct Message Controller 
#Authorname-AyeMyatHnin@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class MWorkspacesController < ApplicationController
    def new
        #check login user
        checkloginuser
        
        @m_user = MUser.new
    end
end
