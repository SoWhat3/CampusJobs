//
//  ConversationDetailViewController.m
//  CampusJobs
//
//  Created by Sophia Zheng on 7/18/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "ConversationDetailViewController.h"
#import "MessageCollectionViewCell.h"
#import "SuggestPriceViewController.h"
#import "PostDetailsViewController.h"
#import "ConversationsViewController.h"
#import "Message.h"
#import "Utils.h"
#import "Alert.h"
#import "SegueConstants.h"
#import <MaterialComponents/MaterialTextFields.h>
#import <MaterialComponents/MaterialButtons.h>
#import <MaterialComponents/MaterialAppBar.h>

@interface ConversationDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MessageCollectionViewCellDelegate, SuggestPriceDelegate, PostDetailsDelegate, UITextViewDelegate>

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) CGFloat maxCellWidth;
@property (assign, nonatomic) CGFloat maxCellHeight;
@property (assign, nonatomic) BOOL showingSuggestViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *messagesCollectionView;
@property (weak, nonatomic) IBOutlet MDCMultilineTextField *composeMessageTextField;
@property (weak, nonatomic) IBOutlet MDCFlatButton *suggestPriceButton;
@property (weak, nonatomic) IBOutlet UIView *inProgressOptionsView;
@property (weak, nonatomic) IBOutlet MDCRaisedButton *cancelJobButton;
@property (weak, nonatomic) IBOutlet MDCRaisedButton *jobCompletedButton;
@property (weak, nonatomic) IBOutlet UILabel *jobStatusProgressLabel;
@property (weak, nonatomic) IBOutlet UIStackView *inProgressButtonsStackView;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *viewPostButton;
@property (strong, nonatomic) UIBarButtonItem *flagButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet MDCFlatButton *sendMessageButton;
@property (assign, nonatomic) CGFloat bottomViewHeight;
@property (assign, nonatomic) CGFloat initialButtonHeight;
@property (strong, nonatomic) MDCAppBar *appBar;

@end

@implementation ConversationDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.user = [PFUser currentUser];
    self.messagesCollectionView.delegate = self;
    self.messagesCollectionView.dataSource = self;
    
    self.maxCellWidth = self.messagesCollectionView.frame.size.width * .6; // max message text view width
    self.maxCellHeight = self.messagesCollectionView.frame.size.height * 3; // arbitrary large max message text view height
    
    [self configureInitialView];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)reloadData {
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];
    [self configureOptions];
    [self.messagesCollectionView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self configureBottomViewShowingSuggestPriceButton:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self configureOptions];
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isEqual:self.composeMessageTextField.textView]) {
        if ([textView.text isEqualToString:@""]) {
            self.composeMessageTextField.placeholder = @"New Message...";
        } else {
            self.composeMessageTextField.placeholder = @"";
            if ([self.composeMessageTextField.text isEqualToString:@""]) {
                self.composeMessageTextField.minimumLines = 1;
            }
            
            [textView sizeToFit];
            [self.composeMessageTextField sizeToFit];
            
            CGFloat distance = self.composeMessageTextField.frame.size.height - self.bottomViewHeight;
            self.bottomViewHeight = self.composeMessageTextField.frame.size.height;
            [Utils animateView:self.bottomView withDistance:distance up:YES];
            [self configureBottomViewShowingSuggestPriceButton:NO];
        }
    }
}

#pragma mark - Initial Configurations

- (void)configureInitialView {
    [self configureRefreshControl];
    [self configureNavigatonBar];
    [self showByDelegate];
    self.showingSuggestViewController = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.composeMessageTextField.textView.delegate = self;
    self.composeMessageTextField.placeholder = @"New Message...";
    self.composeMessageTextField.minimumLines = 1;
    
    self.initialButtonHeight = 58;
    self.bottomViewHeight = self.initialButtonHeight;
    self.bottomView.frame = CGRectMake(0, self.view.frame.size.height - self.bottomViewHeight, self.view.frame.size.width, 500);
}

