//
//  Shotgun.h
//  ShotgunApi
//
//  Created by Rob Blau on 6/8/11.
//  Copyright 2011 Laika. All rights reserved.
//
/// @file Shotgun.h The main import for the API.  All public Shotgun functionality is defined.

#pragma mark - Interface

#import <Foundation/Foundation.h>

#import "ShotgunDate.h"
#import "ShotgunEntity.h"
#import "ShotgunRequest.h"


/**
 * Represents a connection to a shotgun server.
 *
 * @todo Implement Authentication
 * @todo Finish file upload/download asynchronous option
 * @todo Switch from NSException to NSError
 */
@interface Shotgun : NSObject

#pragma mark - Initialize

/*! Connect to shotgun.
 *
 * See initWithUrl
 */
+ (id)shotgunWithUrl:(NSString *)url scriptName:(NSString *)scriptName andKey:(NSString *)key;

/*! Connect to shotgun.
 *
 * @param url The url of the server to connect to.
 * @param scriptName The name of the script to connect as.
 * @param key The key for the script.
 *
 * @return A Shotgun object.
 * @exception NSException Raises if the connection fails.
 */
- (id)initWithUrl:(NSString *)url scriptName:(NSString *)scriptName andKey:(NSString *)key;

#pragma mark Query Information

/*! Return information about the shotgun server.
 *
 * @return A ShotgunRequest whose response is an NSDictionary with information about the server.
 */
- (ShotgunRequest *)info;

- (ShotgunRequest *)findEntityOfType:(NSString *)entityType withFilters:(id)filters;
- (ShotgunRequest *)findEntityOfType:(NSString *)entityType withFilters:(id)filters andFields:(id)fields;
- (ShotgunRequest *)findEntityOfType:(NSString *)entityType withFilters:(id)filters andFields:(id)fields 
                          andOrder:(id)order andFilterOperator:(NSString *)filterOperator retiredOnly:(BOOL)retiredOnly;
- (ShotgunRequest *)findEntitiesOfType:(NSString *)entityType withFilters:(id)filters;
- (ShotgunRequest *)findEntitiesOfType:(NSString *)entityType withFilters:(id)filters andFields:(id)fields;
- (ShotgunRequest *)findEntitiesOfType:(NSString *)entityType withFilters:(id)filters andFields:(id)fields 
                       andOrder:(id)order andFilterOperator:(NSString *)filterOperator;

/*! Return information about shotgun entities from the server.
 *
 * @param entityType An NSString specifying the type of entity to return.
 * @param filters An NSArray or NSDictionary  corresponding to the valid filter values
 *      from the python API (or an NSString that is well formed JSON describing the same value).
 * @param fields An NSArray of NSString that specifies what fields to return (or an NSString that is well formed JSON describing the same value).
 * @param order An NSArray of NSDictionary that specifies what fields to sort by (or an NSString that is well formed JSON describing the same value).
 * @param filterOperator A string that controls whether to join @p filters as an 'and' (when @p filterOperator is @"all")
 *      or as an 'or' (when @p filterOperator is anything else).
 * @param limit An NSUInteger.  Specifies the max number of entities to return.
 * @param page An NSUInteger.  When specified will return page @p page of the results.
 * @param retiredOnly A BOOL.  Return retired entities if YES.  Un-retired entities otherwise.
 *
 * @return A ShotgunRequest whose response is an NSArray of ShotgunEntity objects that match the filters.
 */
- (ShotgunRequest *)findEntitiesOfType:(NSString *)entityType withFilters:(id)filters andFields:(id)fields 
                       andOrder:(id)order andFilterOperator:(NSString *)filterOperator andLimit:(NSUInteger)limit
                        andPage:(NSUInteger)page retiredOnly:(BOOL)retiredOnly;

#pragma mark Modify Information

- (ShotgunRequest *)createEntityOfType:(NSString *)entityType withData:(id)data;

/*! Create a new entity
 *
 * @param entityType An NSString specifying the type of entity to return.
 * @param data An NSDictionary specifying values for fields on the new entity (or an NSString that is well formed JSON describing the same value).
 * @param returnFields An NSArray of NSStrings specifying what fields to return (or an NSString that is well formed JSON describing the same value).
 *
 * @return A ShotgunRequest whose response is a ShotgunEntity representing the created entity populated with the specified @p returnFields.
 */
