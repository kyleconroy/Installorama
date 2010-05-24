//
//  Program.h
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Program;

@protocol ProgramDelegate <NSObject>

- (void)programDidUpdate:(Program*)pgram;

@end


@interface Program : NSObject {
    
    id <ProgramDelegate> delegate;
    NSString *title;
    NSString *url;
    NSString *installationStatus;
    
}

@property (assign) id <ProgramDelegate> delegate;
@property (copy) NSString *title;
@property (copy) NSString *url;
@property (copy) NSString *installationStatus;

- (Program*) initWithTitle:(NSString*)app url:(NSString*)durl installationStatus:(NSString*)status;
- (void) install;

@end
