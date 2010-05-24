//
//  InstallationController.m
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InstallationController.h"

@implementation InstallationController

@synthesize myTableView;
@synthesize applications;

- (InstallationController*) init {
    self = [super init];
    
    if (self) {
        [self loadApplicationsFromFile];
    }
    
    return self;
}

- (void) loadApplicationsFromFile {
    
    applications = [[NSMutableArray alloc] init];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"applications" ofType:@"plist"];
    NSArray *apps = [NSArray arrayWithContentsOfFile:plistPath];
    
    for (NSDictionary *d in apps) {
        Program *p = [[Program alloc] initWithTitle:[d objectForKey:@"Application"] 
                                                url:[d objectForKey:@"Url"]  
                                 installationStatus:[d objectForKey:@"Status"]];
        [applications addObject:p];
    }
    
}

- (IBAction)installApplications:(id)sender {
    
}


/* Table View Delegate Methods */
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [applications count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row
{
    
    Program *p = [applications objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"Application"])
        return p.title;
    else if ([[tableColumn identifier] isEqualToString:@"Status"])
        return p.installationStatus;
    else
        return @"ERROR";
    
}

@end
