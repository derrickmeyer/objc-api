//
//  ShotgunRequest.m
//  UnitTests
//
//  Created by Rob Blau on 6/15/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ShotgunRequest.m Implementation of Request handling.
/// @todo Make requests copyable

#import "SBJson.h"
#import "ASIHTTPRequest.h"

#import "ShotgunConfig.h"
#import "ShotgunEntity.h"

#import "ShotgunLogging.h"
#import "ShotgunRequest.h"
#import "ShotgunRequestPrivate.h"

static NSOperationQueue *sharedQueue = Nil;

@interface ShotgunRequest()

@property (retain, readwrite, nonatomic) id response;
@property (retain, readwrite, nonatomic) NSError *error;
@property (retain, readwrite, nonatomic) ASIHTTPRequest *request;
@property (assign, readwrite, nonatomic) BOOL isFinished;
@property (assign, readwrite, nonatomic) BOOL isExecuting;

@property (assign, readwrite, nonatomic) NSUInteger currentAttempt;
@property (assign, readwrite, nonatomic) NSUInteger timeout;
@property (assign, readwrite, nonatomic) NSUInteger maxAttempts;
@property (retain, readwrite, nonatomic) ShotgunConfig *config;
@property (retain, readwrite, nonatomic) NSString *path;
@property (retain, readwrite, nonatomic) NSString *body;
@property (retain, readwrite, nonatomic) NSDictionary *headers;
@property (retain, readwrite, nonatomic) NSString *method;

- (void)startSynchronous:(BOOL)synchronous;
- (void)continueSynchronous:(BOOL)synchronous;
- (void)finishSynchronous:(BOOL)synchronous;
- (ASIHTTPRequest *)makeRequest;

@end

#pragma mark ShotgunRequest

@implementation ShotgunRequest

@synthesize response = response_;
@synthesize request = request_;
@synthesize error = error_;
@synthesize queue = queue_;

@synthesize startedBlock = startedBlock_;
@synthesize completionBlock = completionBlock_;
@synthesize failedBlock = failedBlock_;
@synthesize postProcessBlock = postProcessBlock_;

@synthesize isExecuting = isExecuting_;
@synthesize isFinished = isFinished_;

@synthesize currentAttempt = currentAttempt_;
@synthesize timeout = timeout_;
@synthesize maxAttempts = maxAttempts_;
@synthesize config = config_;
@synthesize path = path_;
@synthesize body = body_;
@synthesize headers = headers_;
@synthesize method = method_;

+ (void)initialize
{
    if (self == [ShotgunRequest class]) {
        sharedQueue = [[NSOperationQueue alloc] init];
        [sharedQueue setName:@"Shotgun Request Default Queue"];
        [sharedQueue setMaxConcurrentOperationCount:4];
    }
}

+ (id)shotgunRequestWithConfig:(ShotgunConfig *)config path:(NSString *)path body:(NSString *)body headers:(NSDictionary *)headers andHTTPMethod:(NSString *)method
{
    return [[ShotgunRequest alloc] initWithConfig:config path:path body:body headers:headers andHTTPMethod:method];
}

+ (NSOperationQueue *)sharedQueue
{
    return sharedQueue;
}

- (id)initWithConfig:(ShotgunConfig *)config path:(NSString *)path body:(NSString *)body headers:(NSDictionary *)headers andHTTPMethod:(NSString *)method 
{
    self = [super init];
    if (self) {
        self.config = config;
        self.path = path;
        self.body = body;
        self.headers = headers;
        self.method = method;
        self.queue = sharedQueue;
    }
    return self;
}

- (id)startSynchronous
{
    [self startSynchronous:YES];
    return [self response];
}

