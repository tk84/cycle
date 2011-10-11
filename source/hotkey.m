// hotkey.m
// 
// compile:
// gcc hotkey.m -o hotkey.bundle -g -framework Foundation -framework Carbon -dynamiclib -fobjc-gc -arch i386 -arch x86_64

//#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface Hotkey : NSObject
{
    id delegate;
}
@property (assign) id delegate;
- (void) addHotkey;
- (void) hotkeyWasPressed;
- (void) hotkeyWasPressed2;
@end
OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);


@implementation Hotkey
@synthesize delegate;

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
    // NSLog(@"YEAY WE DID A GLOBAL HOTKEY 1");

    EventHotKeyID hotKeyID;
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL,
		      sizeof(hotKeyID), NULL, &hotKeyID);

    if (hotKeyID.signature == 'tk84') {
      if ( userData != NULL ) {
        id delegate = (id)userData;
	if ( delegate ) {
	  switch (hotKeyID.id) {
	  case 1:
	    if ([delegate respondsToSelector:@selector(hotkeyWasPressed)]) {
	      [delegate hotkeyWasPressed];
	    }
	    break;
	  case 2:
	    if ([delegate respondsToSelector:@selector(hotkeyWasPressed2)]) {
	      [delegate hotkeyWasPressed2];
	    }
	    break;
	  }  
	}
      }      
    }

    return noErr;
}

- (void) addHotkey
{
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    if ( delegate == nil )
      delegate = self;

    EventTargetRef eventTarget = (EventTargetRef) GetEventMonitorTarget();
    InstallEventHandler(eventTarget, &myHotKeyHandler, 1, &eventType, (void *)delegate, NULL);

    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    myHotKeyID.signature='tk84';
    myHotKeyID.id=1;
    RegisterEventHotKey(50, cmdKey, myHotKeyID, eventTarget, 0, &myHotKeyRef);

    EventHotKeyRef myHotKeyRef2;
    EventHotKeyID myHotKeyID2;
    myHotKeyID2.signature='tk84';
    myHotKeyID2.id=2;
    // RegisterEventHotKey(50, cmdKey+shiftKey, myHotKeyID2, eventTarget, 0, &myHotKeyRef2);  
    RegisterEventHotKey(48, controlKey, myHotKeyID2, eventTarget, 0, &myHotKeyRef2);  
}

- (void) hotkeyWasPressed {};
- (void) hotkeyWasPressed2 {};

@end

void Init_hotkey(void) {}
