class SessionsController < ApplicationController
  def new
  end

  def create
    m_workspace = MWorkspace.find_by(workspace_name: params[:session][:workspace_name])
    m_user = MUser.find_by(name: params[:session][:name])
    t_user_workspace = TUserWorkspace.find_by(userid: m_user.id, workspaceid: m_workspace.id)

    if m_user && m_user.authenticate(params[:session][:password])
        log_in t_user_workspace
        redirect_to home_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    session.delete(:workspace_id)
    log_out if logged_in?
    redirect_to root_url
  end
end
