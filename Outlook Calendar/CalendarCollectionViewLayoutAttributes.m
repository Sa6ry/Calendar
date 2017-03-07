//
//  CalendarCollectionViewLayoutAttributes.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/26/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalendarCollectionViewLayoutAttributes.h"

@implementation CalendarCollectionViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CalendarCollectionViewLayoutAttributes* copy = [super copyWithZone:zone];
    copy.date = self.date;
    copy.calendar = self.calendar;
    copy.isSelected = self.isSelected;
    copy.noOfEvents = self.noOfEvents;
    return copy;
}

-(NSUInteger) day {
    return [self.calendar component:NSCalendarUnitDay fromDate:self.date];
}

-(CalendarCellBackgroundStyle) backgroundStyle {
    
    return ([self.calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self.date] % 2) ? CalendarCellBackgroundLight : CalendarCellBackgroundDark;
}

-(BOOL) isToday {
    
    NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    NSDateComponents* comp1 = [self.calendar components:unitFlags fromDate:self.date];
    NSDateComponents* comp2 = [self.calendar components:unitFlags fromDate:[NSDate date]];
    return [comp1 day]   == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

@end
