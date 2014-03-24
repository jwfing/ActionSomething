//
//  AVVDetailViewController.h
//  ActionSomething
//
//  Created by Feng Junwen on 3/18/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVVDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITableView *chatHistory;
@property (weak, nonatomic) IBOutlet UITextView *inputText;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end
