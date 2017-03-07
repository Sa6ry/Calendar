//
//  CalendarDataSource.h
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 3/3/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarEvent.h"

@interface CalendarDataSource : NSObject

-(instancetype ) initWithCompletion:(void (^ )(NSError  * error))completion;

-(NSInteger) getEventsCountForDay:(NSDate* ) date withCompletion:(void (^ )(NSUInteger noOfEvents))completion;
-(NSInteger) getEventsForDay:(NSDate* ) date withCompletion:(void (^ )(NSArray<CalendarEvent*> * eventsArray))completion;

-(void) pause;
-(void) resume;
@end
