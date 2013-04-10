//
//  ViewController.m
//  DPlibrary_Bee
//
//  Created by apple on 13-4-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleUISignal:(BeeUISignal *)signal {
    if ([signal is:[BeeUIBoard CREATE_VIEWS]]) {
        [self.view setBackgroundColor:[UIColor redColor]];
    }
}

@end
