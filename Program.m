//
//  Program.m
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Program.h"

@implementation Program

@synthesize title;
@synthesize url;
@synthesize installationStatus;

-(Program*) initWithTitle:(NSString*)app url:(NSString*)durl installationStatus:(NSString*)status {
    self = [super init];
    
    if ( self ) {
        self.title = app;
        self.url = durl;
        self.installationStatus = status;
    }
    
    return self;
}


@end
