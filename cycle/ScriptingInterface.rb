#
#  ScriptingInterface.rb
#  uielement
#
#  Created by Hiroyuki Takahashi on 11/10/03.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class Cycle < NSScriptCommand
    def performDefaultImplementation
      #ws = WindowServer.instance
      ws = AppDelegate.instance
      ws.cycleWindow
    end
end

class Test < NSScriptCommand
  def performDefaultImplementation
    args = evaluatedArguments
    #    args['']
    #args['ProseText']

    app = NSWorkspace.sharedWorkspace.runningApplications.find {|app| app.isActive}
    uiApp = AXUIElementCreateApplication(app.processIdentifier)
    
  end
end

