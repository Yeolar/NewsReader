//
//  Common.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-19.
//  Copyright 2011. All rights reserved.
//

// screen window size: can be get from [UIScreen mainScreen].bounds.size, default to (320, 480)
//
#define WIN_WIDTH               ([UIScreen mainScreen].bounds.size.width)
#define WIN_HEIGHT              ([UIScreen mainScreen].bounds.size.height)

// application size: can be get from [UIScreen mainScreen].applicationFrame.size, default to (320, 460)
//
#define APP_WIDTH               ([UIScreen mainScreen].applicationFrame.size.width)
#define APP_HEIGHT              ([UIScreen mainScreen].applicationFrame.size.height)

// navigation size: can be get from self.navigationController.navigationBar.frame.size, default to (320, 44)
//
#define NAV_WIDTH               APP_WIDTH
#define NAV_HEIGHT              44
#define NAV_HEIGHT_IPHONE_LA    32

// toolbar size
//
#define TBR_WIDTH               APP_WIDTH
#define TBR_HEIGHT              40 //49
#define TBR_HEIGHT_IPHONE_LA    30 //35

// news image size
//
#define NEWS_IMG_WIDTH          60
#define NEWS_IMG_HEIGHT         60
#define HEAD_NEWS_IMG_WIDTH     300
#define HEAD_NEWS_IMG_HEIGHT    150

// subscribe button size
//
#define SUBS_BTN_WIDTH          65
#define SUBS_BTN_HEIGHT         30

// font size
//
#define TITLE_FSIZE             16
#define DESC_FSIZE              14
#define BUTTON_FSIZE            16

// color
//
#define NAV_BAR_BGCOLOR         [UIColor colorWithRed:139.0/255.0 green:        0.0 blue:  3.0/255.0 alpha:1.0]
#define TOOLBAR_BGCOLOR         [UIColor colorWithRed:139.0/255.0 green:        0.0 blue:  3.0/255.0 alpha:0.0]
#define SUBS_BUTTON_BGCOLOR     NAV_BAR_BGCOLOR
#define SUBS_BUTTON_BGCOLOR_L   [UIColor colorWithRed:205.0/255.0 green:147.0/255.0 blue:149.0/255.0 alpha:1.0]
#define SUBS_BUTTON_BGCOLOR_B   [UIColor colorWithRed: 65.0/255.0 green:        0.0 blue:        0.0 alpha:1.0]
#define ROOT_BUTTON_BGCOLOR     [UIColor colorWithRed:        1.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]
