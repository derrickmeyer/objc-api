//
//  ShotgunDate.m
//  UnitTests
//
//  Created by Rob Blau on 6/23/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ShotgunDate.m Date and DateTime implementation.

#import "ShotgunDate.h"

@interface ShotgunDate ()
@property (assign, readwrite, nonatomic) NSTimeInterval ti;
@end

@implementation ShotgunDate

@synthesize ti = ti_;

+ (id)dateWithDate:(NSDate *)date
{
    return [[[ShotgunDate alloc] initWithTimeIntervalSince1970:[date timeIntervalSince1970]] autorelease];    
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secsToBeAdded
{
    self = [super init];
    if (self) {
        self.ti = [[NSString stringWithFormat:@"%,0f", secsToBeAdded] floatValue];
    }
    return self;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return self.ti;
}

- (NSString *)descriptionWithLocale:(id)locale
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"'\"'yyyy-MM-dd'\"'"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

@end

@interface ShotgunDateTime ()
@property (assign, readwrite, nonatomic) NSTimeInterval ti;
@end

@implementation ShotgunDateTime

@synthesize ti = ti_;

+ (id)dateTimeWithDate:(NSDate *)date
{
    return [[[ShotgunDateTime alloc] initWithTimeIntervalSince1970:[date timeIntervalSince1970]] autorelease];    
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secsToBeAdded
{
    self = [super init];
    if (self) {
        self.ti = [[NSString stringWithFormat:@"%,0f", secsToBeAdded] floatValue];
    }
    return self;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return self.ti;
}

- (NSString *)descriptionWithLocale:(id)locale
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"'\"'yyyy-MM-dd'T'HH:mm:ss'Z\"'"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

@end
