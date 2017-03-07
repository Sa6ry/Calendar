//
//  CalendarCollectionViewLayoutAttributes.h
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/26/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CalendarCellBackgroundLight,
    CalendarCellBackgroundDark,
} CalendarCellBackgroundStyle;

@interface CalendarCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSCalendar* calendar;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) NSUInteger noOfEvents;

@property (nonatomic,readonly) CalendarCellBackgroundStyle backgroundStyle;
@property (nonatomic,readonly) NSUInteger day;
@property (nonatomic,readonly) BOOL isToday;
@end
