//
//  CalenderCollectionViewDynamicLayout.h
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/25/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    CalenderCollectionMonth = 0,
    CalenderCollectionWeek,
} CalenderCollectionStyle;

@interface CalenderCollectionViewDynamicLayout : UICollectionViewLayout<NSCopying>

@property (nonatomic,strong) NSCalendar *calendar;
@property (nonatomic,assign) NSUInteger rowHeight;
@property (nonatomic,assign) UIEdgeInsets rowPadding;
@property (nonatomic,assign) CalenderCollectionStyle style;
@property (nonatomic,copy) NSDate* selectedDay;

@property (nonatomic,readonly) NSUInteger noOfItemsInSection;
@property (nonatomic,readonly) NSUInteger noOfSections;
@property (nonatomic,readonly) CGSize suggestedBoundSize;
@property (nonatomic,readonly) NSDate* midPointDate;

-(void) onCalenderScroll;
-(void) onCalenderIdeal;

-(NSDate*) dateForItemAtIndexPath:(NSIndexPath*) indexPath;
-(void) snapToIndexPath:(NSIndexPath*) indexPath;
-(void) snapToDate:(NSDate*) date;

-(void) setStyle:(CalenderCollectionStyle)style completion:(void (^)(BOOL finished))completion;


@end
