//
//  Utils.m
//  CampusJobs
//
//  Created by Sophia Zheng on 7/26/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)callAlertWithTitle:(NSString *)title alertMessage:(NSString *)message viewController:(UIViewController *)controller {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
    }];
    [alert addAction:okAction];
    
    [controller presentViewController:alert animated:YES completion:^{}];
}

+ (void)callConfirmationWithTitle:(NSString *)title confirmationMessage:(NSString *)message yesActionTitle:(NSString *)yesTitle noActionTitle:(NSString *)noTitle viewController:(UIViewController<UtilsDelegate> *)controller {
    Utils *helper = [Utils new];
    helper.delegate = controller;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create No action
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [helper confirmationAlertHandler:NO];
    }];
    [alert addAction:noAction];
    
    // create Yes action
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [helper confirmationAlertHandler:YES];
    }];
    [alert addAction:yesAction];
    
    [controller presentViewController:alert animated:YES completion:^{}];
}

- (void)confirmationAlertHandler:(BOOL)response {
    [self.delegate confirmationAlertHandler:response];
}

+ (void)animateView:(UIView *)view withDistance:(CGFloat)distance up:(BOOL)up {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    if (up) {
        distance *= -1;
    }
    
    view.frame = CGRectOffset(view.frame, 0, distance);
    
    [UIView commitAnimations];
}

+ (void)showButton:(UIButton *)button {
    [button setEnabled:YES];
    [button setTintColor:nil];
}

+ (void)hideButton:(UIButton *)button {
    [button setEnabled:NO];
    [button setTintColor:[UIColor clearColor]];
}

+ (void)showBarButton:(UIBarButtonItem *)button {
    [button setEnabled:YES];
    [button setTintColor:nil];
}

+ (void)hideBarButton:(UIBarButtonItem *)button {
    [button setEnabled:NO];
    [button setTintColor:[UIColor clearColor]];
}

//Calculating the distance between the location of a post and a user's location
+ (double)calculateDistance:(PFGeoPoint *)postGeoPoint betweenUserandPost:(PFGeoPoint *)userGeoPoint{
    //Convert postGeoPoint and userGeoPoint to CLLocation
    CLLocation  * postLocation=[[CLLocation alloc]init];
    postLocation = [postLocation initWithLatitude:postGeoPoint.latitude longitude:postGeoPoint.longitude];
    CLLocation * userLocation=[[CLLocation alloc]init];
    userLocation = [userLocation initWithLatitude:userGeoPoint.latitude longitude:userGeoPoint.longitude];
    
    //Calculate distance between the two points
    CLLocationDistance distance = [userLocation getDistanceFrom:postLocation];
    //convert from meters to miles
    double miles=distance/1609.34;
    
    return miles;
}

@end
