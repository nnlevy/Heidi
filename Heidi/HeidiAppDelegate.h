//
//  HeidiAppDelegate.h
//  Heidi
//
//  Created by Thomas van der Kleij on 26-07-11.
//  Copyright 2011 GratisPrint.nl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HeidiAppDelegate : NSObject <NSApplicationDelegate> {
    
    NSPipe *piper;
    
}

- (BOOL) finderIsIdle;
- (void) readDefaultsAndNotify;
- (NSString *) promptUser;
- (void) waitUntillDone;

@end

