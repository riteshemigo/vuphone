//
//  POIViewController.h
//  CampusMaps
//
//  Created by Demetri Miller on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POI.h"

@interface POIViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	POI *poi;
}

@property (retain) POI *poi;
@end
