//
//  ShotgunApiTests.m
//  ShotgunApiTests
//
//  Created by Rob Blau on 6/8/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import "SBJson.h"

#import "ShotgunApiTestBase.h"

@interface ShotgunApiTest : ShotgunApiTestBase;
@end

// Get rid of warning that we are calling a private method off of a Shotgun instance
@interface Shotgun ()
- (NSString *)getSessionToken_;
@end

@implementation ShotgunApiTest

- (void)testInfo
{
    ShotgunRequest *req = [self.shotgun info];
    [req startSynchronous];
    NSDictionary *info = [req response];
    GHAssertNotNil([info objectForKey:@"version"], @"version key not found in info dict");
}

- (void)testDates
{
    ShotgunEntity *task;
    ShotgunEntity *queried;
    ShotgunEntity *playlist;
    BOOL rv;
    NSDate *now = [NSDate date];
    ShotgunDate *date = [ShotgunDate dateWithDate:now];
    ShotgunDateTime *datetime = [ShotgunDateTime dateTimeWithDate:now];
    
    // Test Date
    NSString *taskData = [NSString stringWithFormat:
           @"{                                   " \
            "  \"project\": {\"type\": \"Project\", \"id\": %@}, " \
            "  \"content\": \"ObjC Test Task\",  " \
            "  \"start_date\": %@            " \
            "} ", self.projectId, date];
    NSMutableDictionary *taskDict = [taskData JSONValue];

    task = [[self.shotgun createEntityOfType:@"Task" withData:taskData] startSynchronous];
    
    queried = [[self.shotgun findEntityOfType:task.entityType 
                                  withFilters:[NSString stringWithFormat:@"[[\"id\", \"is\", %@]]", task.entityId]
                                    andFields:@"[\"start_date\"]"] startSynchronous];
    GHAssertTrue([[queried objectForKey:@"start_date"] isEqualToString:[taskDict objectForKey:@"start_date"]],
                 @"Returned entity start_date did not match upload: %@", [queried objectForKey:@"start_date"]);
    
    rv = [[[self.shotgun deleteEntityOfType:task.entityType withId:task.entityId] startSynchronous] boolValue];
    GHAssertTrue(rv == TRUE, @"Failed to delete created Task: %@", task.entityId);
    
    [taskDict setObject:date forKey:@"start_date"];
    task = [[self.shotgun createEntityOfType:@"Task" withData:taskDict] startSynchronous];
    rv = [[[self.shotgun deleteEntityOfType:task.entityType withId:task.entityId] startSynchronous] boolValue];
    GHAssertTrue(rv == TRUE, @"Failed to delete created Task: %@", task.entityId);

    [taskDict setObject:datetime forKey:@"start_date"];
    GHAssertThrows([[self.shotgun createEntityOfType:@"Task" withData:taskDict] startSynchronous],
                   @"Passing datetime for a date field did not raise an exception");
    
    [taskDict setObject:now forKey:@"start_date"];
    GHAssertThrows([[self.shotgun createEntityOfType:@"Task" withData:taskDict] startSynchronous],
                   @"Passing NSDate for a date field did not raise an exception");
    
    // Test DateTime
    NSString *playlistData = [NSString stringWithFormat:
        @"{                                    " \
         "  \"project\": {\"type\": \"Project\", \"id\": %@}, " \
         "  \"code\": \"ObjC Test Playlist\",  " \
         "  \"sg_date_and_time\": %@           " \
         "} ", self.projectId, datetime];
    NSMutableDictionary *playlistDict = [playlistData JSONValue];
    
    playlist = [[self.shotgun createEntityOfType:@"Playlist" withData:playlistData] startSynchronous];
    
    queried = [[self.shotgun findEntityOfType:playlist.entityType 
                                  withFilters:[NSString stringWithFormat:@"[[\"id\", \"is\", %@]]", playlist.entityId]
                                    andFields:@"[\"sg_date_and_time\"]"] startSynchronous];
    id field = [queried objectForKey:@"sg_date_and_time"];
    GHAssertTrue([field isKindOfClass:[ShotgunDateTime class]],
                 @"Returned entity sg_date_and_time was not a ShotgunDateTime object");
    GHAssertTrue([field isEqualToDate:datetime], @"Returned sg_date_and_time did not match uploaded value: %f vrs %f.",
                 [field timeIntervalSinceReferenceDate], [datetime timeIntervalSinceReferenceDate]);
    rv = [[[self.shotgun deleteEntityOfType:playlist.entityType withId:playlist.entityId] startSynchronous] boolValue];
    GHAssertTrue(rv == TRUE, @"Failed to delete created Playlist: %@", playlist.entityId);
        
    [playlistDict setObject:datetime forKey:@"sg_date_and_time"];
    playlist = [[self.shotgun createEntityOfType:@"Playlist" withData:playlistDict] startSynchronous];
    rv = [[[self.shotgun deleteEntityOfType:playlist.entityType withId:playlist.entityId] startSynchronous] boolValue];
    GHAssertTrue(rv == TRUE, @"Failed to delete created Playlist: %@", playlist.entityId);
    
    [playlistDict setObject:date forKey:@"sg_date_and_time"];
    GHAssertThrows([[self.shotgun createEntityOfType:@"Playlist" withData:playlistDict] startSynchronous],
                   @"Passing date for a datetime field did not raise an exception");
    
    [playlistDict setObject:now forKey:@"sg_date_and_time"];
    GHAssertThrows([[self.shotgun createEntityOfType:@"Playlist" withData:playlistDict] startSynchronous],
                   @"Passing NSDate for a date field did not raise an exception");    
}

