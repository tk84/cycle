# -*- coding: utf-8 -*-
framework 'Foundation'

class Timer
  attr_accessor :repeat
  attr_accessor :callback

  private_class_method :new

  def initialize msec=1000, repeat=false, &p
    self.msec = msec
    self.repeat = repeat
    self.callback = p
  end

  def msec
    @oMsec
  end

  def msec=(value)
    @oMsec = value
    @msec = value / 1000.0
  end

  def start
    @first = true
    @tm.invalidate if @tm
    @tm = NSTimer.scheduledTimerWithTimeInterval @msec, target:self,
    selector:NSSelectorFromString('fire'), userInfo:nil, repeats:@repeat
  end

  def stop
    @tm.invalidate
  end

  def fire
    @callback.call(self)
  end
  private :fire

  def self.setTimeout msec, &p
    tm = new msec, &p
    tm.start
    tm
  end

  def self.setInterval msec, &p
    tm = new msec, true, &p
    tm.start
    tm
  end
end
