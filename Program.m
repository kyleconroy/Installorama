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
@synthesize mountPoint;

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

- (NSURL*) installationUrl {
    return [NSURL fileURLWithPath:[self installationDirectory] isDirectory:YES];
}

- (void) install {
    
    [self updateStatus:@"Checking for previous installed applications"];
    
    NSString *installPath = [[self installationDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.app", title]]; 
    
    NSLog(@"Install Path: %@", installPath);
                         
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:installPath];
    
    if (exists) {
        [self cleanUp];
        [self updateStatus:@"Application alread installed, remove to continue"];
        return;
    }
    
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
    
    NSString *destinationDir = [self installationDirectory];
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/usr/bin/ditto"];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-xk",  destinationFilename, destinationDir, nil];
    [task setArguments: arguments];
    
    [task launch];
    [task waitUntilExit];
    
    
    [self cleanUp];
    [self updateStatus:@"Successfully Installed"];
    
}

- (void) installDmg {
    [self updateStatus:@"Mounting DMG file"];
    
    if (!destinationFilename) {
        [self updateStatus:@"destinationFilename Not Set"];
        return;
    }
    
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
        [self cleanUp];
        [self updateStatus:@"Could not mount DMG"];
        [task release];
        [tout release];
        return;
    }
    
    [self updateStatus:@"Mounting Completed"];
    
    NSFileHandle *outputHandle = [tout fileHandleForReading];
    
    
    //Load plist XML
    NSString *content = [[NSString alloc] initWithData:[outputHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    NSLog(@"content: %@", content);
    
    NSDictionary *dmgInfo = [content propertyList];
    
    NSLog(@"DMGINFO: %@", dmgInfo);
    
    for (NSDictionary *d in [dmgInfo objectForKey:@"system-entities"]) {
        if ([d objectForKey:@"mount-point"]) {
            mountPoint = [d objectForKey:@"mount-point"];
        }
    }
    
    [task release];
    [tout release];
    
    if (!mountPoint) {
        [self cleanUp];
        [self updateStatus:@"Could Not Find a suitable moint point"];
        return;
    }
    
    // List directory of mounted DMG
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *mountUrl = [NSURL fileURLWithPath:mountPoint isDirectory:YES];
    
    NSError *error;
    NSArray *dmgFiles = [fileManager contentsOfDirectoryAtURL:mountUrl 
                                   includingPropertiesForKeys:NULL
                                                      options:NSDirectoryEnumerationSkipsSubdirectoryDescendants 
                                                        error:&error];
    
    if (!dmgFiles) {
        [self cleanUp];
        [self updateStatus:@"Could not open volume"];
        return;
    }
    
    // Copy over any .app files into the destination directory directory
    NSURL *destDir = [self installationUrl];
    
    for (NSURL *u in dmgFiles) {
        
        if ([[u pathExtension] isEqualToString:@"app"]) {
            
            [self updateStatus:[NSString stringWithFormat:@"Copying %@ to installation directory", [u lastPathComponent]]];
            
            BOOL copySuccess = [fileManager copyItemAtURL:u 
                                                    toURL:[NSURL URLWithString:[u lastPathComponent] relativeToURL:destDir] 
                                                    error:&error];
            
            if (!copySuccess) {
                [self cleanUp];
                [self updateStatus:@"Failed copying some .app files"];
                return;
            }
        }
    }
    
    // Unmount the Dmg
    [self cleanUp];
    
    // Tell the user everything went Ok
    [self updateStatus:@"Installation Successful"];
}

- (void) cleanUp {
    if (mountPoint) {
        [self updateStatus:@"Unmounting Disk"];
        
        NSTask *task = [[NSTask alloc] init];
        
        [task setLaunchPath:@"/usr/bin/hdiutil"];
        
        NSArray *arguments = [NSArray arrayWithObjects: @"detach", mountPoint, @"-force", nil];
        [task setArguments: arguments];
        
        [task launch];
        [task waitUntilExit];
        
        if ([task terminationStatus] != 0) {
            [self updateStatus:@"Could not unmount DMG"];
        } else {
            [self updateStatus:@"Disk Unmounted Successfully"];
        }
        
    }
    
    if (destinationFilename) {
        
        [self updateStatus:@"Deleting temporary files"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL exists = [fileManager fileExistsAtPath:destinationFilename];
        
        if (exists) {
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:destinationFilename error:&error];
            
            if (success) {
                [self updateStatus:@"Deleted temporary files"];
            } else {
                [self updateStatus:@"Could not delete temporary files"];
            }
        }
            
    }
    
}

-(void) dealloc {
    [title release];
    [url release];
    [installationStatus release];
    [destinationFilename release];
    
    [super dealloc];
}



@end
