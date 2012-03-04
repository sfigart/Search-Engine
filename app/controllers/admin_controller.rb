class AdminController < ApplicationController
  def index
    term = "zynga"
    @terms = [ {term => Rails.cache.read(term)} ]
  end
end