- (ShotgunRequest *)createEntityOfType:(NSString *)entityType withData:(id)data returnFields:(id)returnFields;

/*! Update an existing entity
 *
 * @param entityType An NSString specifying the type of entity to return.
 * @param entityId An NSNumber with the id of the entity to update.
 * @param data An NSDictionary specifying values for fields on the new entity (or an NSString that is well formed JSON describing the same value).
 *
 * @return A ShotgunRequest whose response is a ShotgunEntity representing the created entity populated with the specified @p returnFields.
 */
- (ShotgunRequest *)updateEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId withData:(id)data;

/*! Retire an entity from the database
 *
 * @param entityType An NSString specifying the type of entity to retire.
 * @param entityId An NSNumber with the id of the entity to retire.
 *
 * @return A ShotgunRequest whose response is a NSNumber whose boolValue is TRUE if the entity was retired.  FALSE otherwise.
 */
- (ShotgunRequest *)deleteEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId;

/*! Revive an entity from the database
 *
 * @param entityType An NSString specifying the type of entity to revive.
 * @param entityId An NSNumber with the id of the entity to revive.
 *
 * @return A ShotgunRequest whose response is a NSNumber whose boolValue is TRUE if the entity was revived.  FALSE otherwise.
 */
- (ShotgunRequest *)reviveEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId;

/*! Run a series of operations on the server in a transaction
 *
 * @param requests An NSArray of NSDictionary specifying the operation to run (or an NSString that is well formed JSON describing the same value).
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods#batch">official batch docs</a> for details on the format of @p requests.
 *
 * @return A ShotgunRequest whose response is an NSArray where each element is the return value of its corresponding request.
 */
- (ShotgunRequest *)batch:(id)requests;

#pragma mark Meta Schema

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaEntityRead;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaRead;
- (ShotgunRequest *)schemaFieldReadForEntityOfType:(NSString *)entityType;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaFieldReadForEntityOfType:(NSString *)entityType forField:(NSString *)fieldName;
- (ShotgunRequest *)schemaFieldCreateForEntityOfType:(NSString *)entityType ofDataType:(NSString *)dataType withDisplayName:(NSString *)displayName;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaFieldCreateForEntityOfType:(NSString *)entityType ofDataType:(NSString *)dataType withDisplayName:(NSString *)displayName
                                 andProperties:(id)properties;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaFieldUpdateForEntityOfType:(NSString *)entityType forField:(NSString *)fieldName withProperties:(id)properties;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (ShotgunRequest *)schemaFieldDeleteForEntityOfType:(NSString *)entityType forField:(NSString *)fieldName;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (void)setSessionUuid:(NSString *)uuid;

#pragma mark Upload and Download Files

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (NSNumber *)uploadThumbnailForEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId fromPath:(NSString *)path;
- (NSNumber *)uploadForEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId fromPath:(NSString *)path;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (NSNumber *)uploadForEntityOfType:(NSString *)entityType withId:(NSNumber *)entityId fromPath:(NSString *)path
                          forField:(NSString *)fieldName withDisplayName:(NSString *)displayName andTagList:(NSString *)tagList;

/*!
 * @see The <a href="https://github.com/shotgunsoftware/python-api/wiki/Reference%3A-Methods">official docs</a>
 */
- (NSData *)downloadAttachmentWithId:(NSNumber *)attachmentId;

/*!
 * Returns the url to the thumbnail for this entity.
 *
 * This is the equivalent of having "image" filled out when finding the entity,
 * which incurs a round trip to %Shotgun per entity retrieved.  This method lets
 * you control when that round trip happens.
 *
 * @param entity A ShotgunEntity representing the entity to return the url to the thumbnail of.
 * @return an NSString that is the string form of the url to the thumbnail of @p entity.
 */
- (NSString *)thumbnailUrlForEntity:(ShotgunEntity *)entity;


/**
 * Does what processing is needed to download the thumbnail for this entity asynchronously.
 *
 * @param entity A ShotgunEntity to download the thumbnail for.
 * @param block A ThumbnailBlock that will be run on the resulting UIImage.
 * @note The image field on @p entity will be filled out as a side effect, so entity should be declared __block.
 */
- (void)thumbnailForEntity:(ShotgunEntity *)entity withBlock:(ThumbnailBlock)block;

@end
