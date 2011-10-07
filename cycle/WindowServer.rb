# -*- coding: utf-8 -*-
#
#  WindowServer.rb
#  uielement
#
#  Created by Hiroyuki Takahashi on 11/10/04.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class WindowServer
  attr_accessor :systemMenu

  def serviceCycle pboard, userData:userData, error:error
    cycleWindow
  end

  def cycleWindow
    pid = NSWorkspace.sharedWorkspace.runningApplications.
      find {|app| app.isActive}.processIdentifier

    if 1 < @windows[pid].count
      app = AXUIElementCreateApplication(pid)

      res = Pointer.new(:id)
      if AXUIElementCopyAttributeValue(app, 'AXMainWindow', res)
        window = res[0]

        @windows[pid].rotate!(@windows[pid].index window)

        while 1 < @windows[pid].count
          window = @windows[pid][1]
          break if 0 == AXUIElementPerformAction(window, 'AXRaise')
          @windows[pid].slice! 1
        end
      end
    end
  end

  def registNotification pid
    elm = AXUIElementCreateApplication(pid)

    callback = Proc.new {|observer, element, notification, refcon|
      window = case notification
      when KAXApplicationActivatedNotification
                 res = Pointer.new(:id)
                 AXUIElementCopyAttributeValue(element, 'AXMainWindow', res)
                 res[0]
      when KAXMainWindowChangedNotification
                 element
      end

      res = Pointer.new('i')
      AXUIElementGetPid(window, res)
      pid = res[0]

      @windows[pid].push window if not @windows[pid].include? window
p @windows
    }

    res = Pointer.new('^{__AXObserver}')
    if AXObserverCreate(pid, callback, res) then
      observer = res[0]

      CFRunLoopAddSource(CFRunLoopGetCurrent(),
      AXObserverGetRunLoopSource(observer), KCFRunLoopDefaultMode)

      res = Pointer.new(:id)

      # アプリケーションがアクティブになったとき
      AXObserverAddNotification(observer, elm,
      KAXApplicationActivatedNotification, res)

      # メインウィンドウが変更されたとき
      AXObserverAddNotification(observer, elm,
      KAXMainWindowChangedNotification, res)

    end
  end

  def registMainWindow
    Proc.new {|observer, element, notification, me|
      puts 'hoge'
    }
  end

  def hotkeyWasPressed
    cycleWindow
  end

  def awakeFromNib
    puts 'Window Server'
  end

  def init
    super                       # スーパークラスのコンストラクタ

puts 'hugahoge'

    @windows = Hash.new {|hash, key| hash[key] = []}
    NSWorkspace.sharedWorkspace.runningApplications.each do |app|
      registNotification app.processIdentifier if ['com.google.Chrome', 'com.apple.Terminal', 'com.apple.dt.Xcode'].include? app.bundleIdentifier
    end

    # ホットキーを登録
    @hotkey = Hotkey.new
    @hotkey.delegate = self
    @hotkey.addHotkey

  end

  def self.instance
    self
  end


end
