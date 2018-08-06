//
//  Utils.m
//  CampusJobs
//
//  Created by Sophia Zheng on 7/26/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "Utils.h"
#import "Colors.h"
#import <ChameleonFramework/Chameleon.h>
#import "Colors.h"
#import <MaterialComponents/MaterialAppBar+ColorThemer.h>
#import <MaterialComponents/MaterialAppBar+TypographyThemer.h>
#import "AppScheme.h"

@implementation Utils

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

+ (void)addGreyGradientToView:(UIView *)view {
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:[UIColor whiteColor]];
    [colors addObject:[Colors secondaryGreyLighterColor]];
    view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:view.frame andColors:colors];
}

+ (void)addBlueGradientToView:(UIView *)view {
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:[Colors primaryBlueLightColor]];
    [colors addObject:[Colors primaryBlueColor]];
    [colors addObject:[Colors primaryBlueDarkColor]];
    view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:view.frame andColors:colors];
}

+ (void)formatColorForAppBar:(MDCAppBar *)appBar {
    id<MDCColorScheming> colorScheme = [AppScheme sharedInstance].colorScheme;
    [MDCAppBarColorThemer applySemanticColorScheme:colorScheme toAppBar:appBar];
    appBar.navigationBar.backgroundColor = [Colors primaryBlueColor];
    appBar.headerViewController.headerView.backgroundColor = appBar.navigationBar.backgroundColor;
    
    id<MDCTypographyScheming> typographyScheme = [AppScheme sharedInstance].typographyScheme;
    [MDCAppBarTypographyThemer applyTypographyScheme:typographyScheme toAppBar:appBar];
}

@end
