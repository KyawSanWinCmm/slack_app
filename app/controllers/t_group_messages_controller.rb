class TGroupMessagesController < ApplicationController
  def show
    session[:s_group_message_id] =  params[:id]
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_channel = MChannel.find_by(id: session[:s_channel_id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
    INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);

    @m_channels = MChannel.distinct.select("m_channels.id,channel_name,channel_status,t_user_channels.message_count").joins(
      "INNER JOIN t_user_channels ON t_user_channels.channelid = m_channels.id"
    ).where("m_channels.m_workspace_id = ? and t_user_channels.userid = ?", session[:workspace_id], session[:user_id])

    @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
  
      @thread_count = TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id").where(
          "t_direct_threads.read_status = 0 and t_direct_threads.m_user_id = ? and ((t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?) || (t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?))", muser.id, muser.id, session[:user_id], session[:user_id], muser.id
      )
      muser.email = ( @direct_count.size +  @thread_count.size).to_s
      end
    
    @t_group_message = TGroupMessage.find_by(id: params[:id])
    @send_user = MUser.find_by(id: @t_group_message.m_user_id)


    @t_group_threads = TGroupThread.select("name, groupthreadmsg, t_group_threads.id as id, t_group_threads.created_at  as created_at").joins(
        "INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
        INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id").where("t_group_threads.t_group_message_id = ?", params[:id]).order(id: :asc)
    
    @temp_group_star_thread_msgids = TGroupStarThread.select("groupthreadid").where("userid = ?", session[:user_id])

    @t_group_star_thread_msgids = Array.new
    @temp_group_star_thread_msgids.each { |r| @t_group_star_thread_msgids.push(r.groupthreadid) }
    
    @u_count = TUserChannel.where(channelid: session[:s_channel_id]).count
  end
end
