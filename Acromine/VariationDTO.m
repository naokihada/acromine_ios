//
//  VariationDTO.m
//  
//
//  Created by Naoki Hada on 3/23/17.
//
//

#import "VariationDTO.h"

@implementation VariationDTO


- (id)initWithData:(NSString*)lf freq:(NSInteger)freq since:(NSInteger)since {
    DLog(@"debug marker");
    
    self = [super init];
    if(self){
        self.lf = [lf copy];
        self.freq  = freq;
        self.since = since;
    }
    return self;
}



@end
