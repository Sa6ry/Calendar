//
//  CalendarCollectionViewInterface.h
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 3/3/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#ifndef CalendarCollectionViewInterface_h
#define CalendarCollectionViewInterface_h

@class CalendarCollectionView;

// Events comming out from the control
@protocol CalenderCollectionViewDelegate <NSObject>
@optional
- (void)calendarView:(CalendarCollectionView * _Nonnull)calenderView didSelectDate:(NSDate * _Nonnull )date;
- (void)calendarViewDidScroll:(CalendarCollectionView * _Nonnull)calenderView;
- (void)calendarViewDidStopAnimation:(CalendarCollectionView * _Nonnull)calenderView;
@end

// Feed the control with data through these methods
@protocol CalenderCollectionViewDataSource <NSObject>
- (NSUInteger) calendarView:(CalendarCollectionView * _Nonnull)calenderView noOfEventsInDay:(NSDate * _Nonnull )date;
@end

// Drive the control through these methods
@protocol CalenderCollectionViewInterface <NSObject>
@property (nonatomic, weak, nullable) id <CalenderCollectionViewDelegate> calendarDelegate;
@property (nonatomic, weak, nullable) id <CalenderCollectionViewDataSource> calendarDataSource;
-(void) updateNoOfEvents:(NSUInteger)noOfEvents forVisibleCellWithDate:(NSDate* _Nonnull) date;
@end

#endif /* CalendarCollectionViewInterface_h */
