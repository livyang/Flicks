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

@interface ViewController () <UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray<MovieModel *> *movies;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<MovieModel *> *filteredMovies;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.movieTableView.frame = self.view.bounds;
    self.movieCollectionView.frame = self.view.bounds;
    
    self.movieTableView.dataSource = self;
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    
    NSLog(@"restorationIdentifier is %@", self.restorationIdentifier);
    if ([self.restorationIdentifier isEqualToString:@"Movies"]) {
        [self fetchMovies:@"now_playing"];
        
    }else if ([self.restorationIdentifier isEqualToString:@"TopMovies"]) {
        [self fetchMovies:@"top_rated"];
    }else {
        NSLog((@"Unknown restorationIdentifier"));
    }
        
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
    collectionView.hidden = YES;
    self.movieCollectionView = collectionView;
    
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
    [self.movieCollectionView.refreshControl endRefreshing];
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
    if ([self.filteredMovies count] != 0  ) {
        return self.filteredMovies.count;
    }
    return self.movies.count;
}


- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *movieArray;
    if ([self.filteredMovies count] != 0  ) {
        movieArray = self.filteredMovies;
    }else {
        movieArray = self.movies;
    }
    MovieCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCellId" forIndexPath:indexPath];
    MovieModel *model = [movieArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor orangeColor];
    [cell.movieTitle setText:model.title];
    cell.movieImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.movieImage setImageWithURL:model.posterURL];
    [cell.movieOverview  setText:model.moviewDescription];
    
     return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MovieModel *model;
    if ([sender isKindOfClass:[MovieCell class]]) {
        NSIndexPath *indexPath = [self.movieTableView indexPathForSelectedRow];
        NSLog(@"cell clicked %@",
          [self.movies objectAtIndex:indexPath.row].title);
        // get model
        model = [self.movies objectAtIndex:indexPath.row];
    
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.model = model;
        NSLog(@"detail view controller is %@", detailViewController);
    } else {
        NSLog(@"sender is %@", sender);
        model = sender;
    }
    DetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.model = model;
    NSLog(@"detail view controller is %@", detailViewController);
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.filteredMovies count] != 0  ) {
        return self.filteredMovies.count;
    }
    return self.movies.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *movieArray;
    if ([self.filteredMovies count] != 0  ) {
        movieArray = self.filteredMovies;
    }else {
        movieArray = self.movies;
    }
    MoviePosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviePosterCollectionViewCell" forIndexPath:indexPath];
    cell.model = [movieArray objectAtIndex:indexPath.item];
    [cell reloadData];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    TODO
//    self performSegueWithIdentifier:@"showDetail" sender:<#(nullable id)#>
    
    MovieModel *model = [self.movies objectAtIndex:indexPath.item];
//    DetailViewController *detailViewController =
//    [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
//    detailViewController.model = model;
    
    [self performSegueWithIdentifier:@"showDetail" sender:model];
}


- (IBAction)segmentSelected:(id)sender {
    NSInteger segmentIndex = [self.segControl selectedSegmentIndex];
    NSLog(@"selected segment: %ld", (long)segmentIndex);
    if(segmentIndex == 0)
    {
        // action for the first button (Current or Default)
        self.movieCollectionView.hidden = YES;
        self.movieTableView.hidden = NO;
    }
    else if(segmentIndex == 1)
    {
        // action for the second button
        self.movieCollectionView.hidden = NO;
        self.movieTableView.hidden = YES;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *filteredMovies = [NSMutableArray array];
    if (searchText.length != 0) {
        self.filteredMovies = nil;
   
        NSLog(@"search text is %@", searchText);
        
        for (MovieModel *model in self.movies) {
            NSRange range = [model.title rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [filteredMovies addObject:model];
            }
        }
        self.filteredMovies = filteredMovies;
    }
    [self.movieTableView reloadData];
    [self.movieCollectionView reloadData];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


@end
