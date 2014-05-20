//
//  ExampleViewVC.m
//  SignatureView
//
//  Created by Michal Konturek on 05/05/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "ExampleViewVC.h"

#import "SignatureView.h"

@implementation ExampleViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.signatureView setLineWidth:2.0];
    self.signatureView.foregroundLineColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1.000];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
