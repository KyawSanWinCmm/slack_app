class StarChannelListsController < ApplicationController
    def showgpstar

        @gpstar=TGroupStarMsg.find_by_sql("select t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_users.name from t_group_messages,t_group_star_msgs,
                                            m_users where t_group_star_msgs.groupmsgid=t_group_messages.id and t_group_star_msgs.userid=1 and t_group_messages.m_user_id=m_users.id
                                            and t_group_messages.m_channel_id=1")

        #@gpstar=TGroupStarMsg.select("t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_users.name")
         #                           .joins("INNER JOIN t_group_messages ON t_group_messages.id=t_group_star_msgs.groupmsgid
          #                                  INNER JOIN m_users ON m_users.id=t_group_star_msgs.userid")
           #                         .where("t_group_star_msgs.groupmsgid=t_group_messages.id 
            #                                and t_group_messages.m_user_id=m_users.id and t_group_star_msgs.userid=?,t_group_messages.m_channel_id=?",session[:user_id],session[:m_channel_id])
        
        @gpthreadstar=TGroupStarThread.find_by_sql("select t_group_threads.id,t_group_threads.groupthreadmsg,t_group_threads.created_at,m_users.name from t_group_threads,t_group_star_threads,
		                                            m_users,t_group_messages where t_group_star_threads.groupthreadid=t_group_threads.id and t_group_star_threads.userid=1 and 
                                                  t_group_messages.m_user_id=m_users.id and t_group_messages.id=t_group_threads.t_group_message_id and 
                                                   t_group_messages.m_channel_id=1")

        #@gpthreadstar=TGroupStarThread.select("t_group_threads.id,t_group_threads.groupthreadmsg,t_group_threads.created_at,m_users.name")  
         #                                       .joins("INNER JOIN t_group_threads ON t_group_threads.id=t_group_star_threads.groupthreadid
          #                                              INNER JOIN t_group_messages ON t_group_messages.id=t_group_star_threads.groupthreadid
           #                                             INNER JOIN m_users ON m_users.id=t_group_star_threads.userid")
            #                                    .where("t_group_star_threads.groupthreadid=t_group_threads.id and 
             #                                          t_group_messages.m_user_id=m_users.id and t_group_messages.id=t_group_threads.t_group_message_id and 
              #                                          t_group_star_threads.userid=?,t_group_messages.m_channel_id=?",session[:user_id],session[:m_channel_id])                 

        @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
        @m_user = MUser.find_by(id: session[:user_id])
        @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id  
                                INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid AND  m_workspaces.id = 1") 
                                                                    
        @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])
        @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at as created_at").joins(
                                                    "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").order(id: :asc)

        @m_users.each do |muser|
            @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
                                                    
            @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
            muser.email = ( @direct_count.size +  @thread_count.size).to_s
        end
    end
end
