#Slack System
#Application Controller 
#@Since 27/06/2019
#Version 1.0.0

class ApplicationController < ActionController::Base
protect_from_forgery with: :exception
  include SessionsHelper

  
  #Authorname-SuMyatPhyoe@CyberMissions Myanmar Company limited 
  def retrievehome
    @m_workspace = MWorkspace.find_by(id: session[:workspace_id])
    @m_user = MUser.find_by(id: session[:user_id])
    
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
                            INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid")
      .where("m_users.member_status = 1 and m_workspaces.id = ?", session[:workspace_id])

    @m_channels = MChannel.select("m_channels.id,channel_name,channel_status,t_user_channels.message_count").joins(
      "INNER JOIN t_user_channels ON t_user_channels.channelid = m_channels.id"
    ).where("(m_channels.m_workspace_id = ? and t_user_channels.userid = ?)",session[:workspace_id], session[:user_id])

    @m_p_channels = MChannel.select("m_channels.id,channel_name,channel_status")
      .where("(m_channels.channel_status = 1 and m_channels.m_workspace_id = ?)",session[:workspace_id])
           
    @direct_msgcounts = Array.new

    @m_users.each do |muser|
      @direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: session[:user_id], read_status: 0)
  
      @thread_count = TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id")
                                    .where("t_direct_threads.read_status = 0 and t_direct_threads.m_user_id = ? and 
                                    ((t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?) || 
                                    (t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?))", 
                                    muser.id, muser.id, session[:user_id], session[:user_id], muser.id)
      @direct_msgcounts.push( @direct_count.size +  @thread_count.size)
    end

    @all_unread_count = 0
    @m_channels.each do |c|
      @all_unread_count += c.message_count
    end

    @direct_msgcounts.each do |c|
      @all_unread_count +=c
    end

    @m_channelsids = Array.new
    @m_channels.each do|m_channel|
      @m_channelsids.push(m_channel.id)
    end
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def retrieve_direct_message
    TDirectMessage.where(send_user_id: session[:s_user_id], receive_user_id: session[:user_id], read_status: 0).update_all(read_status: 1)
    TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id").where(
      "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id]
    ).where.not(m_user_id: session[:user_id], read_status: 1).update_all(read_status: 1)

    @s_user = MUser.find_by(id: session[:s_user_id])

    @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at  as created_at, 
                                          (select count(*) from t_direct_threads where t_direct_threads.t_direct_message_id = t_direct_messages.id) as count")
                                        .joins("INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id")
                                        .where("(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) 
                                          || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", 
                                          session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id]).order(created_at: :desc).limit(session[:r_direct_size])

    @t_direct_messages = @t_direct_messages.reverse
    @temp_direct_star_msgids = TDirectStarMsg.select("directmsgid").where("userid = ?", session[:user_id])

    @t_direct_star_msgids = Array.new
    @temp_direct_star_msgids.each { |r| @t_direct_star_msgids.push(r.directmsgid) }

    @t_direct_message_dates = TDirectMessage.select("distinct DATE(created_at) as created_date")
                                            .where("(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) 
                                            || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", 
                                            session[:user_id],  session[:s_user_id],  session[:s_user_id], session[:user_id])
    
    @t_direct_message_datesize = Array.new
    @t_direct_messages.each{|d| @t_direct_message_datesize.push(d.created_at.strftime("%F").to_s)}
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def retrieve_direct_thread
    @s_user = MUser.find_by(id: session[:s_user_id])
        
    @t_direct_message = TDirectMessage.find_by(id: session[:s_direct_message_id])
    @send_user = MUser.find_by(id: @t_direct_message.send_user_id)

    TDirectThread.where.not(m_user_id: session[:user_id], read_status: 1).update_all(read_status: 1)

    @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at")
                .joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
                        INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id")
                .where("t_direct_threads.t_direct_message_id = ?", session[:s_direct_message_id]).order(id: :asc)
    
    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", session[:user_id])

    @t_direct_star_thread_msgids = Array.new
    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def retrieve_group_message
    @s_channel = MChannel.find_by(id: session[:s_channel_id])

    @m_channel_users = MUser.joins("INNER JOIN t_user_channels on t_user_channels.userid = m_users.id 
                                    INNER JOIN m_channels ON m_channels.id = t_user_channels.channelid")
                                .where("m_users.member_status = 1 and m_channels.m_workspace_id = ? and m_channels.id = ?",
                                session[:workspace_id], session[:s_channel_id])

    TUserChannel.where(channelid: session[:s_channel_id], userid: session[:user_id]).update_all(message_count: 0, unread_channel_message: nil)

    @t_group_messages = TGroupMessage.select("name, groupmsg, t_group_messages.id as id, t_group_messages.created_at as created_at, 
                                            (select count(*) from t_group_threads where t_group_threads.t_group_message_id = t_group_messages.id) as count ")
                                      .joins("INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id")
                                      .where("m_channel_id = ? ", session[:s_channel_id]).order(created_at: :desc).limit(session[:r_group_size])
    
    @t_group_messages = @t_group_messages.reverse
    @temp_group_star_msgids = TGroupStarMsg.select("groupmsgid").where("userid = ?", session[:user_id])

    @t_group_star_msgids = Array.new
    @temp_group_star_msgids.each { |r| @t_group_star_msgids.push(r.groupmsgid) }
    @u_count = TUserChannel.where(channelid: session[:s_channel_id]).count
    @t_group_message_dates = TGroupMessage.select("distinct DATE(created_at) as created_date").where("m_channel_id = ? ", session[:s_channel_id])
    
    @t_group_message_datesize = Array.new
    @t_group_messages.each{|d| @t_group_message_datesize.push(d.created_at.strftime("%F").to_s)}
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def retrieve_group_thread
    @s_channel = MChannel.find_by(id: session[:s_channel_id])

    @m_channel_users = MUser.joins("INNER JOIN t_user_channels on t_user_channels.userid = m_users.id 
                                    INNER JOIN m_channels ON m_channels.id = t_user_channels.channelid")
                                .where("m_users.member_status = 1 and m_channels.m_workspace_id = ? and m_channels.id = ?",
                                session[:workspace_id], session[:s_channel_id])
                                
    TUserChannel.where(channelid: session[:s_channel_id], userid: session[:user_id]).update_all(message_count: 0, unread_channel_message: nil)
    
    @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
    @send_user = MUser.find_by(id: @t_group_message.m_user_id)

    @t_group_threads = TGroupThread.select("name, groupthreadmsg, t_group_threads.id as id, t_group_threads.created_at  as created_at")
                    .joins("INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
                          INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id").where("t_group_threads.t_group_message_id = ?", session[:s_group_message_id]).order(id: :asc)
    
    @temp_group_star_thread_msgids = TGroupStarThread.select("groupthreadid").where("userid = ?", session[:user_id])

    @t_group_star_thread_msgids = Array.new
    @temp_group_star_thread_msgids.each { |r| @t_group_star_thread_msgids.push(r.groupthreadid) }
    
    @u_count = TUserChannel.where(channelid: session[:s_channel_id]).count
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def checkuser
    if session[:workspace_id].nil?
      redirect_to root_url
    else
      m_user = MUser.find_by(id: session[:user_id], member_status: 1)
      if m_user.nil?
        session.delete(:workspace_id)
        session.delete(:s_channel_id)
        session.delete(:s_user_id)
        session.delete(:s_direct_message_id)
        session.delete(:s_group_message_id)
        
        flash.clear
        log_out if logged_in?
        redirect_to root_url
      end
    end
  end

  #Authorname-KyawSanWin@CyberMissions Myanmar Company limited 
  def checkloginuser
    unless session[:workspace_id].nil?
      redirect_to home_url
    end
  end
end
