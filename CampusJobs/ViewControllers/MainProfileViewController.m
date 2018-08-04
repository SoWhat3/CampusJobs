//
//  MainProfileViewController.m
//  CampusJobs
//
//  Created by Sophia Khezri on 7/26/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "MainProfileViewController.h"
#import "Parse.h"
#import "ParseUI.h"
#import "Colors.h"
#import "Utils.h"
#import <ChameleonFramework/Chameleon.h>
#import <MaterialComponents/MaterialButtons.h>
#import <MaterialComponents/MaterialAppBar+ColorThemer.h>
#import "AppScheme.h"

@interface MainProfileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet PFImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIView *roundedEdgeView;
@property (weak, nonatomic) IBOutlet MDCFlatButton *editProfPicButton;
@property (weak, nonatomic) IBOutlet MDCRaisedButton *editPersonalSettingsButton;
@property (weak, nonatomic) IBOutlet MDCRaisedButton *editPaymentInfoButton;
@property (weak, nonatomic) IBOutlet MDCRaisedButton *editDesiredRadiusButton;
@property (strong, nonatomic) MDCAppBar *appBar;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation MainProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser=[PFUser currentUser];
    [self setMainPageLabels];
    [self formatPicAndButtons];
    
    self.appBar = [[MDCAppBar alloc] init];
    [self addChildViewController:_appBar.headerViewController];
    [self.appBar addSubviewsToParent];
    self.title = @"YOUR PROFILE";
    [Utils formatColorForAppBar:self.appBar];
    [self formatViewLayout];
}

//Helper method
- (void)formatViewLayout{
    //Format top view
    self.topView.frame=CGRectMake(0,0, self.view.frame.size.width, 300);
    NSMutableArray *topColors = [NSMutableArray array];
    [topColors addObject:[Colors primaryBlueLightColor]];
    [topColors addObject:[Colors primaryBlueColor]];
    self.topView.backgroundColor=[UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.topView.frame andColors:topColors];
    
    //format rounded view
    self.roundedEdgeView.frame=CGRectMake(-self.view.frame.size.width/2, self.topView.frame.size.height-50, self.view.frame.size.width *2, 100);
    self.roundedEdgeView.layer.cornerRadius=self.roundedEdgeView.frame.size.width / 2;
    self.roundedEdgeView.clipsToBounds=YES;
    self.roundedEdgeView.backgroundColor=[Colors primaryBlueColor];
    
    //format bottom view
    NSMutableArray *bottomColors = [NSMutableArray array];
    [bottomColors addObject:[Colors secondaryGreyLightColor]];
    [bottomColors addObject:[UIColor whiteColor]];
    [bottomColors addObject:[Colors secondaryGreyLightColor]];
    self.view.backgroundColor=[UIColor colorWithGradientStyle:UIGradientStyleRadial withFrame:self.view.frame andColors:bottomColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapEditProfilePicButton:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    // Dismiss UIImagePickerController to go back to profile view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.profilePicture setImage:editedImage];
    PFUser *user= PFUser.currentUser;
    user[@"profileImageFile"]=[self getPFFileFromImage:editedImage];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!succeeded){
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

//Converts the image to a file
-(PFFile *)getPFFileFromImage: (UIImage * _Nullable) image{
    if(!image){
        return nil;
    }
    NSData * imageData =UIImagePNGRepresentation(image);
    
    if(!imageData){
        return nil;
    }
    return [PFFile fileWithName: @"image.png" data:imageData];
}

//Helper method
- (void)setMainPageLabels{
    //set labels
    self.usernameLabel.text=self.currentUser.username;
    self.emailLabel.text=self.currentUser.email;
    self.nameLabel.text=self.currentUser[@"name"];
}

//Helper method
- (void)formatPicAndButtons{
    //set profile picture (if there is one already selected)
    if(self.currentUser[@"profileImageFile"]){
        self.profilePicture.file = self.currentUser[@"profileImageFile"];
        [self.profilePicture loadInBackground];
    }
    //Create a circle for profile picture
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    
    //format profile picture border
    self.profilePicture.layer.borderColor=[[Colors primaryOrangeColor]CGColor];
    self.profilePicture.layer.borderWidth=2.0;
    
    //Edit profile picture button
    self.editProfPicButton.layer.borderWidth=.25f;
    [self.editProfPicButton sizeToFit];
    
    //Add rounded edges to bottom view buttons
    self.editPersonalSettingsButton.layer.cornerRadius=3.0;
    self.editPaymentInfoButton.layer.cornerRadius=3.0;
    self.editDesiredRadiusButton.layer.cornerRadius=3.0;
    
    //Change button shadow to selected orange
    self.editPersonalSettingsButton.layer.shadowColor=[[Colors primaryOrangeColor]CGColor];
    self.editPaymentInfoButton.layer.shadowColor=[[Colors primaryOrangeColor]CGColor];
    self.editDesiredRadiusButton.layer.shadowColor=[[Colors primaryOrangeColor]CGColor];
}

@end
