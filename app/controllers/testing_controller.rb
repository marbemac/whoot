class TestingController < ApplicationController

  def test
    users = User.where(:status => 'Active')
    users.each do |user|
      unless user.schools && user.schools.length > 0
        fb = user.facebook
        if fb
          me = fb.get_object("me")
          if me
            me['education'].each do |e|
              data = {:type => e['type']}
              if e['school']
                data[:fb_id] = e['school']['id']
                data[:name] = e['school']['name']
              end
              if e['year']
                data[:year] = e['year']['name']
              end

              user.schools.new(data)
            end
            user.save
          end
        end
      end
    end
  end

end