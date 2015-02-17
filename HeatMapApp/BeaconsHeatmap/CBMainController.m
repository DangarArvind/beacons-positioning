//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Eleonora on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBMainController.h"
#import "LFHeatMap.h"
#import "CBBeaconsMap.h"
#import "CBBeaconsSimulator.h"
#import "CBSettingsViewController.h"
#import "CBBeaconsRanger.h"

const float kRoomWidth = 3.5;
const float kRoomHeight = 5.5;

static NSString *kBeaconsFilename = @"beacons.plist";

@interface CBMainController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate, CBBeaconsRangerDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;

@property CBBeaconsSimulator *simulator;
@property CBBeaconsRanger *ranger;

@end

@implementation CBMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simulator = [CBBeaconsSimulator new];
    _simulator.delegate = self;
    
    _ranger = [CBBeaconsRanger new];
    _ranger.delegate = self;
    
    _beaconsView.physicalSize = [self roomSize];
    _beaconsView.delegate = self;
}

- (CGSize)roomSize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSNumber *width = [defaults objectForKey:@"room_width"];
    NSNumber *height = [defaults objectForKey:@"room_height"];
    
    if (!width && !height) {
        [defaults setObject:[NSNumber numberWithFloat:kRoomWidth] forKey:@"room_width"];
        [defaults setObject:[NSNumber numberWithFloat:kRoomHeight] forKey:@"room_height"];
        [defaults synchronize];
    }
    
    width = [defaults objectForKey:@"room_width"];
    height = [defaults objectForKey:@"room_height"];
    
    NSAssert(width != 0, @"room width can't be zero");
    NSAssert(height != 0, @"room height can't be zero");

    return CGSizeMake([width floatValue], [height floatValue]);
}

- (IBAction)changeSimulation:(UIBarButtonItem *)sender {
    if ([sender.title hasPrefix:@"Start"]) {
        [sender setTitle:@"Stop Simulation"];
        [_simulator simulateBeacons:_beaconsView.beacons noise:0.05];
    } else {
        [sender setTitle:@"Start Simulation"];
        [_simulator stopSimulation];
    }
}

- (IBAction)changeRanging:(UIBarButtonItem *)sender {
    if ([sender.title hasPrefix:@"Start"]) {
        [sender setTitle:@"Stop Ranging"];
        [_ranger startRanging];
    } else {
        [sender setTitle:@"Start Ranging"];
        [_ranger stopRanging];
    }
}

- (IBAction)dismissViewController:(UIStoryboardSegue *)segue {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CBSettingsViewController *settingsVC = (CBSettingsViewController *)segue.sourceViewController;
    [settingsVC save];
    
    // update room size
    _beaconsView.physicalSize = [self roomSize];
    [_beaconsView updateBeacons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];

    NSArray *savedBeacons = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename]];
    if (savedBeacons) {
        _beaconsView.beacons = savedBeacons;
    } else {
        CBBeacon *b0 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width - 20 y:_beaconsView.bounds.size.height/3 distance:2.0];
        b0.name = @"6131";
        CBBeacon *b1 = [[CBBeacon alloc] initWithX:20 y:_beaconsView.bounds.size.height*0.5 distance:2.4];
        b1.name = @"6132";
        CBBeacon *b2 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width/2 y:_beaconsView.bounds.size.height - 20 distance:2.0];
        b2.name = @"6133";
        CBBeacon *b3 = [[CBBeacon alloc] initWithX:_beaconsView.bounds.size.width - 20 y:_beaconsView.bounds.size.height/2 distance:2.3];
        b3.name = @"6134";
        
        _beaconsView.beacons = @[b0, b1, b2, b3];
    }
}

// Delegates

- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)beacons {
    for (CBBeacon *beaconView in _beaconsView.beacons) {
        for (CLBeacon *beacon in beacons) {
            if (beaconView.name == nil || [beaconView.name isEqualToString:[beacon.minor stringValue]]) { // in case it's empty assign the first empty
                beaconView.name = [beacon.minor stringValue];
                beaconView.distance = (float)beacon.accuracy;
            }
        }

        [_beaconsView updateBeacons];
    }
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap probabilityPointsUpdated:(NSArray *)points {
//    NSMutableArray *weights = [NSMutableArray arrayWithCapacity:points.count];
//    for (int i = 0; i < points.count; i++) {
//        [weights addObject:[NSNumber numberWithFloat:10.0]];
//    }
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *map = [LFHeatMap heatMapWithRect:_imageView.bounds boost:0.6 points:points weights:weights];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _imageView.image = map;
//        });
//    });
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:beacons];
    [data writeToFile:[docDirectory stringByAppendingPathComponent:kBeaconsFilename] atomically:YES];
}

-(void)beaconSimulatorDidChange:(CBBeaconsSimulator *)simulator {
    [_beaconsView updateBeacons];
}

@end