- (void)testBatch
{
    NSString *batch = [NSString stringWithFormat:@"[" \
     "{                               " \
     "  \"request_type\": \"create\", " \
     "  \"entity_type\":  \"Shot\",   " \
     "  \"data\": {                   " \
     "      \"code\": \"New Shot\",   " \
     "      \"project\": {\"type\": \"Project\", \"id\": %@} " \
     "  }                             " \
     "}, {                            " \
     "  \"request_type\": \"update\", " \
     "  \"entity_type\":  \"Shot\",   " \
     "  \"entity_id\": %@,            " \
     "  \"data\": {                   " \
     "      \"code\": \"Changed\"     " \
     "  }                             " \
     "}]                              ", self.projectId, self.shotId];
    ShotgunRequest *request = [self.shotgun batch:batch];
    [request startSynchronous];
    NSArray *responses = [request response];
    GHAssertTrue([responses isKindOfClass:[NSArray class]], @"Batch did not return an NSArray");
    
    NSNumber *createdId = [[responses objectAtIndex:0] objectForKey:@"id"];
    NSNumber *updatedId = [[responses objectAtIndex:1] objectForKey:@"id"];
    GHAssertTrue([createdId intValue] != 0, @"Batch create returned 0 for id");
    GHAssertTrue([updatedId isEqualToNumber:self.shotId], @"Batch updated returned id other than config.");
    
    batch = [NSString stringWithFormat:@"[     " \
                 "{                               " \
                 "  \"request_type\": \"delete\", " \
                 "  \"entity_type\":  \"Shot\",   " \
                 "  \"entity_id\": %@             " \
                 "}]", createdId];
    request = [self.shotgun batch:batch];
    [request startSynchronous];
    responses = [request response];
    GHAssertTrue([[responses objectAtIndex:0] boolValue] == TRUE, @"Batch delete did not return True");
}

