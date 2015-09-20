# Methods For meal status
module Statusable
  extend ActiveSupport::Concern

  def close!
    raise "invalid status for closing" if status != "open"
    update_attribute(:status, "closed")
  end

  def reopen!
    raise "invalid status for reopening" if status != "closed"
    update_attribute(:status, "open")
  end

  def closed?
    status == "closed"
  end

  def open?
    status == "open"
  end

  def closeable?
    open?
  end

  def reopenable?
    closed? && Time.now < served_at
  end

  def new_signups_allowed?
    !closed? && !full?
  end

  def signups_editable?
    !closed?
  end
end