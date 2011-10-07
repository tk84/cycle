//
//  main.m
//  uielement
//
//  Created by Hiroyuki Takahashi on 11/10/03.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
