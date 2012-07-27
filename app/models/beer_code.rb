class BeerCode
  include Mongoid::Document

  field :code
  field :used, :default => false

  validates_uniqueness_of :code

  def self.grab_code
    beer_code = self.where(:used => false).first
    beer_code.used = true
    beer_code.save
    beer_code.code
  end

  def self.generate
    600.times do |i|
      code = (0...5).map{65.+(rand(25)).chr}.join.to_s
      while self.where(:code => code).first
        code = (0...5).map{65.+(rand(25)).chr}.join.to_s
      end
      BeerCode.create(:code => code)
    end
  end
end