//
//  HotKey.m
//  cycle
//
//  Created by Hiroyuki Takahashi on 11/10/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HotKey.h"

@implementation HotKey
@synthesize keyPressedMap;

- (id)init {
  self = [super init]; // スーパークラスの呼びだし
  if(self != nil) {
    keyPressedMap = [NSMutableDictionary dictionary];
  }
  return self;
}

- (BOOL) addHotKey:(int)code modifier:(int)key onKeyPressed:(id)method
{
  BOOL res = FALSE;
  static EventTargetRef eventTarget;

  if ( NULL == eventTarget ) {
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    eventTarget = (EventTargetRef) GetEventMonitorTarget();
    InstallEventHandler(eventTarget, &onKeyPressedHandler, 1,
                        &eventType, (__bridge void *)self, NULL);
  }
  
  id orgId = [NSNumber numberWithInt:(code+key)];
  
  if ( nil == [keyPressedMap objectForKey:orgId] ) {
    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    myHotKeyID.signature = 'cycl';
    myHotKeyID.id = [orgId intValue];
    
    OSStatus status = 
    RegisterEventHotKey(code, key, myHotKeyID, eventTarget, 0, &myHotKeyRef); 
    
    if ( noErr == status ) {
      id dict = [NSDictionary dictionaryWithObjectsAndKeys:
                 method, @"method",
                 (__bridge id)myHotKeyRef, @"EventHotKeyRef",
                 [NSNumber numberWithInt:code], @"code",
                 [NSNumber numberWithInt:key], @"key",
                 nil];
      
      [keyPressedMap setObject:dict forKey:orgId];
    }
    res = TRUE;
  }
  return res;
}

- (BOOL) deleteHotKey:orgId
{
  OSStatus status = noErr;
  
  id dic = [keyPressedMap objectForKey:orgId];
  if ( dic ) {
    status = UnregisterEventHotKey((__bridge EventHotKeyRef)[dic objectForKey:@"EventHotKeyRef"]);
  }
  
  return (noErr == status);
}

- (BOOL) deleteHotKey:(int)code modifier:(int)key
{
  return [self deleteHotKey:[NSNumber numberWithInt:(code+key)]];
}

- (BOOL) deleteHotKeyAll
{
  BOOL res = TRUE;
  for (id orgId in keyPressedMap) {
    res &= [self deleteHotKey:orgId];
  }
  return res;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  [self deleteHotKeyAll];
}

OSStatus onKeyPressedHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
  EventHotKeyID hotKeyID;
  GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL,
                    sizeof(hotKeyID), NULL, &hotKeyID);
  
  if (hotKeyID.signature == 'cycl') {
    if ( userData != NULL ) {
      id self = (__bridge id)userData;
      if ( self ) {
        id dic = [[self keyPressedMap] objectForKey:
                  [NSNumber numberWithInt:hotKeyID.id]];
        if ( dic ) {
          SEL sel = NSSelectorFromString([dic objectForKey:@"method"]);

          if ( [self respondsToSelector:sel] ) {
            [self performSelector:sel];
          }
        }
      }
    }      
  }
  
  return noErr;
}

@end


