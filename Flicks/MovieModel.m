//
//  NovieModel.m
//  Flicks
//
//  Created by  Li Yang on 1/23/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (instancetype) initWithDictionary: (NSDictionary *) dictionary {
    
    self = [super init];
    if (self) {
        self.title = dictionary[@"original_title"];
        self.moviewDescription = dictionary[@"overview"];
        NSString *urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@",dictionary[@"poster_path"]];
        self.posterURL = [NSURL URLWithString:urlString];
    }
    return self;
}

- (NSString *)description
{
//    return [NSString stringWithFormat:@"{title->%@, moviewDescription->%@, posterURL->%@ ", self.title, self.moviewDescription, self.posterURL];
    return [NSString stringWithFormat:@"{title->%@", self.title];
}

@end
