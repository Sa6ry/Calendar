//
//  CalenderView.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/24/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalendarCollectionView.h"
#import "CalenderCollectionViewDynamicLayout.h"
#import "CalendarCollectionViewCell.h"

#define kCalenderViewCell @"CalenderViewCell"

@interface CalendarCollectionView()
@property (nonatomic,readonly) CalenderCollectionViewDynamicLayout* collectionViewDynamicLayout;
@property (nonatomic,retain) NSCalendar* calender;
@property (nonatomic,assign) BOOL lockContentOffset;
@property (nonatomic,assign) CGRect lockedBound;
@property (nonatomic,assign) CGPoint lockedCenter;

@property (nonatomic,strong) UICollectionView* collectionView;
@end

@implementation CalendarCollectionView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadContent];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self loadContent];
    }
    return self;
}

// Load content from the xib file
-(void) loadContent {
    [self setCollectionViewLayout:[[CalenderCollectionViewDynamicLayout alloc] init]];
    self.calender = [NSCalendar currentCalendar];
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.dataSource = self;
    self.delegate = self;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self registerClass:[CalendarCollectionViewCell class] forCellWithReuseIdentifier:kCalenderViewCell];
    self.selectedDay = [NSDate date];
}

-(void) setContentOffset:(CGPoint)contentOffset {
    if(self.lockContentOffset == false) {
        [super setContentOffset: CGPointMake( self.collectionViewDynamicLayout.style == CalenderCollectionWeek ? contentOffset.x : 0.0, self.collectionViewDynamicLayout.style == CalenderCollectionMonth ? contentOffset.y : 0.0 )];
    }
}

#pragma mark -
-(CGSize) suggestedBoundSize {
    return self.collectionViewDynamicLayout.suggestedBoundSize;
}

-(NSDate*) selectedDay {
    return self.collectionViewDynamicLayout.selectedDay;
}

-(NSDate*) visibleDay {
    return self.collectionViewDynamicLayout.midPointDate;
}
-(void) setSelectedDay:(NSDate *)selectedDay {
    self.collectionViewDynamicLayout.selectedDay = selectedDay;
}
-(CalenderViewStyle) style {
    return (CalenderViewStyle)self.collectionViewDynamicLayout.style;
}
-(void) setStyle:(CalenderViewStyle)style {
    
    // The transition animation is not yet read
    // This is a workaround, we are going to disable it for now
    // to have a better looking transition
    [UIView performWithoutAnimation:^{
        self.lockContentOffset = YES;
        [self.collectionViewDynamicLayout setStyle:(CalenderCollectionStyle)style completion:^(BOOL finished) {
            [self onScrollStop];
            self.lockContentOffset = NO;
        }];
    }];
    
}

-(BOOL) scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    self.collectionViewDynamicLayout.selectedDay = [NSDate date];
    return false;
}

#pragma mark -
-(CalenderCollectionViewDynamicLayout*) collectionViewDynamicLayout {
    return (CalenderCollectionViewDynamicLayout*) super.collectionViewLayout;
}

-(void) layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - senders

-(void) onScrollStop {
    if([self.calendarDelegate respondsToSelector:@selector(calendarViewDidStopAnimation:)]) {
        [self.calendarDelegate performSelector:@selector(calendarViewDidStopAnimation:) withObject:self];
    }
}
-(void) onScroll {
    if([self.calendarDelegate respondsToSelector:@selector(calendarViewDidScroll:)]) {
        [self.calendarDelegate performSelector:@selector(calendarViewDidScroll:) withObject:self];
    }
}
-(void) onDaySelect:(NSDate*) date {
    if([self.calendarDelegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.calendarDelegate performSelector:@selector(calendarView:didSelectDate:) withObject:self withObject:date];
    }
}

#pragma mark - delegates
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self onScroll];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self onScroll];
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.collectionViewDynamicLayout onCalenderScroll];
    [self onScroll];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.collectionViewDynamicLayout onCalenderIdeal];
    [self onDaySelect:self.selectedDay];
    [self onScrollStop];
    
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.collectionViewDynamicLayout onCalenderIdeal];
    [self onDaySelect:self.selectedDay];
    [self onScrollStop];
}
#pragma mark - delegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  [self onDaySelect:[self.collectionViewDynamicLayout dateForItemAtIndexPath:indexPath]];
    [self.collectionViewDynamicLayout snapToIndexPath:indexPath];
    [self onDaySelect:self.selectedDay];
}
#pragma mark - Data Source

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.collectionViewDynamicLayout noOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.collectionViewDynamicLayout noOfItemsInSection];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCollectionViewCell * cell = (id)[self dequeueReusableCellWithReuseIdentifier:kCalenderViewCell forIndexPath:indexPath];
    [cell setNoOfEvents:[self.calendarDataSource calendarView:self noOfEventsInDay:cell.date]];
    return cell;
}

#pragma mark -

-(void) updateNoOfEvents:(NSUInteger)noOfEvents forVisibleCellWithDate:(NSDate* _Nonnull) date {
    for(CalendarCollectionViewCell* cell in self.visibleCells) {
        if([cell.date isEqualToDate:date]) {
            [cell setNoOfEvents:noOfEvents];
            break;
        }
    }
}

@end
