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
    bool hasAgreement;
    NSString *title;
    NSString *url;
    NSString *installationStatus;
    NSString *destinationFilename;
    NSString *mountPoint;
    NSMutableString *currentStringValue;
    NSMutableString *pastStringValue;
    NSPipe *mountOut;
    NSTask *mountTask;
    long long totalLength;
    long long gotLength;
    float progress;
    
}

@property (assign) id <ProgramDelegate> delegate;
@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *installationStatus;
@property (retain) NSString *destinationFilename;
@property (retain) NSString *mountPoint;
@property (retain) NSMutableString *currentStringValue;
@property (retain) NSMutableString *pastStringValue;
@property (retain) NSPipe *mountOut;
@property (retain) NSTask *mountTask;
@property (readwrite) bool hasAgreement;
@property (readwrite) float progress;
@property (readwrite) long long gotLength;
@property (readwrite) long long totalLength;

- (Program*) initWithTitle:(NSString*)app url:(NSString*)durl;

- (NSString*) installationDirectory;
- (NSURL*) installationUrl;

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
