//
//  ShotgunApiLongTests.m
//  ShotgunApiLongTests
//
//  Created by Rob Blau on 6/20/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import "ShotgunApiTestBase.h"

@interface ShotgunApiLongTest : ShotgunApiTestBase {}
@end

@implementation ShotgunApiLongTest

#pragma mark Test Schema

- (NSArray *)schemaTestRequests
{
    ShotgunRequest *req1 = [self.shotgun schemaEntityRead];
    ShotgunRequest *req2 = [self.shotgun schemaRead];
    ShotgunRequest *req3 = [self.shotgun schemaFieldReadForEntityOfType:@"Version"];
    ShotgunRequest *req4 = [self.shotgun schemaFieldReadForEntityOfType:@"Version" forField:@"user"];
    ShotgunRequest *req5 = [self.shotgun schemaFieldCreateForEntityOfType:@"Version" 
                                                          ofDataType:@"number"
                                                     withDisplayName:@"Monkey Count" 
                                                       andProperties:@"{\"description\": \"How many monkeys were needed\"}"];
    NSArray *requests = [NSArray arrayWithObjects:req1, req2, req3, req4, req5, nil];
    return requests;
}

- (void)schemaTestResponses:(NSArray *)responses
{
    id res1 = [responses objectAtIndex:0];
    id res2 = [responses objectAtIndex:1];
    id res3 = [responses objectAtIndex:2];
    id res4 = [responses objectAtIndex:3];
    id res5 = [responses objectAtIndex:4];
    GHAssertTrue([res1 isKindOfClass:[NSDictionary class]], @"SchemaEntityRead was not an NSDictionary");
    GHAssertTrue([res1 count]>0, @"SchemaEntityRead count was zero");
    GHAssertTrue([res2 isKindOfClass:[NSDictionary class]], @"SchemaRead was not an NSDictionary");
    GHAssertTrue([res2 count]>0, @"SchemaRead count was zero");
    GHAssertTrue([res3 isKindOfClass:[NSDictionary class]], @"SchemaFieldRead was not an NSDictionary");
    GHAssertTrue([res3 count]>0, @"SchemaFieldRead count was zero");
    GHAssertTrue([res4 isKindOfClass:[NSDictionary class]], @"SchemaFieldRead was not an NSDictionary");
    GHAssertTrue([res4 count]>0, @"SchemaFieldRead count was zero");
    GHAssertTrue([res4 objectForKey:@"user"] != Nil, @"SchemaFieldRead did not have user");
    GHAssertTrue([res5 isKindOfClass:[NSString class]], @"SchemaFieldCreate was not an NSString");
    
    ShotgunRequest *update = [self.shotgun schemaFieldUpdateForEntityOfType:@"Version"
                                                              forField:res5
                                                        withProperties:@"{\"description\": \"How many monkeys turned up\"}"];
    [update startSynchronous];
    GHAssertTrue([[update response] isKindOfClass:[NSNumber class]], @"SchemaFieldUpdate was not an NSNumber");
    GHAssertTrue([[update response] boolValue] == YES, @"SchemaFieldUpdate did not return true.");

    ShotgunRequest *delete = [self.shotgun schemaFieldDeleteForEntityOfType:@"Version" forField:res5];
    [delete startSynchronous];
    GHAssertTrue([[delete response] isKindOfClass:[NSNumber class]], @"SchemaFieldUpdate was not an NSNumber");
    GHAssertTrue([[delete response] boolValue] == YES, @"SchemaFieldUpdate did not return true.");
}

- (void)testSchemaSync
{
    [self runSyncWith:@selector(schemaTestRequests)
         andCheckWith:@selector(schemaTestResponses:)];
}

- (void)testSchemaAsync
{
    [self runAsyncWith:@selector(schemaTestRequests)
             checkWith:@selector(schemaTestResponses:)
               timeout:60.0];
}

#pragma mark Test Automated Find

- (NSArray *)automatedFindRequests
{
    ShotgunRequest *request = [self.shotgun schemaEntityRead];
    [request startSynchronous];
    NSDictionary *entityInfo = [request response];
    NSMutableArray *requests = [NSMutableArray array];
    
    NSString *direction = @"asc";
    NSString *filterOperator = @"all";
    NSUInteger limit = 1;
    NSUInteger page = 1;
    
    for (NSString *entityType in entityInfo) {
        request = [self.shotgun schemaFieldReadForEntityOfType:entityType];
        [request startSynchronous];
        NSDictionary *fields = [request response];
        if ([fields count] == 0) {
            GHTestLog(@"Entity %@ has no fields, skipping", entityType);
            continue;
        }

        NSString *order = [NSString stringWithFormat:@"[{\"field_name\": \"%@\", \"direction\": \"%@\"}]",
                           [[fields keyEnumerator] nextObject], direction];
        NSString *filters;
        if ([fields objectForKey:@"project"] != Nil)
            filters = [NSString stringWithFormat:@"[[\"project\", \"is\", "\
                       "{\"type\": \"Project\", \"id\": %@}]]", self.projectId];
        else
            filters = @"[]";
        
        request = [self.shotgun findEntitiesOfType:entityType 
                                       withFilters:filters 
                                         andFields:[fields allKeys] 
                                          andOrder:order
                                 andFilterOperator:filterOperator
                                          andLimit:limit 
                                           andPage:page
                                       retiredOnly:NO];
        [requests addObject:request];
        
        filterOperator = [filterOperator isEqualToString:@"all"] ? @"any" : @"all";
        direction = [direction isEqualToString:@"desc"] ? @"asc" : @"desc";
        limit = (limit % 5) + 1;
        page = (page % 3) + 1;
    }
    return requests;
}

- (void)automatedFindTestResponses:(NSArray *)responses
{
    for (id response in responses) {
        GHAssertTrue([response isKindOfClass:[NSArray class]], @"TestAutomatedFind response was not a list.");
        if ([response count] != 0) {
            ShotgunEntity *entity = [response objectAtIndex:0];
            GHAssertTrue([entity isKindOfClass:[ShotgunEntity class]], @"TestAutomatedFind returned a non ShotgunEntity");
            GHTestLog(@"%@: %@", entity.entityType, entity);
        }
    }
}

- (void)testAutomatedFindSync
{
    [self runSyncWith:@selector(automatedFindRequests)
         andCheckWith:@selector(automatedFindTestResponses:)];
}

- (void)testAutomatedFindAsync
{
    [self runAsyncWith:@selector(automatedFindRequests)
             checkWith:@selector(automatedFindTestResponses:)
               timeout:120.0];
}

@end