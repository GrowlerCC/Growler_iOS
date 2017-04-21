//
//  MasterViewController.m
//  Growler
//
//  Created by Shopify.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Buy/BUYClient.h>
#import "Credentials.h"
#import "ProductListViewController.h"
#import "ProductViewController.h"
#import "Theme.h"
#import "ShippingRatesTableViewController.h"
#import "Growler-Swift.h"
#import "AsyncImageView.h"

#import <Buy/Buy.h>
#import <Buy/BUYClient+Storefront.h>

@interface ProductListViewController () /*<UIViewControllerPreviewingDelegate>*/

@property (nonatomic, strong) BUYClient *client;
@property (nonatomic, strong) BUYCollection *collection;
@property (nonatomic, strong) NSOperation *collectionOperation;

@end

@implementation ProductListViewController

@synthesize products = _products;

- (instancetype)initWithClient:(BUYClient *)client collection:(BUYCollection*)collection
{
    NSParameterAssert(client);
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.client = client;
        self.collection = collection;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.collection) {
    } else {
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    UINib *nib = [UINib nibWithNibName:@"ProductListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ProductListCell"];

    if (self.collection) {
        // If we're presenting with a collection, add the ability to sort
        UIBarButtonItem *sortBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(presentCollectionSortOptions:)];
        self.navigationItem.rightBarButtonItem = sortBarButtonItem;
    }

    [self loadProducts];
}

- (void) loadProducts {
    if (self.collection) {
        [self getCollectionWithSortOrder:BUYCollectionSortCollectionDefault];
    } else if (self.tags) {
        [self getCollectionByTags];
    } else {
        // todo implement loading all pages as user scrolls UITableView
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.client getProductsPage:1 completion:^(NSArray *products, NSUInteger page, BOOL reachedEnd, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error == nil && products) {
                self.products = [self filterProducts:products];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error fetching products: %@", error);
            }
        }];
    }
}

- (NSArray *)filterProducts:(NSArray *)products {
    if (self.minPrice == nil && self.maxPrice == nil && self.searchKeyword == nil) {
        return products;
    }
    NSString *searchKeywordLowerCase = self.searchKeyword == nil || self.searchKeyword.length == 0 ? nil : [self.searchKeyword lowercaseString];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:products.count];
    for (NSUInteger i = 0; i < products.count; i++) {
        BUYProduct *product = products[i];
        NSDecimalNumber *price = product.minimumPrice;
        if (price == nil) {
            continue;
        }
        if (self.minPrice != nil && [price compare:self.minPrice] < 0) {
            continue;
        }
        if (self.maxPrice != nil && [price compare:self.maxPrice] > 0) {
            continue;
        }
        if (searchKeywordLowerCase != nil && ![self product:product matchesKeyword:searchKeywordLowerCase]) {
            continue;
        }
        [result addObject:product];
    }
    return result;
}

- (BOOL)product:(BUYProduct *)product matchesKeyword:(NSString *)keyword {
    NSString *title = [product.title lowercaseString];
    NSString *description = [product.title lowercaseString];
    return [title rangeOfString:keyword].location != NSNotFound || [description rangeOfString:keyword].location != NSNotFound;
}

- (void)dealloc
{
    [self.collectionOperation cancel];
}

- (void)presentCollectionSortOptions:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Collection Sort" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortCollectionDefault];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Best Selling" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortBestSelling];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Title - Ascending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortTitleAscending];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Title - Descending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortTitleDescending];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Price - Ascending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortPriceAscending];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Price - Descending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortPriceDescending];
    }]];
    
    /*  Note: The BUYCollectionSortCreatedAscending and BUYCollectionSortCreatedDescending are currently not support
    [alertController addAction:[UIAlertAction actionWithTitle:@"BUYCollectionSortCreatedAscending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortCreatedAscending];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"BUYCollectionSortCreatedDescending" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getCollectionWithSortOrder:BUYCollectionSortCreatedDescending];
    }]];
     */
    
    if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.barButtonItem = (UIBarButtonItem*)sender;
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)getCollectionWithSortOrder:(BUYCollectionSort)collectionSort
{
    [self.collectionOperation cancel];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.collectionOperation = [self.client getProductsPage:1 inCollection:self.collection.identifier withTags:nil sortOrder:collectionSort completion:^(NSArray *products, NSUInteger page, BOOL reachedEnd, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error == nil && products) {
            self.products = [self filterProducts:products];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error fetching products: %@", error);
        }
    }];
}

- (void)getCollectionByTags
{
    [self.collectionOperation cancel];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    id collectionId = self.collection == nil ? @0 : self.collection.identifier; // cannot pass nil to API, instead empty string should be passed

    self.collectionOperation = [self.client
            getProductsByTags:self.tags
                         page:1
                 completion:^(NSArray * _Nullable products, NSError * _Nullable error) {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     if (error == nil && products) {
                         self.products = [self filterProducts:products];
                         [self.tableView reloadData];
                     } else {
                         NSLog(@"Error fetching products: %@", error);
                     }
                 }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductListCell" forIndexPath:indexPath];
    BUYProduct *product = self.products[indexPath.row];
    [cell setupWithProduct:product];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ProductListCell.HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BUYProduct *product = self.products[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self demoProductViewControllerWithProduct:product];
}

- (void)demoProductViewControllerWithProduct:(BUYProduct*)product
{
    ProductViewController *productViewController = [self productViewController];
    [productViewController loadWithProduct:product completion:^(BOOL success, NSError *error) {
        if (error == nil) {
            [self.navigationController pushViewController:productViewController animated:YES];

        }
    }];
}

-(ProductViewController*)productViewController
{
    ProductViewController *productViewController = [[ProductViewController alloc] initWithClient:self.client];
    productViewController.merchantId = MERCHANT_ID;
    return productViewController;
}

#pragma mark - UIViewControllerPreviewingDelegate
/*

-(UIViewController*)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        return nil;
    }
    
    BUYProduct *product = self.products[indexPath.row];
    ProductViewController *productViewController = [self productViewController];
    [productViewController loadWithProduct:product completion:NULL];
    
    previewingContext.sourceRect = cell.frame;
    
    return productViewController;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self presentViewController:viewControllerToCommit animated:YES completion:NULL];
}
*/

@end
