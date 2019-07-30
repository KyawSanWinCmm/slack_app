#Slack System
#Direct Message Controller 
#Authorname-MyoMinNaing@CyberMissions Myanmar Company limited 
#@Since 27/06/2019
#Version 1.0.0

class MemberInvitationController < ApplicationController
  def new
    #check unlogin user
    checkuser

    session.delete(:s_user_id)
    session.delete(:s_channel_id)
    session.delete(:s_direct_message_id)
    session.delete(:s_group_message_id)
    session.delete(:r_direct_size)
    session.delete(:r_group_size)

    #call from ApplicationController for retrieve home data
    retrievehome
  end

  def invite
    #check unlogin user
    checkuser

    puts params[:session][:email].nil?
    puts params[:session][:channelid][1].nil?
    puts session[:workspace_id]
    @user = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id").where("t_user_workspaces.workspaceid = ? and m_users.email = ?", session[:workspace_id], params[:session][:email])
    
    if @user.size > 0
      flash[:danger] = "Email is already member."
      redirect_to memberinvite_url
    else
      if params[:session][:channelid][1].nil? || params[:session][:channelid][1] == ""
        flash[:danger] = "Please Select Channel."
        redirect_to memberinvite_url
      elsif params[:session][:email].nil? || params[:session][:email] == ""
        flash[:danger] = "Please Enter Eamil."
        redirect_to memberinvite_url
      else
        @i_user = MUser.new
        @i_user.email = params[:session][:email]
        @i_channel = MChannel.find_by(id: params[:session][:channelid][1])
        @i_workspace = MWorkspace.find_by(id: session[:workspace_id])

        UserMailer.member_invite(@i_user, @i_workspace, @i_channel).deliver_now
        flash[:info] = "Invitation is success."
        redirect_to home_url
      end
    end
  end
end
