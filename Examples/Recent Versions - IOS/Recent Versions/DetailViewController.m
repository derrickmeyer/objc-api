//
//  DetailViewController.m
//  Recent Versions
//
//  Created by Rob Blau on 6/14/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import "Shotgun.h"
#import "VersionTableViewCell.h"
#import "ASIHTTPRequest.h"
#import "DetailViewController.h"

#import "RootViewController.h"

@interface DetailViewController ()

@property (retain, readwrite, nonatomic) NSArray *versions;
@property (retain, readwrite, nonatomic) NSMutableDictionary *imageMap;

@end

@implementation DetailViewController

@synthesize toolbar=toolbar_;
@synthesize detailItem=detailItem_;
@synthesize shotgun = shotgun_;
@synthesize versionsTable = versionsTable_;
@synthesize versCell = versCell_;
@synthesize versions = versions_;
@synthesize imageMap = imageMap_;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(ShotgunEntity *)newDetailItem
{
    if (detailItem_ != newDetailItem) {
        detailItem_ = [newDetailItem retain];
        
        // Detail item is the selected Project, grab the 50 latest versions in that project
        self.versions = [NSArray array];
        ShotgunRequest *request = [self.shotgun findEntitiesOfType:@"Version"
                                    withFilters:[NSString stringWithFormat:
                                                 @"[[\"project\", \"is\", {\"type\": \"Project\", \"id\": %@}]]",
                                                 [detailItem_ entityId]]
                                      andFields:@"[\"code\", \"sg_status_list\", \"image\", \"created_at\"]" 
                                       andOrder:@"[{\"field_name\": \"created_at\", \"direction\": \"desc\"}]"
                              andFilterOperator:Nil andLimit:80 andPage:0 retiredOnly:NO];
        [request setCompletionBlock:^{
            self.versions = [request response];
            [self.versionsTable reloadData];
        }];
        [request startAsynchronous];
    }
}

- (ShotgunEntity *)detailItem
{
    return detailItem_;
}

- (void) awakeFromNib
{
    // Keep a map of downloaded thumbnails to keep things responsive
    self.imageMap = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Sized to 5 versions per row
    int count = [self.versions count];
    return (count == 0) ? 0 : (count+4)/5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use our custom layout
    static NSString *CellIdentifier = @"VersionCell";
    
    VersionTableViewCell *cell = (VersionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"VersionTableViewCell" owner:self options:nil];
        cell = self.versCell;
        self.versCell = nil;
    }
    
    // Configure the cell.
    int start = 5*[indexPath row];
    int count = [self.versions count];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"d/M/yyyy H:mm"];

    for (int x=0; x<5 && (start+x)<count; x++) {
        ShotgunEntity *version = [self.versions objectAtIndex:(start+x)];
        // Set the label text to the 'code' field on the version followed
        // by the formatted creation date.
        [[[cell labels] objectAtIndex:x] setText:[NSString stringWithFormat:@"%@\n%@",
                                                  [version objectForKey:@"code"],
                                                  [formatter stringFromDate:[version objectForKey:@"created_at"]]]];
        UIImage *thumbnail = [self.imageMap objectForKey:[version objectForKey:@"image"]];
        if (thumbnail) {
            // Have cached thumbnail
            [[[cell images] objectAtIndex:x] setImage:thumbnail];
        } else {
            [[[cell images] objectAtIndex:x] setImage:Nil];
            if ([version objectForKey:@"image"]) {
                // Need to download the thumbnail, use an asyncronous request to do it in the background
                __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[version objectForKey:@"image"]]];
                [request setCompletionBlock:^{
                    UIImage *thumbnail = [UIImage imageWithData:[request responseData]];
                    [self.imageMap setObject:thumbnail forKey:[version objectForKey:@"image"]];
                    [[[cell images] objectAtIndex:x] setImage:thumbnail];
                }];
                [request startAsynchronous];
            }
        }
    }
    return cell;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.toolbar = Nil;
    self.detailItem = Nil;
    self.shotgun = Nil;
    self.versionsTable = Nil;
    self.versCell = Nil;
    self.versions = Nil;
    self.imageMap = Nil;
    [super dealloc];
}

@end