- (void)configureRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.messagesCollectionView insertSubview:self.refreshControl atIndex:0];
}

- (void)configureNavigatonBar {
    self.appBar = [[MDCAppBar alloc] init];
    [self addChildViewController:_appBar.headerViewController];
    [self.appBar addSubviewsToParent];
    if (![self.conversation.post.title isEqualToString:@""]) {
        self.title = [NSString stringWithFormat:@"%@ - %@", self.otherUser.username, self.conversation.post.title];
    } else {
        self.title = self.otherUser.username;
    }
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton:)];
    self.navigationItem.leftBarButtonItem = self.backButton;
    self.viewPostButton = [[UIBarButtonItem alloc] initWithTitle:@"View Post" style:UIBarButtonItemStylePlain target:self action:@selector(didTapViewPostButton:)];
    self.flagButton = [[UIBarButtonItem alloc] initWithTitle:@"Flag" style:UIBarButtonItemStylePlain target:self action:@selector(didTapViewPostButton:)];
    self.navigationItem.rightBarButtonItems = @[self.viewPostButton, self.flagButton];
    
    [Utils formatColorForAppBar:self.appBar];
    
    self.inProgressOptionsView.frame = CGRectMake(0, 75, self.view.frame.size.width, 50);
}

#pragma mark - Configurations Based on State

- (void)showByDelegate {
    if ([self.delegate isKindOfClass:[ConversationsViewController class]]) {
        [self.viewPostButton setEnabled:YES];
        self.navigationItem.rightBarButtonItems = @[self.viewPostButton, self.flagButton];
    } else {
        [self.viewPostButton setEnabled:NO];
        self.navigationItem.rightBarButtonItems = @[self.flagButton];
    }
}

- (void)configureOptions {
    // show "suggest price" button or "job in progress" bar
    if (self.conversation.post.postStatus == OPEN) {
        [self configureOpenAppearance];
    } else if (self.conversation.post.postStatus == IN_PROGRESS){
        if ([self.conversation.post.taker.objectId isEqualToString:[PFUser currentUser].objectId]) {
            // if the current user is the post's taker
            [self configureInProgressAppearance];
        } else if ([self.conversation.post.author.objectId isEqualToString:[PFUser currentUser].objectId]){
            if ([self.conversation.post.taker.objectId isEqualToString:self.otherUser.objectId]) {
                // the current user is the post's author, and the other user is the post's taker
                [self configureInProgressAppearance];
            } else {
                // the current user is the post's author, but the other user is not the taker
                [self configureNotTakerAppearance];
            }
        } else {
            // the current user is a seeker but not the taker
            [self configureNotInvolvedUserAppearance];
        }
    } else {
        [self configureClosedAppearance];
    }
}

- (void)configureOpenAppearance {
    [self configureBottomViewShowingSuggestPriceButton:YES];
    
    [self.inProgressOptionsView setHidden:YES];
    self.inProgressOptionsView.frame = CGRectMake(self.inProgressOptionsView.frame.origin.x, self.inProgressOptionsView.frame.origin.y, self.inProgressOptionsView.frame.size.width, 0);
}

- (void)configureInProgressAppearance {
    [self configureBottomViewShowingSuggestPriceButton:NO];
    
    [self.inProgressOptionsView setHidden:NO];
    self.inProgressOptionsView.frame = CGRectMake(self.inProgressOptionsView.frame.origin.x, self.inProgressOptionsView.frame.origin.y, self.inProgressOptionsView.frame.size.width, 70);
    
    [self.inProgressButtonsStackView setHidden:NO];
    
    self.jobStatusProgressLabel.text = [NSString stringWithFormat:@"This job is now in progress for $%@!", self.conversation.post.price];
    
    // show/hide job completed button, since only want post's author to state when job completed
    if ([self.user.objectId isEqualToString:self.conversation.post.author.objectId]) {
        [self.jobCompletedButton setHidden:NO];
    } else {
        [self.jobCompletedButton setHidden:YES];
    }
}

