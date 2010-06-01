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
    NSString *destinationFilename;
    NSMutableString *currentStringValue;
    NSMutableString *pastStringValue;
    long long totalLength;
    long long gotLength;
    
}

@property (assign) id <ProgramDelegate> delegate;
@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *installationStatus;
@property (retain) NSString *destinationFilename;
@property (retain) NSMutableString *currentStringValue;
@property (retain) NSMutableString *pastStringValue;
@property (readwrite) long long gotLength;
@property (readwrite) long long totalLength;

- (Program*) initWithTitle:(NSString*)app url:(NSString*)durl installationStatus:(NSString*)status;

- (NSString*) installationDirectory;

- (void) install;
- (void) installDmg;
- (void) installZip;
- (void) updateStatus:(NSString*)info;
- (void) cleanUp;

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path;
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length;
- (void)downloadDidFinish:(NSURLDownload *)download;

@end
