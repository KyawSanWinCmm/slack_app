class ChannelUserController < ApplicationController
  def show

    @w_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id").where("t_user_workspaces.workspaceid = ?", session[:workspace_id])
    
    @c_users = MUser.select("m_users.id, m_users.name, m_users.email, t_user_channels.created_admin").joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id").where("t_user_channels.channelid = ?", session[:s_channel_id]).order(created_admin: :desc)
    
    @temp_c_users_id = MUser.select("m_users.id").joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id").where("t_user_channels.channelid = ?", session[:s_channel_id]).order(created_admin: :desc)
    @c_users_id = Array.new
    @temp_c_users_id.each { |r| @c_users_id.push(r.id) }

    
    @s_channel = MChannel.find_by(id: session[:s_channel_id])

    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    
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
  end

  def create
    @t_user_channel = TUserChannel.new
    @t_user_channel.message_count = 0
    @t_user_channel.unread_channel_message = 0
    @t_user_channel.created_admin = 0
    @t_user_channel.userid = params[:userid]
    @t_user_channel.channelid = session[:s_channel_id]
    @t_user_channel.save
    redirect_to channeluser_path
  end

  def destroy
    TUserChannel.find_by(userid: params[:id], channelid: session[:s_channel_id]).destroy
    redirect_to channeluser_path
  end
end
