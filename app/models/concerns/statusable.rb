# Methods For meal status
module Statusable
  extend ActiveSupport::Concern

  AUTO_CLOSE_LEAD_TIME = 1.day

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

  def finalized?
    status == "finalized"
  end

  def open?
    status == "open"
  end

  def closeable?
    open?
  end

  def reopenable?
    closed? && !past_day?
  end

  def finalizable?
    closed? && past_day?
  end

  def new_signups_allowed?
    !closed? && !full? && !past_time?
  end

  def signups_editable?
    !closed? && !past_time?
  end

  def past_time?
    Time.current > served_at
  end

  def past_day?
    Time.current.midnight > served_at
  end

  def past_auto_close_time?
    Time.current > served_at - AUTO_CLOSE_LEAD_TIME
  end

  def close_if_past_auto_close_time!
    close! if open? && past_auto_close_time?
  end
end
