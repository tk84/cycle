# -*- coding: utf-8 -*-
#
#  AppDelegate.rb
#  uielement
#
#  Created by Hiroyuki Takahashi on 11/10/03.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

require File.dirname(__FILE__) + '/hotkey.bundle'

class AppDelegate
  attr_accessor :systemMenu

  # アプリケーションの終了
  def terminate sender
    NSApp.terminate self
  end

  def self.instance
    self
  end

  # 初期化
  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application

    # ウィンドウの管理
    # @windows = Hash.new {|hash, key| hash[key] = []}
    # NSWorkspace.sharedWorkspace.runningApplications.each do |app|
    #   registNotification app.processIdentifier if ['com.google.Chrome', 'com.apple.Terminal', 'com.apple.dt.Xcode'].include? app.bundleIdentifier
    # end

    # ホットキーを登録
    @hotkey = Hotkey.new
    @hotkey.delegate = self
    @hotkey.addHotkey


    # システムメニューに登録
    bar = NSStatusBar.systemStatusBar
    item = bar.statusItemWithLength NSVariableStatusItemLength
    item.setTitle 'cycle'
    item.setHighlightMode true
    item.setMenu @systemMenu
  end

  # ウィンドウの切り替え
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

  # アプリケーションからの通知を受け取る
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

  # ホットキーが押された
  def hotkeyWasPressed
    cycleWindow
  end
end