- (void)testCreateUpdateDeleteRevive
{
    // Create
    NSDictionary *data = [[NSString stringWithFormat:@"{ " \
     "  \"project\": {\"type\": \"Project\", \"id\": %@},  " \
     "  \"code\": \"ObjC Unit Test Version\",              " \
     "  \"description\": \"This version should be retired by the unit tests if everything goes well.\", " \
     "  \"entity\": {\"type\": \"Shot\", \"id\": %@}       " \
     "}", self.projectId, self.shotId] JSONValue];
    ShotgunRequest *request = [self.shotgun createEntityOfType:@"Version" withData:data];
    [request startSynchronous];
    ShotgunEntity *version = [request response];
    GHAssertTrue([version.entityId intValue] != 0, @"return id of Create was 0");
    GHTestLog(@"Created version with ID: %@", version.entityId);
    GHAssertTrue([[version objectForKey:@"description"] isEqualToString:[data objectForKey:@"description"]], @"return description did not match");
    GHAssertTrue([[version objectForKey:@"code"] isEqualToString:[data objectForKey:@"code"]], @"return code did not match");    

    // Update
    NSString *updateData = @"{ \
        \"description\": \"Updated description.  Delete Next.\" \
    }";
    request = [self.shotgun updateEntityOfType:@"Version" withId:version.entityId withData:updateData];
    [request startSynchronous];
    ShotgunEntity *updatedVersion = [request response];
    GHAssertEqualStrings([updatedVersion valueForKey:@"description"], @"Updated description.  Delete Next.", @"Description not updated");
    GHAssertTrue([updatedVersion.entityId isEqualToNumber:version.entityId] != 0, @"return id of update does not match create.");

    // Delete
    request = [self.shotgun deleteEntityOfType:@"Version" withId:version.entityId];
    [request startSynchronous];
    BOOL result = [[request response] boolValue];
    GHAssertTrue(result == TRUE, @"delete returned False");
    GHTestLog(@"Deleted version with ID: %@", version.entityId);
    request = [self.shotgun deleteEntityOfType:@"Version" withId:version.entityId];
    [request startSynchronous];
    result = [[request response] boolValue];
    GHAssertTrue(result == FALSE, @"second delete returned True");
    
    // Revive
    request = [self.shotgun reviveEntityOfType:@"Version" withId:version.entityId];
    [request startSynchronous];
    result = [[request response] boolValue];
    GHAssertTrue(result == TRUE, @"revive returned False");
    GHTestLog(@"Revived version with ID: %@", version.entityId);
    request = [self.shotgun reviveEntityOfType:@"Version" withId:version.entityId];
    [request startSynchronous];
    result = [[request response] boolValue];
    GHAssertTrue(result == FALSE, @"second revive returned True");
    
    // Final Delete
    request = [self.shotgun deleteEntityOfType:@"Version" withId:version.entityId];
    [request startSynchronous];
    result = [[request response] boolValue];
    GHAssertTrue(result == TRUE, @"delete returned False");
    GHTestLog(@"Final delete of version with ID: %@", version.entityId);
}

- (void)testFind 
{
    NSString *filters = [NSString stringWithFormat:@"[" \
     " [\"project\", \"is\", {\"type\": \"Project\", \"id\": %@}], " \
     " [\"id\", \"is\", %@]                                       " \
     "]", self.projectId, self.versionId];
    NSString *fields = @"[\"id\"]";
    
    ShotgunRequest *request = [self.shotgun findEntitiesOfType:@"Version" withFilters:filters andFields:fields];
    [request startSynchronous];
    NSArray *results = [request response];
    GHAssertTrue([results isKindOfClass:[NSArray class]], @"Find did not return an NSArray");
    ShotgunEntity *version = [results objectAtIndex:0];
    GHAssertTrue([version.entityType isEqualToString:@"Version"], @"Find entity was not a Version");
    GHAssertTrue([version.entityId isEqualToNumber:self.versionId], @"Find entity id did not match config");
    
    request = [self.shotgun findEntityOfType:@"Version" withFilters:filters andFields:fields];
    [request startSynchronous];
    version = [request response];
    GHAssertTrue([version isKindOfClass:[ShotgunEntity class]], @"Find one did not return a ShotgunEntity");
    GHAssertTrue([version.entityType isEqualToString:@"Version"], @"Find one entity was not a Version");
    GHAssertTrue([version.entityId isEqualToNumber:self.versionId], @"Find one entity id did not match config");
}

- (void)testGetSessionToken
{
    NSString *uuid = [self.shotgun getSessionToken_];
    GHAssertTrue([uuid length] > 0, @"Get Session Token did not return a valid token");
    GHTestLog(@"Get Session Token returned: %@", uuid);
}

- (void)testUploadDownload 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    NSNumber *attachId = [self.shotgun uploadThumbnailForEntityOfType:@"Version" withId:self.versionId fromPath:path];
    GHAssertTrue([attachId intValue] != 0, @"upload returned zero for attachment id");

    NSData *data = [self.shotgun downloadAttachmentWithId:attachId];
    GHAssertTrue([data length] != 0, @"download for attachment returned no data.");
    
    NSData *originalData = [NSData dataWithContentsOfFile:path];
    GHAssertTrue([originalData isEqualToData:data], @"Downloaded data did not match uploaded.");
}

@end
