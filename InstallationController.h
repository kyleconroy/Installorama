//
//  InstallationController.h
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Program.h"

@interface InstallationController : NSObject <NSTableViewDelegate, ProgramDelegate> {
    
    IBOutlet NSTableView *myTableView;
    NSArray *applications;

}

@property (retain) IBOutlet NSTableView *myTableView;
@property (retain) NSArray *applications;

- (InstallationController*) init;
- (void) loadApplicationsFromFile;

- (IBAction)installApplications:(id)sender;
- (IBAction)debug:(id)sender;

@end
