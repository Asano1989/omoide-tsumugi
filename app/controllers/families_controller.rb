class FamiliesController < ApplicationController
  before_action :authenticate_user!

  def guide; end
end
