//
//  ShotgunRequestPrivate.m
//  UnitTests
//
//  Created by Rob Blau on 6/15/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ShotgunRequestPrivate.h Interface used by friend classes.

#import "ShotgunRequest.h"

@interface ShotgunRequest()

@property (copy, readwrite, nonatomic) ShotgunPostProcessBlock postProcessBlock;

@end