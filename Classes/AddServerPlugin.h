//
//  AddServerPlugin.h
//  OpenStack
//
//  Created by Mike Mayo on 10/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class Server;

@protocol AddServerPlugin

- (void)pluginWillAppear;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (void)configureServer:(Server **)server;
- (BOOL)pluginShouldAppear;

//- (void)setNavigationController:(UINavigationController *)navigationController;

@end
