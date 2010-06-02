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
        p.delegate = self;
        [applications addObject:p];
    }
    
}

- (void) programDidUpdate:(Program*)pgram {
    [myTableView reloadData];
}

- (IBAction)installApplications:(id)sender {
    
    NSButton *button = (NSButton*)sender;
    [button setEnabled:NO];
    
    for (Program *p in applications)
        [p install];
        
    [myTableView reloadData];
    
}

- (IBAction)debug:(id)sender {
    Program *p = [[Program alloc] initWithTitle:@"Application" 
                                            url:@"Url"  
                             installationStatus:@"Status"];
    
    p.destinationFilename = @"/Users/kjconroy/Downloads/Firefox.dmg";
    
    [p installDmg];
    
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

-(void) dealloc {
    NSLog(@"This should be only when I quit");
    [myTableView release];
    [applications release];
    
    [super dealloc];
}


@end
