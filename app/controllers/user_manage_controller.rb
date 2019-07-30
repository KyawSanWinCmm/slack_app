#Slack System
#Direct Message Controller 
#Authorname-NyiNyiMinThant@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class UserManageController < ApplicationController
  def usermanage
    #check unlogin user
    checkuser

    session.delete(:s_user_id)
    session.delete(:s_channel_id)
    session.delete(:s_direct_message_id)
    session.delete(:s_group_message_id)
    session.delete(:r_direct_size)
    session.delete(:r_group_size)

    @user_manages_activate = MUser.select("m_users.id,name,email,member_status").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and admin <> 1 and member_status = 1 and t_user_workspaces.workspaceid = ?",session[:workspace_id])

    @user_manages_deactivate = MUser.select("m_users.id,name,email,member_status").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and admin <> 1 and member_status = 0 and t_user_workspaces.workspaceid = ?",session[:workspace_id])

    @user_manages_admin = MUser.select("name,email").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and m_users.admin = 1 and t_user_workspaces.workspaceid = ?",session[:workspace_id])

    #call from ApplicationController for retrieve home data
    retrievehome
  end

  def edit
    MUser.where(id: params[:id]).update_all(member_status: 0)
    redirect_to action:"usermanage"
  end

  def update
    MUser.where(id: params[:id]).update_all(member_status: 1)
    redirect_to action:"usermanage"
  end
end
