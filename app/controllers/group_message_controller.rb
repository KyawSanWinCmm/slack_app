class GroupMessageController < ApplicationController
    def show
      @t_group_message = TGroupMessage.new
      @t_group_message.groupmsg = params[:session][:message]
      @t_group_message.m_user_id = session[:user_id]
      @t_group_message.m_channel_id = session[:s_channel_id]
      @t_group_message.save

      @t_user_channels = TUserChannel.where(channelid: session[:s_channel_id])

      @t_user_channels.each do |u_channel|
        if u_channel.userid != session[:user_id]
          u_channel.message_count =  u_channel.message_count + 1
          temp_msgid = ""
          u_channel.unread_channel_message.split(",").each do |u_message|
            temp_msgid += u_message
            temp_msgid += ","
          end
  
          temp_msgid += @t_group_message.id.to_s
  
          u_channel.unread_channel_message = temp_msgid
          TUserChannel.where(id: u_channel.id).update_all(message_count: u_channel.message_count, unread_channel_message: u_channel.unread_channel_message )
        end
      end
    
      @m_channel = MChannel.find_by(id: session[:s_channel_id])
      redirect_to @m_channel
    end

    def showthread
      @t_group_thread = TGroupThread.new
      @t_group_thread.groupthreadmsg = params[:session][:message]
      @t_group_thread.t_group_message_id = session[:s_group_message_id]
      @t_group_thread.m_user_id = session[:user_id]
      @t_group_thread.save

      @t_user_channels = TUserChannel.where(channelid: session[:s_channel_id])

    @t_user_channels.each do |u_channel|
      if u_channel.userid != session[:user_id]
        u_channel.message_count =  u_channel.message_count + 1

        arr_msgid = u_channel.unread_channel_message.split(",")

        if !arr_msgid.include? session[:s_group_message_id].to_s
          temp_msgid = ""
          u_channel.unread_channel_message.split(",").each do |u_message|
            temp_msgid += u_message
            temp_msgid += ","
          end

          temp_msgid += session[:s_group_message_id].to_s 
          u_channel.unread_channel_message = temp_msgid
        end
        TUserChannel.where(id: u_channel.id).update_all(message_count: u_channel.message_count, unread_channel_message: u_channel.unread_channel_message )
      end
    end

      @t_group_message = TGroupMessage.find_by(id: session[:s_group_message_id])
      redirect_to @t_group_message   
    end
end
