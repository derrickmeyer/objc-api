//
//  ClientCapabilities.m
//  ShotgunApi
//
//  Created by Rob Blau on 6/11/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ClientCapabilities.m Implementation of ClientCapabilities

#import "ShotgunClientCapabilities.h"

@implementation ShotgunClientCapabilities

@synthesize platform = platform_;
@synthesize localPathField = localPathField_;

+ (id)clientCapabilities
{
    return [[ShotgunClientCapabilities alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.platform = @"mac";
        self.localPathField = @"local_path_mac";
    }
    return self;
}


@end
