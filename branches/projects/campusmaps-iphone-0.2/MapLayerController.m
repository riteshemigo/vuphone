//
//  MapLayerController.m
//  CampusMaps
//
//  Created by Ben Wibking on 10/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObjectContext-Convenience.h"
#import "MapLayerController.h"
#import "POI.h"

@implementation MapLayerController

- (id)initWithLayer:(Layer *)aLayer andMapView:(MKMapView *)aMapView
{
	if (self = [super init]) {
		layer = [aLayer retain];
		mapView = [aMapView retain];
		filteredPOIs = nil;
		
		// Register for notification to update annotations when the MOC is changed
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contextSaved:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:nil];
	}

	return self;
}

- (void)addAnnotationsToMapView {
	NSEnumerator *enumerator = (self.filteredPOIs) ? [self.filteredPOIs objectEnumerator] : [layer.POIs objectEnumerator];
	POI* point;
	
	while (point = [enumerator nextObject]) {
		[mapView addAnnotation:point];
	}
}

- (void)removeAnnotationsFromMapView {
	NSEnumerator *enumerator = (self.filteredPOIs) ? [self.filteredPOIs objectEnumerator] : [layer.POIs objectEnumerator];
	POI* point;
	
	while (point = [enumerator nextObject]) {
		[mapView removeAnnotation:point];
	}
}

- (void)setPredicate:(NSPredicate *)pred forContext:(NSManagedObjectContext *)context
{
	[self removeAnnotationsFromMapView];
	
	if (pred) {
		NSPredicate *layerPredicate = [NSPredicate predicateWithFormat:@"layer = %@", layer];
		NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
											 [NSArray arrayWithObjects:pred, layerPredicate, nil]];
		self.filteredPOIs = [context fetchObjectsForEntityName:ENTITY_NAME_POI
												 withPredicate:andPredicate];
	} else {
		self.filteredPOIs = nil;
	}
	
	[self addAnnotationsToMapView];
}

- (void)contextSaved:(NSNotification *)notification
{
	// Handle inserted objects
	NSSet *insertedObjects = [[notification userInfo] valueForKey:NSInsertedObjectsKey];
	for (NSManagedObject *obj in insertedObjects)
	{
		if ([[[obj entity] name] isEqualToString:ENTITY_NAME_POI]) {
			if (((POI *)obj).layer == layer) {
				// This POI was inserted into this layer
				[mapView addAnnotation:(id<MKAnnotation>)obj];
			}
		}
	}

	// Handle updated objects
	NSSet *updatedObjects = [[notification userInfo] valueForKey:NSUpdatedObjectsKey];
	for (NSManagedObject *obj in updatedObjects)
	{
		if ([[[obj entity] name] isEqualToString:ENTITY_NAME_POI]) {
			if (((POI *)obj).layer == layer) {
				// This POI was updated in this layer
				[mapView removeAnnotation:(id<MKAnnotation>)obj];
				[mapView addAnnotation:(id<MKAnnotation>)obj];
			}
		}
	}

	// Handle deleted objects
	NSSet *deletedObjects = [[notification userInfo] valueForKey:NSDeletedObjectsKey];
	for (NSManagedObject *obj in deletedObjects)
	{
		if ([[[obj entity] name] isEqualToString:ENTITY_NAME_POI]) {
			if (((POI *)obj).layer == layer) {
				// This POI was deleted from this layer
				[mapView removeAnnotation:(id<MKAnnotation>)obj];
			}
		}
	}
}

- (void)dealloc {
	[layer release];
	[mapView release];
	[super dealloc];
}

@synthesize filteredPOIs;

@end
