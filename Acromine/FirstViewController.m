//
//  FirstViewController.m
//  Acromine
//
//  Created by Naoki Hada on 3/23/17.
//  Copyright © 2017 Naoki Hada. All rights reserved.
//

#import "FirstViewController.h"
#import "VariationDTO.h"
#import "MBProgressHUD.h"


@interface FirstViewController ()

@end

@implementation FirstViewController{
    
    NSArray *tableData; // Table data: Array of VariationDTO
    
}

/**
 viewDidLoad handler
 */
- (void)viewDidLoad {
    DLog(@"debug marker");
    @try{
        [super viewDidLoad];
       
        [self updateSearchButtonState];
        [self setMessageData:@"Results will be appeared here"];
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Set message in table data to display

 @param message NSString *
 */
- (void)setMessageData:(NSString *)message{
    DLog(@"debug marker");
    @try{
        VariationDTO *dto = [VariationDTO new];
        dto.lf = [message copy];
        tableData = [NSArray arrayWithObjects: dto, nil];
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 didReceiveMemoryWarning handler
 */
- (void)didReceiveMemoryWarning {
    DLog(@"debug marker");
    @try{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}

#pragma mark TableView delegates

/**
 Number of rows in section

 @param tableView UITableView *
 @param section NSInteger
 @return NSInteger
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DLog(@"debug marker");
    @try{
        return [tableData count];
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Cell for row at indexPath

 @param tableView UITableView*
 @param indexPath NSIndexPath*
 @return UITableViewCell*
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"debug marker");
    @try{
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
        }
        VariationDTO *dto = (VariationDTO *)[tableData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = dto.lf;
        if(dto.since == 0 || dto.freq == 0){ // message only
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            cell.detailTextLabel.text = @"";
        }else{
            [cell.textLabel setTextColor:[UIColor blackColor]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld - %ld", dto.since, dto.freq];
        }
        return cell;
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


#pragma mark validators

/**
 Check keyword is valid for search

 @return BOOL
 */
- (BOOL)isValidKeyword {
    DLog(@"debug marker");
    BOOL result = NO;

    @try{
        if(1 < [_keywordTextField.text length]){ // 2 char or more
            result = YES;
        }
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch

    DLog(@"result = %d", result);
    return result;
}


/**
 Update seach button state
 */
- (void)updateSearchButtonState{
    DLog(@"debug marker");
    @try{
        if([self isValidKeyword]){
            [_searchButton setEnabled:YES];
            [_searchButton setBackgroundColor:[UIColor redColor]];
        }else{
            [_searchButton setEnabled:NO];
            [_searchButton setBackgroundColor:[UIColor lightGrayColor]];
        }
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


#pragma mark search

/**
 do Acromine search
 */
- (void) doAcromineSearch{
    DLog(@"debug marker");
    @try{
        NSString *keyword = _keywordTextField.text;
        NSString *encoded = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]]; // url encode
        
        NSString *url = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@", encoded];
        DLog(@"url=%@", url);
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:20.0]; // 20 sec
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:url]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES]; // show HUD
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{ // main thread
                [MBProgressHUD hideHUDForView:self.view animated:YES]; // hide HUD

                NSError *error;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                DLog(@"jsonDict=%@", jsonDict);
                
                [self processJsonDict:jsonDict]; // process and update table
            });
        }] resume]; // start URL session
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Process JSON data and update table view
 Note: Call in main thread

 @param jsonDict NSDictionary *
 */
- (void)processJsonDict:(NSDictionary *)jsonDict{
    DLog(@"debug marker");
    @try{
        NSArray *arrayLfs = [[jsonDict valueForKey:@"lfs"] firstObject];
        
        DLog(@"arrayLfs = %@",[arrayLfs description]);
        
        if(0 == [arrayLfs count]){
            [self setMessageData: @"No Result"];
            [_resultTableView reloadData];
            
        }else{
            NSMutableArray *tmpArray  = [NSMutableArray new];
            
            for (NSDictionary *dict in arrayLfs) {
                VariationDTO *dto = [VariationDTO new];
                dto.lf = (NSString *)dict[@"lf"];
                dto.since = [dict[@"since"] intValue];
                dto.freq  = [dict[@"freq"] intValue];
                [tmpArray addObject:dto];
            }
            
            tableData = [tmpArray copy];
            [_resultTableView reloadData];
        }
        
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}



#pragma mark UI actions


/**
 Keyword TextField text change handler

 @param sender id
 */
- (IBAction)keywordTextFieldEditingChanged:(id)sender {
    DLog(@"debug marker");
    @try{
        [self updateSearchButtonState]; // update search button
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 TextField return key handler

 @param sender UITextField*
 */
- (IBAction)textFieldDidEndOnExit:(UITextField *)sender { // On return
    // dismiss keyboard by this handler only
    DLog(@"debug marker");
    @try{
        [self doAcromineSearch];
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Seach button tapped handler

 @param sender id
 */
- (IBAction)seachButtonTouchUpInside:(id)sender {
    DLog(@"debug marker");
    @try{
        [self dismissKeyboard];
        [self doAcromineSearch];
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Touche Began Handler

 @param touches (NSSet *)
 @param event (UIEvent *)
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DLog(@"debug marker");
    @try{
        if (_keywordTextField.isFirstResponder) { // Keyboad is showing
            [_keywordTextField resignFirstResponder]; // Dismiss keyboard
        } else { // Keyboard is not showing
            [_keywordTextField becomeFirstResponder]; // Show keyboard
        }
    } // try
    @catch (NSException *exception) {
        DLog(@"[EXCEPTION] %@", exception);
    } // catch
}


/**
 Dismiss keyboard
 */
- (void)dismissKeyboard {
    DLog(@"debug marker");
    [self.view endEditing:YES]; // dismiss keyboard
}


@end
