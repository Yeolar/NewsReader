//
//  TouchedLabel.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-21.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TouchedLabelDelegate;

@interface TouchedLabel : UILabel {
    NSIndexPath *indexPath;
    id <TouchedLabelDelegate> delegate;
}

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) id <TouchedLabelDelegate> delegate;

@end

@protocol TouchedLabelDelegate <NSObject>

- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath;

@end
