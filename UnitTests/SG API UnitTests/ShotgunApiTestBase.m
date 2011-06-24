//
//  ShotgunApiTestBase.m
//  UnitTests
//
//  Created by Rob Blau on 6/20/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import "ShotgunApiTestBase.h"

@implementation ShotgunApiTestBase

@synthesize shotgun = shotgun_;
@synthesize projectId = projectId_;
@synthesize shotId = shotId_;
@synthesize versionId = versionId_;

- (void)setUp 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *config = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
    self.shotgun = [[Shotgun alloc] initWithUrl:[config objectForKey:@"url"]
                                     scriptName:[config objectForKey:@"script"] 
                                         andKey:[config objectForKey:@"key"]];
    self.projectId = [config objectForKey:@"projectId"];
    self.shotId = [config objectForKey:@"shotId"];
    self.versionId = [config objectForKey:@"versionId"];
}

- (void)tearDown
{
    self.shotgun = Nil;
    self.projectId = Nil;
    self.shotId = Nil;
    self.versionId = Nil;
}

- (void)runSyncWith:(SEL)requestsSelector andCheckWith:(SEL)checkSelector
{
    NSArray *requests = [self performSelector:requestsSelector];
    NSMutableArray *responses = [NSMutableArray arrayWithCapacity:[requests count]];
    for (ShotgunRequest *request in requests) {
        [request startSynchronous];
        [responses addObject:[request response]];
    }
    [self performSelector:checkSelector withObject:responses];
}

- (void)runAsyncWith:(SEL)requestsSelector checkWith:(SEL)checkSelector timeout:(NSUInteger)timeout
{
    [self prepare:requestsSelector];
    NSArray *requests = [self performSelector:requestsSelector];
    __block NSMutableArray *successes = [[NSMutableArray alloc] initWithCapacity:[requests count]];
    __block NSMutableArray *failures = [[NSMutableArray alloc] initWithCapacity:[requests count]];
    for (NSUInteger index=0; index<[requests count]; index++) {
        ShotgunRequest *request = [requests objectAtIndex:index];
        [request setCompletionBlock:^{
            @synchronized(self) {
                [successes addObject:[NSNumber numberWithInt:index]];
                if ([successes count] == [requests count])
                    [self notify:kGHUnitWaitStatusSuccess forSelector:requestsSelector];
            }
        }];
        [request setFailedBlock:^{
            @synchronized(self) {
                [failures addObject:[NSNumber numberWithInt:index]];
                [self notify:kGHUnitWaitStatusFailure forSelector:requestsSelector];
            }
        }];
        [request startAsynchronous];
    }
    @try {
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout];        
    }
    @catch (NSException *exception) {
        GHTestLog(@"Successes (%d of %d): %@", [successes count], [requests count], successes);
        GHTestLog(@"Failures (%d): %@", [failures count], failures);
        @throw;
    }
    GHAssertTrue([successes count] == [requests count], @"Success count not equal to the number of requests: %@ of %d", successes, [requests count]);
    GHAssertTrue([failures count] == 0, @"Failure count is non-zero: %@", failures);
    NSMutableArray *responses = [NSMutableArray arrayWithCapacity:[requests count]];
    for (ShotgunRequest *request in requests) {
        id response = [request response];
        [responses addObject:response ? response : [NSNull null]];
    }
    [self performSelector:checkSelector withObject:responses];
    [failures release];
    [successes release];   
}

@end
