class TGroupStarMsgController < ApplicationController
  def create
    @t_group_star_msg = TGroupStarMsg.new
    @t_group_star_msg.userid = session[:user_id]
    @t_group_star_msg.groupmsgid = params[:id]
    @t_group_star_msg.save

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

  def destroy
    TGroupStarMsg.find_by(groupmsgid: params[:id], userid: session[:user_id]).destroy

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
end
