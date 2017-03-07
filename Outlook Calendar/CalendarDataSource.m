//
//  CalendarDataSource.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 3/3/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalendarDataSource.h"
#import <EventKit/EventKit.h>
#import "NSCalendar+Alignment.h"

@interface CalendarDataSource()
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, assign) BOOL eventsAccessGranted;
@property (nonatomic, strong) dispatch_queue_t eventQueue;
@property (nonatomic,strong) NSMutableDictionary<NSDate*, NSNumber*> *noOfEventsInDateCache;
@property (nonatomic,assign) BOOL isPaused;
@end


@implementation CalendarDataSource

-(instancetype) initWithCompletion:(void (^ __nullable)(NSError *error))completion {
    self = [super init];
    if(self) {
        
        self.eventQueue = dispatch_queue_create("com.unique.eventqueue.queue", DISPATCH_QUEUE_SERIAL);
        self.eventStore = [[EKEventStore alloc] init];
        self.noOfEventsInDateCache = [NSMutableDictionary dictionary];
        [self requestAccessToEventsWithCompletion:completion];
    }
    return self;
}

-(void)requestAccessToEventsWithCompletion:(void (^ __nullable)(NSError *error))completion{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error == nil) {
            // Store the returned granted value.
            self.eventsAccessGranted = granted;
        }
        else{
            // In case of error, just log its description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

-(NSInteger) getEventsForDay:(NSDate*) date withCompletion:(void (^ __nullable)(NSArray<CalendarEvent*> *))completion {
    dispatch_async(self.eventQueue, ^{
        NSArray<CalendarEvent*> * events = [self getEventsForDay:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion(events);
            }
        });
    });
    return self.noOfEventsInDateCache[date].integerValue;
}

-(NSArray<CalendarEvent*> * ) getEventsForDay:(NSDate*) date {

    // Create the predicate from the event store's instance method
    NSDate* startDay = [[NSCalendar currentCalendar] alignToStartOfDay:date];
    NSDate* endDay = [[NSCalendar currentCalendar] alignToEndOfDay:date];
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDay
                                                            endDate:endDay
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSMutableArray<CalendarEvent*> * res = [NSMutableArray array];
    NSArray* temp = [self.eventStore eventsMatchingPredicate:predicate];
    [temp enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [res addObject: [[CalendarEvent alloc] initWithEKEvent:obj]];
    }];
    return res;
}

-(NSInteger) getEventsCountForDay:(NSDate*) date withCompletion:(void (^ __nullable)(NSUInteger noOfEvents))completion {
    dispatch_async(self.eventQueue, ^{
        NSUInteger noOfEvents = [self getEventsCountForDay:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.noOfEventsInDateCache[date] = @(noOfEvents);
            if(completion) {
                completion(noOfEvents);
            }
        });
    });
    return self.noOfEventsInDateCache[date].integerValue;
}

-(NSUInteger) getEventsCountForDay:(NSDate*) date {

    NSDate* startDay = [[NSCalendar currentCalendar] alignToStartOfDay:date];
    NSDate* endDay = [[NSCalendar currentCalendar] alignToEndOfDay:date];
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDay
                                                                      endDate:endDay
                                                                    calendars:nil];
    
    return [self.eventStore eventsMatchingPredicate:predicate].count;
}

-(void) pause {
    if(self.isPaused == false) {
        dispatch_suspend(self.eventQueue);
        self.isPaused = true;
    }
}

-(void) resume {
    if(self.isPaused == true) {
        dispatch_resume(self.eventQueue);
        self.isPaused = false;
    }
}

@end
