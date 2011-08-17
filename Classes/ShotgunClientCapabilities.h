//
//  ClientCapabilities.h
//  ShotgunApi
//
//  Created by Rob Blau on 6/11/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ClientCapabilities.h A structure for storing information about the client.

#import <Foundation/Foundation.h>

@interface ShotgunClientCapabilities : NSObject

@property (retain, readwrite, nonatomic) NSString *platform;
@property (retain, readwrite, nonatomic) NSString *localPathField;

+ (id) clientCapabilities;
- (id) init;

@end
