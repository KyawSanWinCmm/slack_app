module SessionsHelper
    # Logs in the given user.
    def log_in(t_user_workspace)
        session[:user_id] = t_user_workspace.userid
        session[:workspace_id] = t_user_workspace.workspaceid
        session[:s_user_id] = 1
    end

    # Returns true if the given user is the current user.
    def current_user?(m_user)
        m_user == current_user
    end

        # Returns the current logged-in user (if any).
    def current_user
        user_id = session[:user_id]
        @current_user ||= MUser.find_by(id: session[:user_id])
        print(@current_user)
        print("Current User")
    end

    # Returns true if the user is logged in, false otherwise.
    def logged_in?
    !current_user.nil?
    end

    # Logs out the current user.
    def log_out
        session.delete(:user_id)
        session.delete(:s_user_id)
        session.delete(:workspace_id)
        session.delete(:s_channel_id)
    end
end
