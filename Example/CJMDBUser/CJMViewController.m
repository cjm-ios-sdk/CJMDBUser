//
//  CJMViewController.m
//  CJMDBUser
//
//  Created by chenjm on 04/07/2020.
//  Copyright (c) 2020 chenjm. All rights reserved.
//

#import "CJMViewController.h"
#import "CJMDBTestManager.h"

@interface CJMViewController ()

@end

@implementation CJMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CJMDBTestManager *manager = [[CJMDBTestManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
