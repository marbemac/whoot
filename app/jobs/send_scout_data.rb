class SendScoutData
  @queue = :scout

  def self.perform()
    if Rails.env.production? || Rails.env.staging?
      %x( /usr/bin/scout 1812af81-2919-4d92-a790-b582e07dd3a7 )
    end
  end
end