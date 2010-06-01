//
//  Program.m
//  Installorama
//
//  Created by Kyle Conroy on May24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Program.h"

@implementation Program

@synthesize delegate;
@synthesize title;
@synthesize url;
@synthesize installationStatus;
@synthesize destinationFilename;
@synthesize gotLength;
@synthesize totalLength;
@synthesize currentStringValue;
@synthesize pastStringValue;

-(Program*) initWithTitle:(NSString*)app url:(NSString*)durl installationStatus:(NSString*)status {
    self = [super init];
    
    if ( self ) {
        self.title = app;
        self.url = durl;
        self.installationStatus = status;
        self.gotLength = 0;
        self.totalLength = 0;
    }
    
    return self;
}

- (void) updateStatus:(NSString*)info {
    self.installationStatus = info;
    NSLog(@"%@: %@", title, info);
    [delegate programDidUpdate:self];
}

- (NSString*) installationDirectory {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Applications"];
}

- (void) install {
    
    [self updateStatus:@"Downloading"];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                
                                            timeoutInterval:60.0];
    
    
    
    // Create the connection with the request and start loading the data.
    
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest
                                   
                                                                delegate:self];
    

    if (!theDownload) {
        
        [self updateStatus:@"Error: Download Failed"];
        
    }
    
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename

{
    NSString* dFilename = [NSTemporaryDirectory()                           
                           stringByAppendingPathComponent:filename];
    
    [download setDestination:dFilename allowOverwrite:NO];
    
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error

{
    
    // Inform the user.
    [self updateStatus:@"Error: Download Failed"];
    
    NSLog(@"%@: Download failed! Error - %@", title,
          
          [error localizedDescription]);
    
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path {
    NSLog(@"didCreateDestination %@", path);
    destinationFilename = path;
    [destinationFilename retain];
}

- (void) download: (NSURLDownload *) download didReceiveResponse: (NSURLResponse *) response
{
    gotLength = 0;
    totalLength = [response expectedContentLength];
}

- (void) download: (NSURLDownload *) download willResumeWIthResponse: (NSURLResponse *) response fromByte: (long long) startingByte
{
    gotLength = startingByte;
    totalLength = gotLength + [response expectedContentLength];
}


- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length {
    
    if (totalLength > 0){
        gotLength += length;
        float currentValue = (float) gotLength;
        float totalValue = (float) totalLength;
        [self updateStatus:[NSString stringWithFormat:@"%.2f%% downloaded", (currentValue / totalValue) * 100]]; 
    }
    
}

- (void)downloadDidFinish:(NSURLDownload *)download

{
    if (destinationFilename) {
        
        if ([[url pathExtension] isEqualToString:@"dmg"])
            [self installDmg];
        else if ([[url pathExtension] isEqualToString:@"zip"])
            [self installZip];
        else {
            [self updateStatus:[NSString stringWithFormat:@"Error: Could not install file with extension %@", [url pathExtension]]];
            [self cleanUp];
        }
        
    } else {
        NSLog(@"Download destination not set");
        [self cleanUp];
    }
    
    [download release];

}

- (void)installZip {
    
    NSLog(@"Unpacking zip");
    [self updateStatus:@"Unpacking zip"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationDir = [self installationDirectory];
    
    NSTask *task = [[[NSTask alloc]init]autorelease];
    
    [task setLaunchPath:@"/usr/bin/ditto"];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-xk",  destinationFilename, destinationDir, nil];
    [task setArguments: arguments];
    
    [task launch];
    [task waitUntilExit];
    
    
    NSError *error;
    NSString* escapedPath = [destinationFilename  
                             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *zipFileUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"file://%@", escapedPath]];
    
    if (!zipFileUrl) {
        NSLog(@"Escaped path is not valid RFC 2396 %@",escapedPath);
    } else if (![fileManager removeItemAtURL:zipFileUrl error:&error]) {
        NSLog(@"Could not delete file %@",zipFileUrl);
        
    }
    [zipFileUrl release];
    
    [self cleanUp];
    
}

- (void) installDmg {
    [self updateStatus:@"Mounting DMG file"];
    
    if (!destinationFilename) {
        [self updateStatus:@"destinationFilename Not Set"];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSPipe *tout = [[NSPipe alloc] init];
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setStandardOutput:tout];
    
    
    // TODO Add @"-nobrowse" back into the mix
    NSArray *arguments = [NSArray arrayWithObjects: @"attach", destinationFilename, @"-plist", nil];
    [task setArguments: arguments];
    
    [task launch];
    [task waitUntilExit];
    
    
    if ([task terminationStatus] != 0) {
        [self updateStatus:@"Could not mount DMG"];
        [self cleanUp];
        [task release];
        [tout release];
        return;
    }
    
    NSFileHandle *outputHandle = [tout fileHandleForReading];
    
    
    //Load plist XML
    NSString *content = [NSString stringWithUTF8String:[[outputHandle availableData] bytes]];
    
    NSDictionary *dmgInfo = [content propertyList];
    
//    NSXMLParser *dmgParser = [[NSXMLParser alloc] initWithData:[outputHandle availableData]];
//    dmgParser.delegate = self;
//    
//    BOOL success = [dmgParser parse];
//    
//    if (success) {
//
//    }
    
    // List directory of mounted DMG

    //NSArray *dmgFiles = [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"/Volumes/%d", title] error:&error];
    
    // Copy over any .app files into the destination directory directory
    
    // Unmount the Dmg
}

- (void) cleanUp {
    [self updateStatus:@"Deleting temporary files"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL *isDir;
    BOOL exists = [fileManager fileExistsAtPath:destinationFilename isDirectory:isDir];
    
    if (exists && !isDir) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:destinationFilename error:&error];
        
        if (success) {
            [self updateStatus:@"Deleted temporary files"];
        } else {
            [self updateStatus:@"Could not delete temporary files"];
        }
    }
    
    [self updateStatus:@"Successfully installed"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (!currentStringValue) {
        
        currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
        
    }
    
    [currentStringValue appendString:string];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
qualifiedName:(NSString *)qName {
    
    NSLog(@"%@", currentStringValue);
    
    if ([currentStringValue isEqualToString:@"mount-point"]) {
        NSLog(@"%@", currentStringValue);
    }
    
    pastStringValue = currentStringValue;
    
}

-(void) dealloc {
    [title release];
    [url release];
    [installationStatus release];
    [destinationFilename release];
    
    [super dealloc];
}



@end
