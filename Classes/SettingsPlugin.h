//
//  SettingsPlugin.h
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class SettingsViewController;

@protocol SettingsPlugin

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setSettingsViewController:(SettingsViewController *)settingsViewController;
- (void)setNavigationController:(UINavigationController *)navigationController;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

@end
