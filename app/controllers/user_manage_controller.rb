class UserManageController < ApplicationController
    def usermanage
        @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
        @m_user = MUser.find_by(id: session[:user_id])
        @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id  
                                INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid AND  m_workspaces.id = 1") 
                                
        @m_channels = MChannel.distinct.select("m_channels.id,channel_name,channel_status,t_user_channels.message_count").joins(
            "INNER JOIN t_user_channels ON t_user_channels.channelid = m_channels.id"
            ).where("(m_channels.m_workspace_id = ? and t_user_channels.userid = ? and m_channels.channel_status = 0) or ( m_channels.m_workspace_id = ? and m_channels.channel_status = 1)", session[:workspace_id], session[:user_id], session[:workspace_id])
                
        @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at as created_at").joins(
                                                    "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").order(id: :asc)

        @m_users.each do |muser|
            @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
                                                                                                
            @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
            muser.email = ( @direct_count.size +  @thread_count.size).to_s
        end
    end

    def edit
    end
    
end
