class StarDirectListsController < ApplicationController
    def showdirstar

        #@dirstar=TDirectStarMsg.find_by_sql("select t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name from t_direct_messages,t_direct_star_msgs,
		                                   # m_users where t_direct_star_msgs.directmsgid=t_direct_messages.id and t_direct_star_msgs.userid=1 and t_direct_messages.send_user_id=m_users.id")                                   

        @dirstar=TDirectStarMsg.select("t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name")
                                        .joins("INNER JOIN t_direct_messages ON t_direct_messages.id=t_direct_star_msgs.directmsgid
                                                INNER JOIN m_users ON m_users.id=t_direct_star_msgs.userid")
                                        .where("t_direct_star_msgs.directmsgid=t_direct_messages.id and t_direct_messages.send_user_id=m_users.id and t_direct_star_msgs.userid=?",session[:user_id])

        #@dirthreadstar=TDirectStarThread.find_by_sql("select t_direct_threads.id,t_direct_threads.directthreadmsg,t_direct_threads.created_at,m_users.name from t_direct_threads,t_direct_star_threads,
                                                    #m_users where t_direct_star_threads.directthreadid=t_direct_threads.id and t_direct_star_threads.userid=1 and t_direct_threads.m_user_id=m_users.id")
    
        @dirthreadstar=TDirectStarThread.select("t_direct_threads.id,t_direct_threads.directthreadmsg,t_direct_threads.created_at,m_users.name")
                                                .joins("INNER JOIN t_direct_threads ON t_direct_threads.id=t_direct_star_threads.directthreadid
                                                        INNER JOIN m_users ON m_users.id=t_direct_star_threads.userid")
                                                .where("t_direct_star_threads.directthreadid=t_direct_threads.id and t_direct_threads.m_user_id=m_users.id and t_direct_star_threads.userid=?",session[:user_id])

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
