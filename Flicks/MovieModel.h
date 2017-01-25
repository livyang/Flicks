//
//  NovieModel.h
//  Flicks
//
//  Created by  Li Yang on 1/23/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

- (instancetype) initWithDictionary: (NSDictionary *) otherDictionary ;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *moviewDescription;
@property (nonatomic, strong) NSURL *posterURL;

@end
