//
//  SignUpViewController.m
//  CampusJobs
//
//  Created by Sophia Khezri on 7/16/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "SignUpViewController.h"
#import "Helper.h"

@interface SignUpViewController ()

@property(strong, nonatomic) Helper *helper;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)registerUser {
    PFUser *newUser = [PFUser user];
    
    newUser.username = @"username";
    newUser.email = @"email";
    newUser.password = @"password";
    newUser[@"name"] = @"full name";
    newUser[@"address"] = @"";
    newUser[@"profileImageFile"] = [self.helper getPFFileFromImage:[UIImage imageNamed:@"image_placeholder"]];
    newUser[@"creditCardNumber"] = @"";
    newUser[@"creditCardExpDate"] = @"";
    newUser[@"creditCardCVC"] = @"";
    newUser[@"billingName"] = @"full name";
    newUser[@"billingAddress"] = @"";
    newUser[@"venmoHandle"] = @"";
    newUser[@"rating"] = @5; // out of five stars
    newUser[@"numberJobsCompleted"] = @0; // number of jobs completed as job taker
    newUser[@"conversations"] = [[NSMutableArray alloc] init];
    
    
    if (![newUser.email isEqual:@""] && ![newUser[@"name"] isEqual:@""] && ![newUser.username isEqual:@""] && ![newUser.password isEqual:@""]) {
        // call sign up function on the object
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                [self.helper callAlertWithTitle:@"Error" alertMessage:[NSString stringWithFormat:@"%@",error.localizedDescription] viewController:self];
            } else {
                NSLog(@"User registered successfully");
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }];
    } else {
        [self.helper callAlertWithTitle:@"Cannot Sign Up" alertMessage:@"No fields can be blank" viewController:self];
        NSLog(@"Did not register user");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end