//
//  MoviePosterCollectionViewCell.m
//  Flicks
//
//  Created by  Li Yang on 1/26/17.
//  Copyright © 2017 Li Yang. All rights reserved.


#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MoviePosterCollectionViewCell ()
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation MoviePosterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

-(void)reloadData
{
    // assumes model is set
    [self.imageView setImageWithURL:self.model.posterURL];
    //make sure "layoutSubviews" is called
    [self setNeedsLayout];
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    
}

@end
