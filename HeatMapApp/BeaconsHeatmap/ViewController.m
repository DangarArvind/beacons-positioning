//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Eleonora on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "ViewController.h"
#import "LFHeatMap.h"
#import "CBBeaconsMap.h"
#import "CBBeaconsSimulator.h"

@interface ViewController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property CBBeaconsSimulator *simulator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simulator = [CBBeaconsSimulator new];
    _simulator.delegate = self;
    
    _beaconsView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CBBeacon *b1 = [[CBBeacon alloc] initWithX:0 y:40 distance:290];
    CBBeacon *b2 = [[CBBeacon alloc] initWithX:0 y:_beaconsView.bounds.size.height - 80 distance:300];
    CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width y:_beaconsView.bounds.size.height/2 distance:270];
    CBBeacon *b4 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height distance:320];
    
    _beaconsView.beacons = @[b1, b2, b3, b4];
    
    [_simulator simulateBeacons:_beaconsView.beacons noise:0.1];
}

- (void)probabilityPointsUpdated:(NSArray *)points {
    NSMutableArray *weights = [NSMutableArray arrayWithCapacity:points.count];
    for (int i = 0; i < points.count; i++) {
        [weights addObject:[NSNumber numberWithFloat:10.0]];
    }
    UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.5 points:points weights:weights];
    _imageView.image = map;
}

-(void)beaconsDidChange {
    [_beaconsView updateBeacons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
