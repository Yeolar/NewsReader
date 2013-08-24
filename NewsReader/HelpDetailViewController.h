//
//  HelpDetailViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-8-11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpDetailViewController : UIViewController {
    UIWebView *webView;
    NSString *htmlFileName;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *htmlFileName;

@end
