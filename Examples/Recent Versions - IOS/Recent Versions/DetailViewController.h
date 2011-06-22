//
//  DetailViewController.h
//  Recent Versions
//
//  Created by Rob Blau on 6/14/11.
//  Copyright 2011 Laika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shotgun;
@class ShotgunEntity;
@class VersionTableViewCell;

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) ShotgunEntity *detailItem;
@property (nonatomic, retain) IBOutlet UITableView *versionsTable;
@property (nonatomic, retain) IBOutlet VersionTableViewCell *versCell;
@property (nonatomic, retain) Shotgun *shotgun;

@end
