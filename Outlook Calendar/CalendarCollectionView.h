//
//  CalenderView.h
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/24/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarCollectionViewInterface.h"

typedef enum : NSUInteger {
    CalenderViewMonth = 0,
    CalenderViewWeek,
} CalenderViewStyle;

@interface CalendarCollectionView : UICollectionView < CalenderCollectionViewInterface, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,readonly) CGSize suggestedBoundSize;
@property (nonatomic,copy) NSDate* _Nonnull selectedDay;
@property (nonatomic,readonly) NSDate* _Nonnull visibleDay;
@property (nonatomic,assign) CalenderViewStyle style;

@property (nonatomic, weak, nullable) id <CalenderCollectionViewDelegate> calendarDelegate;
@property (nonatomic, weak, nullable) id <CalenderCollectionViewDataSource> calendarDataSource;
@end