- (void)startSynchronous:(BOOL)synchronous
{
    if ((synchronous == NO) && ([NSThread isMainThread] == NO)) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    self.currentAttempt = 0;
    self.maxAttempts = self.config.maxRpcAttempts;
    self.timeout = self.config.timeoutSecs;
    self.request = [self makeRequest];
    NSString *body = [[NSString alloc] initWithData:[self.request postBody] encoding:NSUTF8StringEncoding];
    SG_INFO(@"\nStarting %@ request %@ with body\n-----------------------\n%@\n-----------------------",
            synchronous ? @"synchronous" : @"asynchronous",
            [self.request requestID],
            body);

    if (synchronous == YES) {
        [self.request startSynchronous];
        [self finishSynchronous:YES];
    } else {
        [self willChangeValueForKey:@"isExecuting"];
        self.isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self.request setDelegate:self];
        [self.request startAsynchronous];
        if (self.startedBlock)
            self.startedBlock();  
    }
}

- (void)startAsynchronous
{
    int runningCount = 0;
    NSArray *ops = [self.queue operations];
    for (NSOperation *op in ops)
        runningCount += ([op isExecuting]) ? 1 : 0;
    SG_INFO(@"ASYNC Starting: Queue count (%d/%d running)", runningCount, [ops count]);
    [self.queue addOperation:self];
}

- (void)start
{
    [self startSynchronous:NO];
}

- (void)continueSynchronous:(BOOL)synchronous
{
    if (synchronous == YES) {
        while (self.currentAttempt < self.maxAttempts) {
            self.currentAttempt += 1;
            SG_INFO(@"Request failed, trying again (try %d). %@", self.currentAttempt, [self.request error]);
            self.request = [self makeRequest];
            [self.request startSynchronous];
            NSData *data = [self.request responseData];
            if (data != Nil)
                return;
        }
    } else {
        self.currentAttempt += 1;
        self.request = [self makeRequest];
        [self.request startAsynchronous];
    }
}

- (void)finishSynchronous:(BOOL)synchronous
{
    NSData *data = [self.request responseData];
    if ((data == Nil) && (self.currentAttempt < self.maxAttempts)) {
        SG_INFO(@"Request failed, trying again.");
        [self continueSynchronous:synchronous];
        return;
    }

    self.response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.postProcessBlock)
        self.response = self.postProcessBlock([self.request responseHeaders], self.response);
    SG_INFO(@"Finished request %@", [self.request requestID]);
    SG_DEBUG(@"Response status is %d %@", [self.request responseStatusCode], [self.request responseStatusMessage]);
    SG_DEBUG(@"Response headers are %@", [self.request responseHeaders]);
    SG_DEBUG(@"Response is %@", self.response);

    if (synchronous == NO) {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        self.isExecuting = NO;
        self.isFinished = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        // Queue will take care of running the completion block
    }
}

#pragma mark ASIHTTPRequest Delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    SG_INFO(@"ASYNC Started: %@", [request requestID]);    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    SG_INFO(@"ASYNC Finished: %@", [request requestID]);
    [self finishSynchronous:NO];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *body = [[NSString alloc] initWithData:[self.request postBody] encoding:NSUTF8StringEncoding];
    SG_INFO(@"ASYNC Failed (current %d): %@\n%@\n-----------\n%@\n----------", self.currentAttempt, [request requestID], [request error], body);
    /// @todo Set class error
    if (self.currentAttempt < self.maxAttempts) {
        [self continueSynchronous:NO];
        return;
    }
    self.error = [self.request error];
    if (self.failedBlock)
        self.failedBlock();
    [self finishSynchronous:NO];
}


- (ASIHTTPRequest *)makeRequest
{
    NSURL *url = [[NSURL alloc] initWithScheme:self.config.scheme host:self.config.server path:self.path];
    ASIHTTPRequest *aRequest = [ASIHTTPRequest requestWithURL:url];
    [aRequest setUserAgent:@"shotgun-json"];
    [aRequest setPostBody:[NSMutableData dataWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding]]];
    [aRequest setRequestMethod:self.method];
    [aRequest setRequestHeaders:[NSMutableDictionary dictionaryWithDictionary:self.headers]];
    [aRequest setShouldAttemptPersistentConnection:YES];
    [aRequest setTimeOutSeconds:self.timeout];
    [aRequest setNumberOfTimesToRetryOnTimeout:self.config.maxRpcAttempts];
    return aRequest;
}

- (BOOL)isConcurrent
{
    return YES;
}

@end