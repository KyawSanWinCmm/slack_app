class MUsersController < ApplicationController
  def new
    @m_user = MUser.new
  end

  def create
    @m_user = MUser.new(user_params)
    
    @m_workspace = MWorkspace.new
    @m_workspace.workspace_name = @m_user.remember_digest

    @m_channel = MChannel.new
    @m_channel.channel_name = @m_user.profile_image
    @m_channel.channel_status = 1

    @m_user.active_status = 1
    @m_user.admin = 1
    @m_user.member_status = 1

    status = true

    if status &&  @m_user.save
      MUser.where(id: @m_user.id).update_all(remember_digest: nil, profile_image: nil)
    else status = false
    end

    @t_workspace = MWorkspace.find_by(workspace_name: @m_workspace.workspace_name)
    if(@t_workspace.nil?)
      if status && @m_workspace.save
      else status = false
      end
    else
      @m_workspace = @t_workspace
    end

    @t_user_workspace = TUserWorkspace.new
    @t_user_workspace.userid = @m_user.id
    @t_user_workspace.workspaceid = @m_workspace.id

    if status && @t_user_workspace.save
    else status = false
    end

    @m_channel.m_workspace_id = @m_workspace.id

    @t_channel = MChannel.find_by(channel_name: @m_channel.channel_name)
    if(@t_channel.nil?)
      if status && @m_channel.save
      else status = false
      end
    else
      @m_channel = @t_channel
    end

    @t_user_channel = TUserChannel.new
    @t_user_channel.message_count = 0
    @t_user_channel.unread_channel_message = 0
    @t_user_channel.created_admin = 1
    @t_user_channel.userid = @m_user.id
    @t_user_channel.channelid = @m_channel.id

    if status && @t_user_channel.save
    else status = false
    end

    if(status)
      flash[:success] = "Workspace Createion Complete."
      redirect_to root_url
    else
      render 'm_workspaces/new'
    end
  end

  def show
    session.delete(:s_user_id)
    session[:s_user_id] =  params[:id]
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    @s_user = MUser.find_by(id: params[:id])
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
    INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid").where("m_workspaces.id = ?", session[:workspace_id]);
    
    TDirectMessage.where(send_user_id: params[:id], receive_user_id: session[:user_id], read_status: 0).update_all(read_status: 1)
    TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id").where(
      "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", session[:user_id],  params[:id],  params[:id], session[:user_id]
    ).where.not(m_user_id: session[:user_id], read_status: 1).update_all(read_status: 1)

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
        "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", session[:user_id],  params[:id],  params[:id], session[:user_id]).order(id: :asc)

    @temp_direct_star_msgids = TDirectStarMsg.select("directmsgid").where("userid = ?", session[:user_id])

    @t_direct_star_msgids = Array.new
    @temp_direct_star_msgids.each { |r| @t_direct_star_msgids.push(r.directmsgid) }
    end

    

  def confirm
    puts params[:email]
    puts params[:workspaceid]
    puts params[:channelid]
    @m_workspace = MWorkspace.find_by(id: params[:workspaceid])
    @m_channel = MChannel.find_by(id: params[:channelid])

    @m_user = MUser.new
    @m_user.email = params[:email]
    @m_user.remember_digest = @m_workspace.workspace_name
    @m_user.profile_image = @m_channel.channel_name
  end

  def user_params
    params.require(:m_user).permit(:name, :email, :password,
    :password_confirmation, :profile_image, :remember_digest)
  end

end