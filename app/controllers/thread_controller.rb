class ThreadController < ApplicationController
    def show

        @s_channel = MChannel.find_by(id: session[:s_channel_id])
        #@dirthrd=TDirectThread.find_by_sql("select distinct t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name from t_direct_messages,
         #                                   t_direct_threads,m_users where t_direct_messages.id=t_direct_threads.t_direct_message_id and t_direct_threads.id=1 and 
          #                                  t_direct_messages.send_user_id=m_users.id")
        @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at  as created_at, (select count(*) from t_direct_threads where t_direct_threads.t_direct_message_id = t_direct_messages.id) as count").joins(
                                                "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").where(
                                                    "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )",
                                                     session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id]).order(id: :asc)

        @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at").joins(
                                    "INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
                                     INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id").where("t_direct_threads.t_direct_message_id = ?", session[:s_direct_message_id]).order(id: :asc) 
        
        @t_group_messages = TGroupMessage.select("name, groupmsg, t_group_messages.id as id, t_group_messages.created_at as created_at,channel_name").joins(
                                        "INNER JOIN m_channels ON m_channels.id=t_group_messages.m_channel_id
                                        INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id").order(id: :asc)
        
        @t_group_threads = TGroupThread.select("name, groupthreadmsg, t_group_threads.id as id, t_group_threads.created_at  as created_at").joins(
                                            "INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
                                            INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id").where("t_group_threads.t_group_message_id = ?", session[:s_group_message_id]).order(id: :asc)

        #@dirthrd=TDirectThread.select("distinct t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name")
         #                               .joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
          #                                      INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id")
           #                             .where("t_direct_messages.id=t_direct_threads.t_direct_message_id and 
            #                                    t_direct_messages.send_user_id=m_users.id and t_direct_threads.id=?",session[:user_id])

        #@gpthrd=TGroupThread.find_by_sql("select distinct t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_channels.channel_name,m_users.name from	
         #                               t_group_messages,t_group_threads,m_channels,m_users where t_group_messages.id=t_group_threads.t_group_message_id
          #                              and t_group_threads.id=1 and t_group_messages.m_channel_id=m_channels.id and t_group_threads.id=1 and
           #                             t_group_threads.m_user_id=m_users.id")      
            
        #@gpthrd=TGroupThread.select("distinct t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_channels.channel_name,m_users.name")
         #                           .joins("INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
          #                                  INNER JOIN m_channels ON m_channels.id=t_group_messages.m_channel_id
           #                                 INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id")
            #                         .where("t_group_messages.id=t_group_threads.t_group_message_id
             #                               and t_group_messages.m_channel_id=m_channels.id and
              #                              t_group_threads.m_user_id=m_users.id and t_group_threads.id=?,",session[:user_id])

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
        
        @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", session[:user_id])

        @t_direct_star_thread_msgids = Array.new
        @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }

        @temp_group_star_thread_msgids = TGroupStarThread.select("groupthreadid").where("userid = ?", session[:user_id])
  
        @t_group_star_thread_msgids = Array.new
        @temp_group_star_thread_msgids.each { |r| @t_group_star_thread_msgids.push(r.groupthreadid) }

    end
end
