class MobileController < ApplicationController
  before_filter :set_mobile

  def login

  end

  private

  def set_mobile
    request.format = :mobile
  end

end