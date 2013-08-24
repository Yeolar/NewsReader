//
//  TouchedLabel.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-21.
//  Copyright 2011. All rights reserved.
//

#import "TouchedLabel.h"


@implementation TouchedLabel

@synthesize indexPath, delegate;

- (void)dealloc
{
    [indexPath release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTextColor:[UIColor blackColor]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTextColor:[UIColor blueColor]];
    
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if (point.x > 0 && point.y > 0 && point.x < self.frame.size.width && point.y < self.frame.size.height) {
        [delegate scrollToCellAtIndexPath:self.indexPath];
    }
}

@end
