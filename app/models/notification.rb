class Notification
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :active, :default => true
  field :message
  field :type
  field :read, :default => false
  field :notify, :default => false
  field :emailed, :default => false
  field :pushed, :default => false
  field :user_id
  field :triggered_by_emailed, :default => []
  field :triggered_by_pushed, :default => []
  embeds_many :triggered_by, as: :user_assignable, :class_name => 'UserSnippet'
  embeds_one :object, :as => :post_assignable, :class_name => 'PostSnippet'
  embeds_one :object_user, :as => :user_assignable, :class_name => 'UserSnippet'

  index(
    [
      [ :user_id, Mongo::ASCENDING ],
      [ :created_at, Mongo::DESCENDING ]
    ]
  )
  index(
    [
      [ :user_id, Mongo::ASCENDING ],
      [ :type, Mongo::ASCENDING ]
    ]
  )


  belongs_to :user

  def add_triggered_by(triggered_by_user)
    found = triggered_by.detect {|u| u.id == triggered_by_user.id}
    self.set_emailed.delete(triggered_by_user.id)
    unless found
      self.triggered_by.create(
              :_id => triggered_by_user.id,
              :username => triggered_by_user.username,
              :first_name => triggered_by_user.first_name,
              :last_name => triggered_by_user.last_name,
              :public_id => triggered_by_user.public_id
      )
      return true
    end
    false
  end

  def triggered_users_notify_count
    users_count = 0
    triggered_by.each {|triggered_user| users_count += 1 unless triggered_by_emailed.include?(triggered_user.id) }
    users_count
  end

  def triggered_users_notify_string
    string = ''
    users = Array.new
    triggered_by.each {|triggered_user| users << triggered_user unless triggered_by_emailed.include?(triggered_user.id) }
    users.each_with_index do |user, i|
      if i == users.length - 1 && users.length > 1
        string += ' and '
      end
      string += user.fullname
      if i < users.length - 1 && users.length > 2
        string += ', '
      end
    end
    string
  end

  def notification_text(count)
    case type.to_sym
      when :follow
        count > 1 ? 'are following you' : 'is following you'
      when :also # also signifies that someone has also responded to something your responded to
        "also commented on #{object_user.first_name}'s post".html_safe
      when :comment
        "commented on your post".html_safe
      else
        "did something weird... this is a mistake and the Limelight team has been notified to fix it!"
    end
  end

  def set_emailed
    self.emailed = true
    # Set each triggered to emailed
    self.triggered_by.each do |user|
      unless triggered_by_emailed.include? user.id
        self.triggered_by_emailed << user.id
      end
    end
  end

  class << self

    # Creates and optionally sends a notification for a user
    # target_user = the user object we are adding the notification for
    # type = the type of notification (string)
    # notify = bool wether to send the notification or not via email and/or push message
    # triggered_by_user = the user object that triggered this notification, if there is one
    # date_range_aggregate = array[from, to]. If specified, will attempt to only create one notification of a given type between this range
    # message = optional message
    # object = optional object this notification is attached to
    # object_user = optional user associated with the object the notification is about
    # comment = optional comment this notification is attached to
    def add(target_user, type, notify, triggered_by_user=nil, date_range_aggregate=nil, message=nil, mark_unread=nil, object=nil, object_user=nil, comment=nil)
      return if !target_user || (triggered_by_user && target_user.id == triggered_by_user.id)

      # Get a previous notification if there is one
      notification = Notification.where(:user_id => target_user.id)
      if date_range_aggregate
        notification = notification.where(:created_at.gte => date_range_aggregate[0], :created_at.lte => date_range_aggregate[1])
      end
      notification = notification.where(:type => type)
      if object
        notification = notification.where('object._id' => object.id)
      else
        # we don't aggregate around read notification unless there is an object attached
        # for example follow notifications create a new notification if the user has read their previous follow notification
        notification = notification.where(:read => false)
      end
      notification = notification.first

      new_notification = false
      unless notification
        new_notification = true
        notification = Notification.new(
                :user_id => target_user.id,
                :type => type,
                :message => message
        )
        if object
          notification.object = PostSnippet.new(
                  :night_type => object.night_type
          )
          notification.object.id = object.id
          notification.object.comment_id = comment.id if comment
        end
        if object_user
          notification.object_user = UserSnippet.new(
              :username => object_user.username,
              :first_name => object_user.first_name,
              :last_name => object_user.last_name,
              :public_id => object_user.public_id
          )
          notification.object_user.id = object_user.id
        end
      end
      notification.notify = notify

      #if always_notify
      #  notification.triggered_by_emailed.delete(triggered_by_user.id)
      #end

      new_trigger = false
      trigger_notified = notification.triggered_by_emailed.include?(triggered_by_user.id) ? true : false
      if triggered_by_user
        new_trigger = notification.add_triggered_by(triggered_by_user)
      end

      if mark_unread || (notification.notify && !trigger_notified)
        if notification.read == true
          new_notification = true
        end
        notification.read = false
        notification.emailed = false
        notification.pushed = false
      end

      Pusher["#{target_user.id.to_s}_private"].trigger('notification', {
              :id => target_user.id.to_s,
              :message => (message ? message : "#{triggered_by_user.username} #{notification.notification_text(1)}"),
              :url => ''
      })

      if notification.save && (!notification.read || new_trigger || !trigger_notified)
        if new_notification
          target_user.unread_notification_count += 1
          target_user.save
          #target_user.expire_caches
        end
        if notification.notify
          if target_user.device_token
            if Notification.send_push_notification(target_user.device_token, target_user.device_type, "#{triggered_by_user.fullname} #{notification.notification_text(1)}")
              notification.pushed = true
              notification.save
            end
          else
            Resque.enqueue_in(30.minutes, SendUserNotification, target_user.id.to_s)
          end
        end
      end
    end

    def remove(target_user, type, triggered_by_user=nil, date_range_aggregate=nil, object=nil, comment=nil)
      # find the notification
      notification = Notification.where(:user_id => target_user.id)
      if date_range_aggregate
        notification = notification.where(:created_at.gte => date_range_aggregate[0], :created_at.lte => date_range_aggregate[1])
      end
      if object
        notification = notification.where('object._id' => object.id)
        if comment
          notification = notification.where('object.comment_id' => comment.id)
        end
      end
      if triggered_by_user
        notification = notification.where("triggered_by._id" => triggered_by_user._id)
      end
      notification = notification.where(:type => type).first

      if notification
        notification.triggered_by.where(:_id => triggered_by_user.id).delete_all
        if notification.triggered_by.length == 0
          unless notification.read
            target_user.unread_notification_count -= 1
          end
          notification.destroy
        else
          notification.save
        end
      end
    end

    def send_push_notification(device_token, device_type, message)
      case device_type
        when 'Android'
          notification = {
            :schedule_for => [10.seconds.from_now],
            :apids => [device_token],
            :android => {:alert => message}
          }
        when 'IOS'
          notification = {
            :schedule_for => [10.seconds.from_now],
            :device_tokens => [device_token],
            :aps => {:alert => message, :badge => "+1"}
          }
      end

      Urbanairship.push(notification) if notification
    end

  end

end