class GroupMessageController < ApplicationController
    def show
    @t_group_message = TGroupMessage.new
    @t_group_message.groupmsg = params[:session][:message]
    @t_group_message.m_user_id = session[:user_id]
    @t_group_message.m_channel_id = session[:s_channel_id]
    @t_group_message.save

    @t_user_channels = TUserChannel.where(channelid: session[:s_channel_id])

    @t_user_channels.each do |u_channel|
      if u_channel.userid != session[:user_id]
        u_channel.message_count =  u_channel.message_count + 1
        temp_msgid = ""
        u_channel.unread_channel_message.split(",").each do |u_message|
          temp_msgid += u_message
          temp_msgid += ","
        end

        temp_msgid += @t_group_message.id.to_s

        u_channel.unread_channel_message = temp_msgid
        TUserChannel.where(id: u_channel.id).update_all(message_count: u_channel.message_count, unread_channel_message: u_channel.unread_channel_message )
      end
    end

   
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_channel = MChannel.find_by(id: session[:s_channel_id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
    INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);

    @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])

    @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)

      @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
      muser.email = ( @direct_count.size +  @thread_count.size).to_s
    end
    
    @t_group_messages = TGroupMessage.select("name, groupmsg, t_group_messages.id as id, t_group_messages.created_at as created_at, (select count(*) from t_group_threads where t_group_threads.t_group_message_id = t_group_messages.id) as count ").joins(
      "INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id").order(id: :asc)

      @temp_group_star_msgids = TGroupStarMsg.select("groupmsgid").where("userid = ?", session[:user_id])

      @t_group_star_msgids = Array.new
      @temp_group_star_msgids.each { |r| @t_group_star_msgids.push(r.groupmsgid) }
    end

    def showthread
      @t_group_thread = TGroupThread.new
      @t_group_thread.groupthreadmsg = params[:session][:message]
      @t_group_thread.t_group_message_id = session[:s_group_message_id]
      @t_group_thread.m_user_id = session[:user_id]
      @t_group_thread.save

      @t_user_channels = TUserChannel.where(channelid: session[:s_channel_id])

    @t_user_channels.each do |u_channel|
      if u_channel.userid != session[:user_id]
        u_channel.message_count =  u_channel.message_count + 1

        arr_msgid = u_channel.unread_channel_message.split(",")

        if !arr_msgid.include? session[:s_group_message_id].to_s
          temp_msgid = ""
          u_channel.unread_channel_message.split(",").each do |u_message|
            temp_msgid += u_message
            temp_msgid += ","
          end

          temp_msgid += session[:s_group_message_id].to_s 
          u_channel.unread_channel_message = temp_msgid
        end
        TUserChannel.where(id: u_channel.id).update_all(message_count: u_channel.message_count, unread_channel_message: u_channel.unread_channel_message )
      end
    end
  
  
      @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
      @m_user = MUser.find_by(id: session[:user_id])
      @s_channel = MChannel.find_by(id: session[:s_channel_id])
      @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
      INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);

      @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])

      @m_users.each do |muser|
        @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)

        @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
        muser.email = ( @direct_count.size +  @thread_count.size).to_s
      end
      
      @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
      @send_user = MUser.find_by(id: @t_group_message.m_user_id)
  
  
      @t_group_threads = TGroupThread.select("name, groupthreadmsg, t_group_threads.id as id, t_group_threads.created_at  as created_at").joins(
          "INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
          INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id").where("t_group_threads.t_group_message_id = ?", session[:s_group_message_id]).order(id: :asc)
      
      @temp_group_star_thread_msgids = TGroupStarThread.select("groupthreadid").where("userid = ?", session[:user_id])
  
      @t_group_star_thread_msgids = Array.new
      @temp_group_star_thread_msgids.each { |r| @t_group_star_thread_msgids.push(r.groupthreadid) }      
    end
end
