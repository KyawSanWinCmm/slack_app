#Slack System
#Direct Message Controller 
#@Since 27/06/2019
#Version 1.0.0

class MUsersController < ApplicationController
  
  #Authorname-AyeMyatHnin@CyberMissions Myanmar Company limited 
  def new
    #check login user
    checkloginuser

    @m_user = MUser.new
  end

  #Authorname-AyeMyatHnin, MyoMinNaing@CyberMissions Myanmar Company limited 
  def create
    #check login user
    checkloginuser

    @m_user = MUser.new(user_params)

    @m_workspace = MWorkspace.new
    @m_workspace.workspace_name = @m_user.remember_digest

    @m_channel = MChannel.new
    @m_channel.channel_name = @m_user.profile_image
    @m_channel.channel_status = 1

    @m_user.member_status = 1

    status = true

    @t_workspace = MWorkspace.find_by(id: session[:invite_workspaceid])

    if status &&  @m_user.save
      MUser.where(id: @m_user.id).update_all(remember_digest: nil, profile_image: nil)
    else 
      status = false
    end

    if(@t_workspace.nil?)
      if status && @m_workspace.save
      
      else 
        status = false
      end
    else
      @m_workspace = @t_workspace
    end

    @t_user_workspace = TUserWorkspace.new
    @t_user_workspace.userid = @m_user.id
    @t_user_workspace.workspaceid = @m_workspace.id

    if status && @t_user_workspace.save

    else 
      status = false
    end

    @t_user_channel = TUserChannel.new
    
    @t_channel = MChannel.find_by(channel_name: @m_channel.channel_name, m_workspace_id: @m_workspace.id)
    
    if(@t_channel.nil?)
      @t_user_channel.created_admin = 1
      @m_channel.m_workspace_id = @m_workspace.id

      if status && @m_channel.save
      else 
        status = false
      end
    else
      @t_user_channel.created_admin = 0
      @m_channel = @t_channel
    end

    @t_user_channel.message_count = 0
    @t_user_channel.unread_channel_message = 0
    @t_user_channel.userid = @m_user.id
    @t_user_channel.channelid = @m_channel.id

    if status && @t_user_channel.save
    else 
      status = false
    end

    if(status)
      flash[:success] = "Signup Complete."
      redirect_to root_url
    else
      render 'm_workspaces/new'
    end
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def show
    #check unlogin user
    checkuser

    session.delete(:s_channel_id)
    session.delete(:s_group_message_id)
    session.delete(:s_direct_message_id)
    session.delete(:r_group_size)
    
    session[:s_user_id] =  params[:id]

    session[:r_direct_size] =  10

    #call from ApplicationController for retrieve direct message data
    retrieve_direct_message

    #call from ApplicationController for retrieve home data
    retrievehome
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def refresh_direct
    #check unlogin user
    checkuser

    if session[:r_direct_size].nil?
      session[:r_direct_size] =  10
    else
      session[:r_direct_size] +=  10
    end

    #call from ApplicationController for retrieve direct message data
    retrieve_direct_message

    #call from ApplicationController for retrieve home data
    retrievehome
  end

  #Authorname-PyaePhyoeAung@CyberMissions Myanmar Company limited 
  def update
    #check unlogin user
    checkuser

    @m_user = MUser.new(user_params)
    password = params[:m_user][:password]
    password_confirmation = params[:m_user][:password_confirmation]

    if password == "" || password.nil?
      flash[:danger] = "Password can't be blank."
      redirect_to change_password_url(id: session[:user_id])
    elsif password_confirmation == "" || password_confirmation.nil?
      flash[:danger] = "Confirm Password can't be blank."
      redirect_to change_password_url(id: session[:user_id])
    elsif password != password_confirmation
      flash[:danger] = "Password and Confirmation Password does not match."
      redirect_to change_password_url(id: session[:user_id])
    else 
      MUser.where(id: session[:user_id]).update_all(password_digest: @m_user.password_digest)
      flash[:success] = "Change Password Successful."
      redirect_to home_url
    end
  end

  #Authorname-MyoMinNaing@CyberMissions Myanmar Company limited 
  def confirm
    #check login user
    checkloginuser
    
    @m_workspace = MWorkspace.find_by(id: params[:workspaceid])
    @m_channel = MChannel.find_by(id: params[:channelid])
    session[:invite_workspaceid] = params[:workspaceid]

    @m_user = MUser.new
    @m_user.email = params[:email]
    @m_user.remember_digest = @m_workspace.workspace_name
    @m_user.profile_image = @m_channel.channel_name
  end

  #Authorname-AyeMyatHnin@CyberMissions Myanmar Company limited 
  def user_params
    params.require(:m_user).permit(:name, :email, :password,
    :password_confirmation, :profile_image, :remember_digest, :admin)
  end
end