//
//  ComposeNewPostViewController.h
//  CampusJobs
//
//  Created by Sophia Khezri on 7/16/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <MapKit/MapKit.h>

@interface ComposeNewPostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *enteredTitle;
@property (weak, nonatomic) IBOutlet UITextField *enteredDescription;
@property (strong, nonatomic) PFGeoPoint * savedLocation;
@property (strong, nonatomic) NSString * savedLocationAddress;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;


- (void)getAddressFromCoordinate:(PFGeoPoint *)geoPointLocation;


@end
