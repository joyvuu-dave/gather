module Concerns::ApplicationController::Setters
  extend ActiveSupport::Concern

  protected

  def set_validation_error_notice
    flash.now[:error] = "Please correct the errors below."
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
