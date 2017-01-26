//
//  MoviePosterCollectionViewCell.h
//  Flicks
//
//  Created by  Li Yang on 1/26/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieModel.h"

@interface MoviePosterCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MovieModel *model;

- (void) reloadData;

@end
