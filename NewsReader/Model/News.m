//
//  News.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright (c) 2011. All rights reserved.
//

#import "News.h"

@implementation NewsObject

@synthesize title;
@synthesize date;
@synthesize link;
@synthesize desc;
@synthesize imgurl;
@synthesize feedid;
@synthesize channel;
@synthesize type;

- (void)dealloc
{
    [title release];
    [date release];
    [link release];
    [desc release];
    [imgurl release];
    [channel release];
    [type release];
    
    [super dealloc];
}

@end

@implementation News

@dynamic title;
@dynamic date;
@dynamic link;
@dynamic desc;
@dynamic imgurl;
@dynamic feedid;
@dynamic channel;
@dynamic type;

@end