- (void)configureNotInvolvedUserAppearance {
    [self configureBottomViewShowingSuggestPriceButton:NO];
    
    [self.inProgressButtonsStackView setHidden:YES];
    
    [self.inProgressOptionsView setHidden:NO];
    self.inProgressOptionsView.frame = CGRectMake(self.inProgressOptionsView.frame.origin.x, self.inProgressOptionsView.frame.origin.y, self.inProgressOptionsView.frame.size.width, 30);
    
    self.jobStatusProgressLabel.text = @"Sorry, this job has been taken by another user!";
}

- (void)configureNotTakerAppearance {
    [self configureBottomViewShowingSuggestPriceButton:NO];
    
    [self.inProgressButtonsStackView setHidden:YES];
    
    [self.inProgressOptionsView setHidden:NO];
    self.inProgressOptionsView.frame = CGRectMake(self.inProgressOptionsView.frame.origin.x, self.inProgressOptionsView.frame.origin.y, self.inProgressOptionsView.frame.size.width, 50);
    self.jobStatusProgressLabel.frame = CGRectMake(self.jobStatusProgressLabel.frame.origin.x, self.jobStatusProgressLabel.frame.origin.y, self.jobStatusProgressLabel.frame.size.width, 50);
    
    self.jobStatusProgressLabel.text = @"This job is already in progress with another user!";
}

- (void)configureClosedAppearance {
    [self configureBottomViewShowingSuggestPriceButton:NO];
    
    [self.inProgressButtonsStackView setHidden:YES];
    
    [self.inProgressOptionsView setHidden:NO];
    self.inProgressOptionsView.frame = CGRectMake(self.inProgressOptionsView.frame.origin.x, self.inProgressOptionsView.frame.origin.y, self.inProgressOptionsView.frame.size.width, 50);
    self.jobStatusProgressLabel.frame = CGRectMake(self.jobStatusProgressLabel.frame.origin.x, self.jobStatusProgressLabel.frame.origin.y, self.jobStatusProgressLabel.frame.size.width, 50);
    
    self.jobStatusProgressLabel.text = @"This job has been completed, but feel free to keep chatting!";
}

