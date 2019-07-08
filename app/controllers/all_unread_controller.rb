class AllUnreadController < ApplicationController
    def show
        @dirunmsg=TDirectMessage.select("t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name")
                                         .joins("INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id")
                                         .where("t_direct_messages.send_user_id=m_users.id and t_direct_messages.read_status=0 and
                                                 t_direct_messages.receive_user_id=?",session[:user_id]) 
                                                 
        #@dirunmsg=TDirectMessage.select("t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name from m_users,t_direct_messages where
         #                                        t_direct_messages.send_user_id=m_users.id and t_direct_messages.read_status=0 and
          #                                                                                t_direct_messages.receive_user_id=1")

        @dirunthread=TDirectThread.select("distinct t_direct_threads.t_direct_message_id,
                                            t_direct_threads.directthreadmsg,t_direct_threads.created_at,m_users.name")
                                            .joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
                                            INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id")
                                            .where("t_direct_messages.id=t_direct_threads.t_direct_message_id
                                            and t_direct_threads.read_status=0 and t_direct_threads.m_user_id=m_users.id 
                                            and t_direct_messages.read_status=1 and t_direct_threads.m_user_id <> ?",session[:user_id])

        #@dirunthread=TDirectThread.select("select distinct t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at as dmct,t_direct_message_id,t_direct_threads.created_at as dmtct,
         #                                   t_direct_threads.directthreadmsg,m_users.name
          #                                  from t_direct_messages,t_direct_threads,m_users where
           #                                 t_direct_messages.id=t_direct_threads.t_direct_message_id
            #                                and t_direct_threads.read_status=0 and t_direct_threads.m_user_id=m_users.id
             #                               and t_direct_messages.read_status=1 and t_direct_threads.m_user_id <> 1")
        
        @gpunmsg=TGroupMessage.select("t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_users.name,m_channels.channel_name")
                                       .joins("INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id
                                               INNER JOIN t_user_channels ON t_user_channels.channelid=t_group_messages.channelid
                                               INNER JOIN m_channels ON t_group_messages.m_channel_id=m_channels.id")
                                        .where("t_user_channels.userid=m_users.id and t_user_channels.message_count>0 and 
                                                t_group_messages.m_channel_id=m_channels.id and t_group_messages.channelid=t_user_channels.channelid and
                                                m_users.id=?",session[:user_id])

        #@gpunmsg=TGroupMessage.find_by_sql("select t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_users.name from m_users,
		                                   # t_user_channels.userid=m_users.id and t_user_channels.message_count>0 and 
                                           #t_group_messages.channelid=t_user_channels.channelid and t_group_messages.id=t_user_channels.id and m_users.id=1") 


                                           
        #@gpunthread=TGroupThread.select("distinct t_group_threads.t_group_message_id,t_group_threads.groupthreadmsg,t_group_threads.created_at,m_users.name")
         #                               .joins("INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
          #                                      INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id")
           #                             .where("t_group_theads.m_user_id=m_users.id and t_group_threads.t_group_message_id=t_group_messages.id and
            #                                    t_group_threads.read_status = 0 and
             #                                   t_group_messages.read_status = 1 and t_group_threads.m_user_id <> ?",session[:user_id])

        #@gpunthread=TGroupThread.find_by_sql("select distinct t_group_threads.t_group_message_id,t_group_threads.groupthreadmsg,t_group_threads.created_at,m_users.name
         #                                       from t_group_threads,t_group_messages,m_users where t_group_theads.m_user_id=m_users.id and
          #                                      t_group_threads.t_group_message_id=t_group_messages.id and  t_group_threads.read_status = 0 and
           #                                     t_group_messages.read_status = 1 and t_group_threads.m_user_id <> 1")
                                        
        @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
        @m_user = MUser.find_by(id: session[:user_id])
        @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id  
                                INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid AND  m_workspaces.id = 1") 
                                                                    
        @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])
        @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at as created_at").joins(
                                                   "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").order(id: :asc) 
                                                   
        #@m_users.each do | muser | 
         #   @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id],read_status: 0)

          #  @direct_thread_count = TDirectThread.where.not(m_user_id: session[:user_id],read_status: 1)

          #  @group_count = TGroupMessage.where.not(m_user_id: session[:user_id],read_status: 1)

          #  @group_thread_count = TGroupThread.where.not(m_user_id: session[:user_id],read_status: 1)

           # muser.email = ( @direct_count.size + @direct_thread_count.size + @group_count.size + @group_thread_count.size).to_s
        #end

        @m_users.each do |muser|
            @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
            
            @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
            muser.email = ( @direct_count.size +  @thread_count.size).to_s
        end
    end
end
