//
//  InstalloramaAppDelegate.h
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstallationController.h"

@interface InstalloramaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    InstallationController *ic;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) InstallationController *ic;

@end
