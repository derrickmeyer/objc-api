//
//  RootViewController.m
//  Recent Versions
//
//  Created by Rob Blau on 6/14/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import "Shotgun.h"
#import "RootViewController.h"

#import "DetailViewController.h"

@interface RootViewController ()

@property (retain, readwrite, nonatomic) NSArray *projects;
@property (retain, readwrite, nonatomic) Shotgun *shotgun;

@end

@implementation RootViewController

@synthesize projects = projects_;
@synthesize shotgun = shotgun_;
@synthesize detailViewController = detailViewController_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    // Load shotgun connection information from the config plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:path];

    // Create the shotgun connection
    self.shotgun = [Shotgun shotgunWithUrl:[config objectForKey:@"url"]
                           scriptName:[config objectForKey:@"script"] 
                               andKey:[config objectForKey:@"key"]];

    // Share the connection with the detail controller
    self.detailViewController.shotgun = self.shotgun;

    // Pull down all the projects from the servers
    self.projects = [NSArray array];
    ShotgunRequest *request = [self.shotgun findEntitiesOfType:@"Project" withFilters:@"[]" andFields:@"[\"name\", \"image\"]"];
    [request setCompletionBlock:^{
        self.projects = [request response];        
        [[self tableView] reloadData];
    }];
    [request startAsynchronous];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

		
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projects count];    		    		
}

		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.  Standard table cell with the name of the project and its thumbnail.
    NSDictionary *project = [self.projects objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[project objectForKey:@"name"]];
    if (![[project objectForKey:@"image"] isEqual:[NSNull null]]) {
        NSLog(@"Loading image at: '%@'", [project objectForKey:@"image"]);
        NSURL *url = [NSURL URLWithString:[project objectForKey:@"image"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [[cell imageView] setImage:image];        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get selected project and tell the detail view
    ShotgunEntity *project = [self.projects objectAtIndex:[indexPath row]];
    [self.detailViewController setDetailItem:project];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {}

- (void)dealloc
{
    self.detailViewController = Nil;
    self.projects = Nil;
    self.shotgun = Nil;
    [super dealloc];
}

@end
