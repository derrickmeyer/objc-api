//
//  ShotgunApiTestBase.h
//  UnitTests
//
//  Created by Rob Blau on 6/20/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import "Shotgun.h"

@interface ShotgunApiTestBase : GHAsyncTestCase;

@property (retain, readwrite, nonatomic) Shotgun *shotgun;
@property (retain, readwrite, nonatomic) NSNumber *projectId;
@property (retain, readwrite, nonatomic) NSNumber *shotId;
@property (retain, readwrite, nonatomic) NSNumber *versionId;

- (void)runSyncWith:(SEL)requestsSelector andCheckWith:(SEL)checkSelector;
- (void)runAsyncWith:(SEL)requestsSelector checkWith:(SEL)checkSelector timeout:(NSUInteger)timeout;

@end
