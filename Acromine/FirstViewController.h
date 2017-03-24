//
//  FirstViewController.h
//  Acromine
//
//  Created by Naoki Hada on 3/23/17.
//  Copyright © 2017 Naoki Hada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@end

