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

    @apps = []
    @windows = Hash.new {|hash, key| hash[key] = []}

    # 起動中のアプリケーションに切り替えの通知を登録
    workspace = NSWorkspace.sharedWorkspace
    workspace.runningApplications.each do |app|
      registNotification app.processIdentifier #if ['com.google.Chrome', 'com.apple.Terminal', 'com.apple.dt.Xcode'].include? app.bundleIdentifier
    end

    # 新たなアプリケーションが起動されたときにも切り替えの通知を登録
    workspace.notificationCenter.addObserver self,
    selector:NSSelectorFromString('applicationLaunched:'),
    name:NSWorkspaceDidLaunchApplicationNotification, object:workspace

    # ホットキーを登録
    @hotkey = Hotkey.new
    @hotkey.delegate = self
    @hotkey.addHotkey

    # システムメニューに表示
    bar = NSStatusBar.systemStatusBar
    item = bar.statusItemWithLength NSVariableStatusItemLength
    item.setTitle 'cycle'
    item.setHighlightMode true
    item.setMenu @systemMenu
  end

  # アプリケーションが起動したら
  def applicationLaunched notification
    pid = notification.userInfo['NSApplicationProcessIdentifier']

    applicationOrWindowSwitched(AXUIElementCreateApplication(pid),
    KAXApplicationActivatedNotification) if registNotification pid
  end

  # 切り替えられたら
  def applicationOrWindowSwitched element, notification
    window = case notification
             when KAXApplicationActivatedNotification
               res = Pointer.new(:id)
               AXUIElementCopyAttributeValue(element, 'AXMainWindow', res)
               res[0]
             when KAXMainWindowChangedNotification
               element
             end
    if window
      res = Pointer.new('i')
      AXUIElementGetPid(window, res)
      pid = res[0]

      if i = @apps.index(pid) then @apps.rotate! i else @apps.push pid end

      if i = @windows[pid].index(window)
        @windows[pid].rotate!(@windows[pid].index window)
      else
        @windows[pid].push window
      end
    end
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

        #@windows[pid].rotate!(@windows[pid].index window)

        while 1 < @windows[pid].count
          window = @windows[pid][1]
          break if 0 == AXUIElementPerformAction(window, 'AXRaise')
          @windows[pid].slice! 1
        end
      end
    end
  end

  # アプリケーションの切り替え
  def cycleApplication
    if startPid = @apps[1]
      pid = startPid
      begin
        if app = NSRunningApplication.runningApplicationWithProcessIdentifier(pid)
          break if app.activateWithOptions(NSApplicationActivateAllWindows|
                       NSApplicationActivateIgnoringOtherApps)
        end
        @apps.slice! 1
      end while pid = @apps[1] and startPid != pid
    end
  end

  def performCycleWindow sender
    cycleWindow
  end

  def performCycleApplication sender
    cycleApplication
  end

  # アプリケーションからの通知を受け取る
  def registNotification pid
    complete = false

    # メニューバーを持ちDockに表示されるアプリケーションのみ対象
    app = NSRunningApplication.
      runningApplicationWithProcessIdentifier pid
    if app and app.activationPolicy == NSApplicationActivationPolicyRegular
      elm = AXUIElementCreateApplication(pid)

      callback = Proc.new {|observer, element, notification, refcon|
        applicationOrWindowSwitched element, notification}
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

        complete = true
      end
    end

    complete
  end

  # ホットキーが押された
  def hotkeyWasPressed
    cycleWindow
  end

  #
  def hotkeyWasPressed2
    cycleApplication
  end
end

