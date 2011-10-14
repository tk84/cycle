//
//  HotKey.h
//  cycle
//
//  Created by Hiroyuki Takahashi on 11/10/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface HotKey : NSObject
{
  id keyPressedMap;
}
@property (assign) id keyPressedMap;
- (BOOL) addHotKey:(int)code modifier:(int)key onKeyPressed:(id)method;
- (BOOL) deleteHotKey:(int)code modifier:(int)key;
- (BOOL) deleteHotKeyAll;
@end

OSStatus onKeyPressedHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);
