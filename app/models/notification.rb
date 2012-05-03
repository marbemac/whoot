class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include ModelUtilitiesHelper

  field :active, :default => true
  field :message
  field :type
  field :update_count, :default => 1 # how many times has this notification been used (comment comment comment) from the same user on the same object would create 1 notification that is updated
  field :notify, :default => false
  field :read, :default => false
  field :emailed, :default => false
  field :pushed, :default => false
  field :user_id

  embeds_one :triggered_by, as: :user_assignable, :class_name => 'UserSnippet'
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

  def notification_text
    case type.to_sym
      when :follow
        'is following you'
      when :comment
        "commented on #{object_user.first_name}'s post"
      when :also # also signifies that someone has also responded to something your responded to
        "also commented on #{object_user.first_name}'s post"
      else
        "did something weird... this is a mistake and The Whoot team has been notified to fix it!"
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

  def as_json(options={})
    {
            :id => id.to_s,
            :read => read,
            :user_id => user_id.to_s,
            :message => message,
            :type => type,
            :sentence => notification_text,
            :created_at => created_at,
            :created_at_pretty => pretty_time(created_at),
            :created_at_day => pretty_day(created_at),
            :triggered_by => triggered_by.as_json,
            :object => object.as_json,
            :object_user => object_user.as_json
    }
  end

  class << self

    # Creates and optionally sends a notification for a user
    # target_user = the user object we are adding the notification for
    # type = the type of notification (string)
    # notify = bool wether to send the notification or not via email and/or push message
    # triggered_by_user = the user object that triggered this notification, if there is one
    # message = optional message
    # object = optional object this notification is attached to
    # object_user = optional user associated with the object the notification is about
    # comment = optional comment this notification is attached to
    def add(target_user, type, notify, triggered_by_user=nil, message=nil, object=nil, object_user=nil, comment=nil)
      return if !target_user || (triggered_by_user && target_user.id == triggered_by_user.id)

      # Get a previous notification if there is one
      notification = Notification.where(:user_id => target_user.id, :type => type)
      if triggered_by_user
        notification = notification.where('triggered_by._id' => triggered_by_user.id)
      end
      if object
        notification = notification.where('object._id' => object.id)
      end
      notification = notification.first

      new_notification = false
      if notification
        new_notification = true if notification.read == true
        notification.created_at = Time.now
        notification.update_count += 1
        notification.read = false
        notification.emailed = false
        notification.pushed = false
      else
        new_notification = true
        notification = Notification.new(
                :user_id => target_user.id,
                :type => type,
                :message => message
        )

        if triggered_by_user
          notification.triggered_by = UserSnippet.new(
              :username => triggered_by_user.username,
              :first_name => triggered_by_user.first_name,
              :last_name => triggered_by_user.last_name,
              :public_id => triggered_by_user.public_id,
              :fbuid => triggered_by_user.fbuid
          )
          notification.triggered_by.id = triggered_by_user.id
        end

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
              :public_id => object_user.public_id,
              :fbuid => object_user.fbuid
          )
          notification.object_user.id = object_user.id
        end

        notification.notify = notify
      end

      if notification.save
        if new_notification
          target_user.unread_notification_count += 1

          if notification.notify
            # TODO: Only send one every 5 minutes
            if target_user.device_token  # pushing notification
              if Notification.send_push_notification(target_user.device_token, target_user.device_type, "#{triggered_by_user.fullname} #{notification.notification_text(1)}")
                target_user.last_notified = Time.now
                notification.pushed = true
                notification.save
              end
            else # emailing notification
              Resque.enqueue_in(30.minutes, SendUserNotification, target_user.id.to_s)
            end
          end

          target_user.save
        end

        notification
      end
    end

    def remove(target_user, type, triggered_by_user=nil, object=nil, comment=nil)
      # find the notification
      notification = Notification.where(:user_id => target_user.id)
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
        unless notification.read
          target_user.unread_notification_count = target_user.unread_notification_count.to_i - 1
        end
        notification.destroy
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
            :aps => {:alert => message}
          }
      end

      Urbanairship.push(notification) if notification
    end

  end

end