- (void)configureBottomViewShowingSuggestPriceButton:(BOOL)showsSuggestPrice {
    
    CGFloat horizontalInset = 8;
    
    CGFloat sendMessageButtonWidth = 70;
    self.sendMessageButton.frame = CGRectMake(self.bottomView.frame.size.width - sendMessageButtonWidth, self.bottomViewHeight - self.initialButtonHeight, sendMessageButtonWidth, self.initialButtonHeight);
    
    if (showsSuggestPrice) {
        self.suggestPriceButton.hidden = NO;
        self.suggestPriceButton.frame = CGRectMake(0, self.bottomViewHeight - self.initialButtonHeight, 130, self.initialButtonHeight);
        
        CGFloat composeMessageOriginX = self.suggestPriceButton.frame.origin.x + self.suggestPriceButton.frame.size.width + horizontalInset;
        self.composeMessageTextField.textView.frame = CGRectMake(composeMessageOriginX, 0, self.sendMessageButton.frame.origin.x - composeMessageOriginX, self.bottomViewHeight);
        self.composeMessageTextField.frame = self.composeMessageTextField.textView.frame;
        
    } else {
        self.suggestPriceButton.hidden = YES;
        
        self.composeMessageTextField.textView.frame = CGRectMake(horizontalInset, 0, self.sendMessageButton.frame.origin.x - horizontalInset, self.bottomViewHeight);
        self.composeMessageTextField.frame = self.composeMessageTextField.textView.frame;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.showingSuggestViewController) {
        [Utils animateView:self.bottomView withDistance:[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height up:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.showingSuggestViewController) {
        [Utils animateView:self.bottomView withDistance:[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height up:NO];
    }
}

#pragma mark - IBAction

- (IBAction)didTapAway:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)didTapBackButton:(id)sender {
    if (self.conversation.messages.count == 0) {
        [self.conversation deleteInBackgroundWithBlock:^(BOOL didDeleteConversation, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)didTapViewPostButton:(id)sender {
    [self performSegueWithIdentifier:messagesToPostDetailsSegue sender:nil];
}

- (IBAction)didTapSendMessage:(id)sender {
    if (![self.composeMessageTextField.text isEqualToString:@""]) {
        __unsafe_unretained typeof(self) weakSelf = self;
        [self.conversation addToConversationWithMessageText:self.composeMessageTextField.text withSender:self.user withReceiver:self.otherUser withCompletion:^(BOOL didSendMessage, NSError *error) {
            if (didSendMessage) {
                weakSelf.composeMessageTextField.text = @"";
                [weakSelf.messagesCollectionView reloadData];
            } else {
                [Alert callAlertWithTitle:@"Error sending message" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:weakSelf];
            }
        }];
    }
}

- (IBAction)didTapSuggestPriceButton:(id)sender {
    self.showingSuggestViewController = YES;
    [self performSegueWithIdentifier:messagesToSuggestPriceSegue sender:nil];
}

- (IBAction)didTapCancelJobButton:(id)sender {
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.conversation.post cancelJobWithConversation:self.conversation withCompletion:^(BOOL didCancelJob, NSError *error) {
        if (didCancelJob) {
            [weakSelf reloadData];
        } else {
            [Alert callAlertWithTitle:@"Error Cancelling Job" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:weakSelf];
        }
    }];
}

- (IBAction)didTapJobCompletedButton:(id)sender {
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.conversation.post completeJobWithCompletion:^(BOOL didUpdateJob, NSError *error) {
        if (didUpdateJob) {
            [weakSelf.conversation addToConversationWithSystemMessageWithText:[NSString stringWithFormat:@"%@ indicated that the job has been completed, and payment is on the way!", [PFUser currentUser].username] withSender:[PFUser currentUser] withReceiver:weakSelf.otherUser withCompletion:^(BOOL didSendMessage, NSError *error) {
                if (didSendMessage) {
                    [weakSelf reloadData];
                } else {
                    [Alert callAlertWithTitle:@"Something's wrong!" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:(UIViewController *)weakSelf];
                }
            }];
        } else {
            [Alert callAlertWithTitle:@"Error Registering Job as Complete" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:weakSelf];
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.conversation.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    [cell configureCellWithMessage:self.conversation.messages[indexPath.item] withConversation:self.conversation withMaxWidth:self.maxCellWidth withMaxHeight:self.maxCellHeight withViewWidth:self.messagesCollectionView.frame.size.width];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = self.conversation.messages[indexPath.item];
    NSString *messageText = message[@"text"];
    
    // estimate frame size based on message text
    CGSize boundedSize = CGSizeMake(self.maxCellWidth, self.maxCellHeight);
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGRect estimatedFrame = [messageText boundingRectWithSize:boundedSize options:options attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    
    // show/hide the accept/decline suggested price buttons
    CGFloat buttonsStackViewAllowance = 0;
    if (self.conversation.post.postStatus == OPEN && message[@"suggestedPrice"] && ![message.sender.objectId isEqualToString:[PFUser currentUser].objectId]) {
        buttonsStackViewAllowance = 40;
    }
    
    return CGSizeMake(collectionView.frame.size.width, ceil(estimatedFrame.size.height) + 20 + buttonsStackViewAllowance);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:messagesToSuggestPriceSegue]) {
        SuggestPriceViewController *suggestPriceController = [segue destinationViewController];
        suggestPriceController.delegate = self;
        suggestPriceController.conversation = self.conversation;
        suggestPriceController.otherUser = self.otherUser;
    } else if ([segue.identifier isEqualToString:messagesToPostDetailsSegue]) {
        PostDetailsViewController *postDetailsController = [segue destinationViewController];
        postDetailsController.post = self.conversation.post;
        postDetailsController.delegate = self;
    }
}

@end
