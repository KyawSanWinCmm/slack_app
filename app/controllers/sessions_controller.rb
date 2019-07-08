class SessionsController < ApplicationController
  def new
  end

  def create
    m_workspace = MWorkspace.find_by(workspace_name: params[:session][:workspace_name])
    m_user = MUser.find_by(name: params[:session][:name])

    if m_user && m_user.authenticate(params[:session][:password]) && m_workspace
      t_user_workspace = TUserWorkspace.find_by(userid: m_user.id, workspaceid: m_workspace.id)
        if t_user_workspace
          log_in t_user_workspace
          redirect_to home_path
        else
          flash.now[:danger] = 'Invalid email/password combination'
          render 'new'
        end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  
  def destroy
    session.delete(:workspace_id)
    session.delete(:s_channel_id)
    session.delete(:s_user_id)
    flash.clear
    log_out if logged_in?
    redirect_to root_url
  end

  

  def refresh
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_user = MUser.find_by(id: session[:s_user_id])
    
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
                            INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);
                 
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

    @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at  as created_at, (select count(*) from t_direct_threads where t_direct_threads.t_direct_message_id = t_direct_messages.id) as count").joins(
      "INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id").where(
        "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id]).order(id: :asc)

    @temp_direct_star_msgids = TDirectStarMsg.select("directmsgid").where("userid = ?", session[:user_id])
    puts @t_direct_messages.size
    puts 'hello'
    @t_direct_star_msgids = Array.new
    @temp_direct_star_msgids.each { |r| @t_direct_star_msgids.push(r.directmsgid) }


    @s_channel = MChannel.find_by(id: session[:s_channel_id])
    @t_group_messages = TGroupMessage.select("name, groupmsg, t_group_messages.id as id, t_group_messages.created_at as created_at, (select count(*) from t_group_threads where t_group_threads.t_group_message_id = t_group_messages.id) as count ").joins(
      "INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id").where("m_channel_id = ? ", session[:s_channel_id]).order(id: :asc)
    
    @temp_group_star_msgids = TGroupStarMsg.select("groupmsgid").where("userid = ?", session[:user_id])

    @t_group_star_msgids = Array.new
    @temp_group_star_msgids.each { |r| @t_group_star_msgids.push(r.groupmsgid) }

    @u_count = TUserChannel.where(channelid: session[:s_channel_id]).count

    respond_to do |format|
      format.js
    end
  end
end
