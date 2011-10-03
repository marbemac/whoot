class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.role? 'admin'
      can :manage, :all
    else
      can :read, :all
      can :create, :all if user.persisted?

      [NormalPost, InvitePost, Comment, Ping, Follow].each do |resource|
        [:update, :destroy].each do |permission|
          can permission.to_sym, resource do |target|
            target.try(:permission?, user.id, permission)
          end
        end
      end
    end
  end
end