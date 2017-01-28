//
//  DetailViewController.m
//  Flicks
//
//  Created by  Li Yang on 1/24/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import "DetailViewController.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *movieOverview;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView.contentSize =
    CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height * 3);
    
    //set background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [backgroundImage setImageWithURL:self.model.posterURL];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage.image]];
    [self.view addSubview:backgroundImage];
    
    [self.view bringSubviewToFront:self.scrollView];
    
    //set Label
    self.movieOverview.backgroundColor = [UIColor blackColor];
    self.movieOverview.textColor = [UIColor whiteColor];

    UIFont *font1 = [UIFont boldSystemFontOfSize:18.0];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n\n",self.model.title] attributes: arialDict];
    
    UIFont *font2 = [UIFont systemFontOfSize:14.0];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n",self.model.moviewDescription] attributes: arialDict2];
    
    
    [aAttrString1 appendAttributedString:aAttrString2];

    
    self.movieOverview.attributedText = aAttrString1;
    
//    self.movieOverview.text = desc;
    [self.movieOverview sizeToFit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
