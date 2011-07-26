//
//  HeidiAppDelegate.m
//  Heidi
//
//  Created by Thomas van der Kleij on 26-07-11.
//  Copyright 2011 GratisPrint.nl. All rights reserved.
//

#import "HeidiAppDelegate.h"

@implementation HeidiAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    if([self finderIsIdle])
    {
        [self readDefaultsAndNotify];
        
    } else {
        
       NSString *operation =  [self promptUser];
        
        if ([operation isEqualToString:@"continue"])
        {
            [self readDefaultsAndNotify];
        } else if ([operation isEqualToString:@"wait"]) {
            [self waitUntillDone];
        } else if ([operation isEqualToString:@"cancel"]) {
            [NSApp terminate:self];
        }
        
    }
    
}

- (void) waitUntillDone
{

    if ([self finderIsIdle]) {

        [self readDefaultsAndNotify];
        
    } else {
        
    [NSThread sleepForTimeInterval:0.5];
    [self waitUntillDone];
        
    }

    
}



- (NSString *) promptUser
{
    NSString *question = NSLocalizedString(@"Finder appears to busy", 
                                           @"Let's verify that I see this question");
    NSString *info = NSLocalizedString(@"Continuing will force finder to stop copying/deleting.\n\n Are you sure you wish to continue?", 
                                       @"Here is an info");
    NSString *cancelButton = NSLocalizedString(@"Cancel", 
                                               @"Cancel button title");
    
    NSString *confirmButton = NSLocalizedString(@"Continue", 
                                                @"Confirm button title");
    
    NSString *waitButton = NSLocalizedString(@"Wait untill done", 
                                             @"Wait untill done button title");
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:question];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:confirmButton];
    [alert addButtonWithTitle:cancelButton];
    [alert addButtonWithTitle:waitButton];
    
    
    switch ([alert runModal]) {
        case NSAlertFirstButtonReturn:
            return @"continue";
            break;
        case NSAlertSecondButtonReturn:
            return @"cancel";
            break;
        case NSAlertThirdButtonReturn:
            return @"wait";
            break;

    
    }
  return @"unknown";

}

- (void) readDefaultsAndNotify 
{
    
    piper = [[NSPipe pipe] retain];
    
    NSTask *hide = [[NSTask alloc] init];
    hide.launchPath = @"/usr/bin/defaults";
    hide.arguments = [NSArray arrayWithObjects:@"read", @"com.apple.finder", @"CreateDesktop", nil];
    hide.standardOutput = piper;
    [hide launch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readFromStandardOutput:)
                                                 name:NSFileHandleReadCompletionNotification object:[piper fileHandleForReading]];
    
    
    [[piper fileHandleForReading] readInBackgroundAndNotify];
    
}

- (BOOL) finderIsIdle 
{
    NSString *theScript = @"set thestatus to \"not busy\"\ntell application \"System Events\"\n\tset theList to get the title of every window of process \"Finder\"\n\trepeat with theItem in theList\n\t\tif theItem contains \"Copy\" then\n\t\t\tset thestatus to \"busy\"\n\t\tend if\n\t\tif theItem contains \"Kopi\u00EBren\" then\n\t\t\tset thestatus to \"busy\"\n\t\tend if\n\t\tif theItem contains \"Delete\" then\n\t\t\tset thestatus to \"busy\"\n\t\tend if\n\t\tif theItem contains \"Verwijderen\" then\n\t\t\tset thestatus to \"busy\"\n\t\tend if\n\tend repeat\nend tell\nthestatus\n";
    
    NSDictionary *errorInfo = nil;
    NSAppleScript *run = [[NSAppleScript alloc] initWithSource:theScript];
    NSAppleEventDescriptor *theDescriptor = [[NSAppleEventDescriptor alloc]init];
    theDescriptor = [run executeAndReturnError:&errorInfo];
    [theDescriptor coerceToDescriptorType:'utxt'];
    
    NSLog(@"descs %@", [theDescriptor stringValue]);
    
    if ([[theDescriptor stringValue] isEqualTo:@"busy"]) {
        return NO;
    } else {
        return YES;
    }
        
   
        
}

- (void)readFromStandardOutput:(NSNotification*)aNotification
{    NSData *theData = [[aNotification
                         userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    NSString *tempText;
    
    if (!theData)
    {  
        return ;
    }
    
    tempText = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    
    NSString *trimmedString = [tempText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *uno = [NSString stringWithFormat:@"%@", @"1"];
    
    if ([trimmedString isEqualToString: uno]) {
        
        NSTask *hide = [[NSTask alloc] init];
        hide.launchPath = @"/usr/bin/defaults";
        hide.arguments = [NSArray arrayWithObjects:@"write", @"com.apple.finder", @"CreateDesktop", @"-bool", @"false", nil];
        
        [hide launch];
        [hide release];

        NSTask *kill = [[NSTask alloc] init];
        kill.launchPath = @"/usr/bin/killall";
        kill.arguments = [NSArray arrayWithObject:@"Finder"];
        [kill launch];
        
        [[NSWorkspace sharedWorkspace] launchApplication:@"Totalfinder"];
        [NSApp terminate:self];
    } else {
                
        NSTask *hide = [[NSTask alloc] init];
        hide.launchPath = @"/usr/bin/defaults";
        hide.arguments = [NSArray arrayWithObjects:@"write", @"com.apple.finder", @"CreateDesktop", @"-bool", @"true", nil];
        [hide launch];
        [hide release]; 
        
        NSTask *kill = [[NSTask alloc] init];
        kill.launchPath = @"/usr/bin/killall";
        kill.arguments = [NSArray arrayWithObject:@"Finder"];
        [kill launch];
        [[NSWorkspace sharedWorkspace] launchApplication:@"Totalfinder"];
        [NSApp terminate:self];
    }
    
    
    [tempText release];
}

@end