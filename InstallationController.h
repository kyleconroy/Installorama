//
//  InstallationController.h
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Program.h"

@interface InstallationController : NSObject <NSTableViewDelegate> {
    
    IBOutlet NSTableView *myTableView;
    NSMutableArray *applications;

}

@property (assign) IBOutlet NSTableView *myTableView;
@property (assign) NSMutableArray *applications;

- (InstallationController*) init;
- (void) loadApplicationsFromFile;
- (IBAction)installApplications:(id)sender;

@end
