//  ShotgunDate.h
//  UnitTests
//
//  Created by Rob Blau on 6/23/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file ShotgunDate.h Classes implementing Date handling.

#import <Foundation/Foundation.h>

/** A thin wrapper around NSDate to be able to differentiate date objects from datetime objects. */
@interface ShotgunDate : NSDate

/*! Create a ShotgunDate object
 *
 * @param date An NSDate object to convert to a ShotgunDate
 */
+ (id)dateWithDate:(NSDate *)date;

/** Format the date to be compatible with a value in a JSON string. */
- (NSString *)descriptionWithLocale:(id)locale;

@end

/** A thin wrapper around NSDate to be able to differentiate date objects from datetime objects. */
@interface ShotgunDateTime : NSDate

/*! Create a ShotgunDateTime object
 *
 * @param date An NSDate object to convert to a ShotgunDateTime
 */
+ (id)dateTimeWithDate:(NSDate *)date;

/** Format the date to be compatible with a value in a JSON string. */
- (NSString *)descriptionWithLocale:(id)locale;

@end