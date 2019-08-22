#Slack System
#Direct Message Controller 
#@Since 27/06/2019
#Version 1.0.0

class SessionsController < ApplicationController
  #Authorname-SuMyatPhyoe@CyberMissions Myanmar Company limited 
  def new
    #check login user
    checkloginuser
  end

  #Authorname-SuMyatPhyoe@CyberMissions Myanmar Company limited 
  def create
    #check login user
    checkloginuser

    m_user = MUser.find_by(name: params[:session][:name])
    m_workspace = MWorkspace.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.workspaceid = m_workspaces.id
                                    INNER JOIN m_users ON m_users.id = t_user_workspaces.userid")
                            .where("m_workspaces.workspace_name = ? and m_users.name = ? ", params[:session][:workspace_name],  params[:session][:name]).take(1)

    if m_user && m_user.authenticate(params[:session][:password]) && m_workspace.size > 0
      t_user_workspace = TUserWorkspace.find_by(userid: m_user.id, workspaceid: m_workspace[0].id)
        if t_user_workspace
          if m_user.member_status == true
            log_in t_user_workspace
            redirect_to home_path
          else
            flash.now[:danger] = 'Account Deactivate. Please contact admin.'
            render 'new'
          end
        else
          flash.now[:danger] = 'Invalid name/password combination'
          render 'new'
        end
    else
      flash.now[:danger] = 'Invalid name/password combination'
      render 'new'
    end
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def destroy
    MUser.where(id: session[:user_id]).update_all(active_status: 0)

    session.delete(:workspace_id)
    session.delete(:user_id)
    session.delete(:s_channel_id)
    session.delete(:s_user_id)
    session.delete(:s_direct_message_id)
    session.delete(:s_group_message_id)
    session.delete(:r_direct_size)
    session.delete(:r_group_size)
    
    flash.clear
    log_out if logged_in?
    redirect_to root_url
  end

#Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def refresh
    unless session[:user_id].nil?
      @user = MUser.find_by(id: session[:user_id])

      MUser.where(id: session[:user_id]).update_all(active_status: 1)

      if @user.remember_digest == "1"
        if session[:s_direct_message_id] != nil && session[:s_direct_message_id] != ""
          #call from ApplicationController for retrieve direct thread data
          retrieve_direct_thread

        elsif session[:s_user_id] != nil && session[:s_user_id] != ""    
          #call from ApplicationController for retrieve direct message data
          retrieve_direct_message

        elsif session[:s_group_message_id] != nil && session[:s_group_message_id] != ""
          #call from ApplicationController for retrieve group thread data
          retrieve_group_thread

        elsif session[:s_channel_id] != nil && session[:s_channel_id] != ""
          #call from ApplicationController for retrieve group message data
          retrieve_group_message

        end
        
        #call from ApplicationController for retrieve home data
        retrievehome

        MUser.where(id: session[:user_id]).update_all(remember_digest: "0")
      end
    end
  end
end
