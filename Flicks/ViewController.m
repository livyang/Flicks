//
//  ViewController.m
//  Flicks
//
//  Created by  Li Yang on 1/23/17.
//  Copyright © 2017 Li Yang. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "MoviePosterCollectionViewCell.h"

@interface ViewController () <UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray<MovieModel *> *movies;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.movieTableView.dataSource = self;
    
    NSLog(@"restorationIdentifier is %@", self.restorationIdentifier);
    if ([self.restorationIdentifier isEqualToString:@"Movies"]) {
        [self fetchMovies:@"now_playing"];
        
    }else if ([self.restorationIdentifier isEqualToString:@"TopMovies"]) {
        [self fetchMovies:@"top_rated"];
    }else {
        NSLog((@"Unknown restorationIdentifier"));
    }
    
//    UIBarButtonItem* rightButton = self.navigationItem.rightBarButtonItem;
//    [rightButton setImage:[[UIImage imageNamed:@"star"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
//    [self.tabBarItem setImage:[[UIImage imageNamed:@"iconmonstr-star-1-24"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    self.movieTableView.refreshControl = [[UIRefreshControl alloc]init];
    [self.movieTableView addSubview:self.movieTableView.refreshControl];
    [self.movieTableView.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat itemHight = 150;
    CGFloat itemWidth = screenWidth/3;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemWidth, itemHight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 64) collectionViewLayout:layout];
    [collectionView registerClass:[MoviePosterCollectionViewCell class] forCellWithReuseIdentifier:@"MoviePosterCollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:collectionView];
    //collectionView.hidden = YES;
    self.movieTableView.hidden = YES;
    self.movieCollectionView = collectionView;
    
    //TODO: doesn't work well
    self.movieCollectionView.refreshControl = [[UIRefreshControl alloc]init];
    [self.movieCollectionView addSubview:self.movieCollectionView.refreshControl];
    [self.movieCollectionView.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable {
    NSLog(@"restorationIdentifier is %@", self.restorationIdentifier);
    if ([self.restorationIdentifier isEqualToString:@"Movies"]) {
        [self fetchMovies:@"now_playing"];
        
    }else if ([self.restorationIdentifier isEqualToString:@"TopMovies"]) {
        [self fetchMovies:@"top_rated"];
    }else {
        NSLog((@"Unknown restorationIdentifier"));
    }
    
    [self.movieTableView.refreshControl endRefreshing];
}

-(void) fetchMovies:(NSString *) query {

    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", query, apiKey];
    NSLog(@"url string is %@", urlString);

    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                [MBProgressHUD hideHUDForView:self.view animated:true];
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    NSArray *results = responseDictionary[@"results"];
                                                    
                                                    NSMutableArray *models = [NSMutableArray array];
                                                    for (NSDictionary *result in results) {
                                                        MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
                                                        NSLog(@"Model - %@", model);
                                                        [models addObject:model];
                                                    }
                                                    self.movies = models;
                                                    [self.movieTableView reloadData];
                                                    [self.movieCollectionView reloadData];
                                                    
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    [self.view setHidden:true];
                                                    UIAlertController * alert=   [UIAlertController
                                                                                  alertControllerWithTitle:@"Network error"
                                                                                  message:[error localizedDescription]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                                    
                                                    [self presentViewController:alert animated:YES completion:nil];
                                                }
                                            }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}


- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCellId" forIndexPath:indexPath];
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    [cell.movieTitle setText:model.title];
    cell.movieImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.movieImage setImageWithURL:model.posterURL];
    [cell.movieOverview  setText:model.moviewDescription];
    
     return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.movieTableView indexPathForSelectedRow];
    NSLog(@"cell clicked %@",
          [self.movies objectAtIndex:indexPath.row].title);
    // get model
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    DetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.model = model;
    NSLog(@"detail view controller is %@", detailViewController);
    
}


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 //   [self performSegueWithIdentifier:@"ShowDetail" sender:tableView];
    MovieCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCellId" forIndexPath:indexPath];
    NSLog(@"selected movie %@ in %@ ", cell.movieTitle, self.restorationIdentifier);
}
*/



//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //[self performSegueWithIdentifier:@"showDetail" sender:self];
//    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
///*    DetailViewController *vc=(DetailViewController *)[sb instantiateViewControllerWithIdentifier:@"detail"];
//    vc.label.text =[self.peopleaddress objectAtIndex:indexPath.row];
//    vc. textfield.text =[self.peopleaddress objectAtIndex:indexPath.row];*/
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.movies.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MoviePosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviePosterCollectionViewCell" forIndexPath:indexPath];
    cell.model = [self.movies objectAtIndex:indexPath.item];
    [cell reloadData];
    
    return cell;
}




@end
