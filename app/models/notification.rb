class Notification
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :active, :default => true
  field :message
  field :type
  field :notify, :default => false
  field :read, :default => false
  field :emailed, :default => false
  field :pushed, :default => false
  field :user_id
  field :triggered_count, :default => 0
  field :triggered_by_emailed, :default => []
  field :triggered_by_pushed, :default => []
  embeds_many :triggered_by, as: :user_assignable, :class_name => 'UserSnippet'

  index(
    [
      [ :user_id, Mongo::ASCENDING ],
      [ :created_at, Mongo::DESCENDING ]
    ]
  )
  [[ :type, Mongo::ASCENDING ]]

  belongs_to :user

  def add_triggered_by(triggered_by_user)
    found = triggered_by.detect {|u| u.id == triggered_by_user.id}
    unless found
      self.triggered_by.create(
              :_id => triggered_by_user.id,
              :username => triggered_by_user.username,
              :first_name => triggered_by_user.first_name,
              :last_name => triggered_by_user.last_name,
              :public_id => triggered_by_user.public_id
      )
      self.triggered_count += 1
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

  def action_text(count)
    case type
      when 'follow'
        count > 1 ? 'are following you' : 'is following you'
      when 'comment'
        count > 1 ? 'commented on your post' : 'commented on your post'
      else
        "did something weird..."
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
    # create_new = bool wether to always create a new notification
    # triggered_by_user = the user object that triggered this notification, if there is one
    # date_range_aggregate = array[from, to]. If specified, will attempt to only create one notification of a given type between this range
    # message = optional message
    def add(target_user, type, notify, always_notify=false, create_new=false, triggered_by_user=nil, date_range_aggregate=nil, message=nil)
      notification = Notification.where(:user_id => target_user.id)
      if date_range_aggregate
        notification = notification.where(:created_at.gte => date_range_aggregate[0], :created_at.lte => date_range_aggregate[1])
      end
      notification = notification.where(:type => type).first

      new_notification = false
      unless notification
        new_notification = true
        notification = Notification.new(
                :user_id => target_user.id,
                :type => type,
                :message => message
        )
      end
      notification.notify = notify
      notification.active = true

      if always_notify
        notification.triggered_by_emailed.delete(triggered_by_user.id)
      end

      new_trigger = false
      trigger_notified = notification.triggered_by_emailed.include?(triggered_by_user.id) ? true : false
      if triggered_by_user
        new_trigger = notification.add_triggered_by(triggered_by_user)
      end

      if notification.notify && !trigger_notified
        notification.read = false
        notification.emailed = false
        notification.pushed = false
      end

      if notification.save && (new_trigger || new_notification || !trigger_notified)
        if new_notification
          target_user.unread_notification_count += 1
          target_user.save
        end
        if notification.notify
          Resque.enqueue_in(30.minutes, SendUserNotification, target_user.id.to_s)
        end
      end
    end

    def remove(target_user, type, triggered_by_user=nil, date_range_aggregate=nil, message=nil)
      notification = Notification.where(:user_id => target_user.id)
      if date_range_aggregate
        notification = notification.where(:created_at.gte => date_range_aggregate[0], :created_at.lte => date_range_aggregate[1])
      end
      if triggered_by_user
        notification = notification.where("triggered_by._id" => triggered_by_user._id)
      end
      notification = notification.where(:type => type).first

      if notification
        notification.triggered_by.where(:_id => triggered_by_user.id).delete_all
        if notification.triggered_by_emailed.length == 0
          target_user.unread_notification_count -= 1
          notification.destroy
        else
          notification.save
        end
      end
    end

  end

end