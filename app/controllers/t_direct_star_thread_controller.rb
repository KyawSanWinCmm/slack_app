class TDirectStarThreadController < ApplicationController
  def create
    @t_direct_star_thread = TDirectStarThread.new
    @t_direct_star_thread.userid = session[:user_id]
    @t_direct_star_thread.directthreadid = params[:id]
    @t_direct_star_thread.save

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

    TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1).update_all(read_status: 1)

    @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at").joins(
        "INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
        INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id").where("t_direct_threads.t_direct_message_id = ?", session[:s_direct_message_id]).order(id: :asc)
    
    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", session[:user_id])

    @t_direct_star_thread_msgids = Array.new
    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
  end

  def destroy

    TDirectStarThread.find_by(directthreadid: params[:id], userid: session[:user_id]).destroy

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

    TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1).update_all(read_status: 1)

    @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at").joins(
        "INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
        INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id").where("t_direct_threads.t_direct_message_id = ?", session[:s_direct_message_id]).order(id: :asc)
    
    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", session[:user_id])

    @t_direct_star_thread_msgids = Array.new
    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
  end
end
