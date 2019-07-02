class StaticPagesController < ApplicationController
  def welcome
  end

  def home
    workspace_id = session[:workspace_id]
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
                            INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);
                 
    @m_channels = MChannel.where(m_workspace_id: session[:workspace_id])

      @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
      
      @thread_count = TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1)
      muser.email = ( @direct_count.size +  @thread_count.size).to_s
      
    end
  end
end
