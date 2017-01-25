//
//  MovieCell.h
//  Flicks
//
//  Created by  Li Yang on 1/23/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieOverview;

@end
