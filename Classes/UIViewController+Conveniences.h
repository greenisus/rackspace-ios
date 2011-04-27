//
//  UIViewController+Conveniences.h
//
//  Created by Mike Mayo on 7/21/10.
//

#import <Foundation/Foundation.h>

@class OpenStackRequest;

@interface UIViewController (Conveniences) <UIAlertViewDelegate>

- (void)alert:(NSString *)title message:(NSString *)message;
- (void)alert:(NSString *)message request:(OpenStackRequest *)request;
- (void)failOnBadConnection;

// presents a modal view controller inside of a UINavigationController
// it maintains the central navigation bar of the build
- (void)presentModalViewControllerWithNavigation:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentModalViewControllerWithNavigation:(UIViewController *)viewController;
- (void)presentPrimaryViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentPrimaryViewController:(UIViewController *)viewController;
- (void)addCancelButton;

// this requires - (void)saveButtonPressed:(id)sender to be defined
- (void)addSaveButton;

// this requires - (void)addButtonPressed:(id)sender to be defined
- (void)addAddButton;

// this requires - (void)doneButtonPressed:(id)sender to be defined
- (void)addDoneButton;

// this requires - (void)nextButtonPressed:(id)sender to be defined
- (void)addNextButton;

- (UITableViewCell *)tableView:(UITableView *)tableView emptyCellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle;
- (UITableViewCell *)tableView:(UITableView *)tableView emptyCellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle deleteButtonTitle:(NSString *)deleteButtonTitle deleteButtonSelector:(SEL)deleteButtonSelector;

@end
