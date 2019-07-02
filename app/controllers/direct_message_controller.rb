class DirectMessageController < ApplicationController
  def show
    @t_direct_message = TDirectMessage.new
    @t_direct_message.directmsg = params[:session][:message]
    @t_direct_message.send_user_id = session[:user_id]
    @t_direct_message.receive_user_id = session[:s_user_id]
    @t_direct_message.read_status = 0
    @t_direct_message.save


    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_user = MUser.find_by(id: session[:s_user_id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
    INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);

    @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])

    @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)

      @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
      muser.email = ( @direct_count.size +  @thread_count.size).to_s
    end

    @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at  as created_at, (select count(*) from t_direct_threads where t_direct_threads.t_direct_message_id = t_direct_messages.id) as count").joins(
      "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").where(
        "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id]).order(id: :asc)

    
    @temp_direct_star_msgids = TDirectStarMsg.select("directmsgid").where("userid = ?", session[:user_id])

    @t_direct_star_msgids = Array.new
    @temp_direct_star_msgids.each { |r| @t_direct_star_msgids.push(r.directmsgid) }
    
  end

  def showthread
    @t_direct_thread = TDirectThread.new
    @t_direct_thread.directthreadmsg = params[:session][:message]
    @t_direct_thread.t_direct_message_id = session[:s_direct_message_id]
    @t_direct_thread.m_user_id = session[:user_id]
    @t_direct_thread.read_status = 0
    @t_direct_thread.save


    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_user = MUser.find_by(id: session[:s_user_id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
    INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);

    @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])

    @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)

      @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
      muser.email = ( @direct_count.size +  @thread_count.size).to_s
    end

    @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
    @send_user = MUser.find_by(id: @t_direct_message.send_user_id)


    @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at").joins(
            "INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
            INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id").where("t_direct_threads.t_direct_message_id = ?", session[:s_direct_message_id]).order(id: :asc)
    
    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", session[:user_id])

    @t_direct_star_thread_msgids = Array.new
    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
  end
end
