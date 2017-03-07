//
//  CalenderCollectionViewDynamicLayout.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/25/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalenderCollectionViewDynamicLayout.h"
#import "NSCalendar+Alignment.h"
#import "NSCalendar+Arithmetic.h"
#import "CalendarCollectionViewLayoutAttributes.h"
#import "CalendarCollectionViewInterface.h"

@interface CalenderCollectionViewDynamicLayout()
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic,assign) NSUInteger noOfWeeksInSection;
@property (nonatomic,readonly) NSUInteger totalNoOfItems;
@property (nonatomic,readonly) CGSize itemSize;
@property (nonatomic,readonly) NSDate *firstDayInFirstMonthDate;
@property (nonatomic,readonly) CGSize selectedWeekSize;
@property (nonatomic,assign) BOOL isUpdatingStyle;

@end

@implementation CalenderCollectionViewDynamicLayout
@synthesize selectedDay = _selectedDay;

#pragma mark - LifeCycle
-(instancetype) init {
    self = [super init];
    if(self) {
        //self.style = CalenderCollectionWeek;
        self.calendar = [NSCalendar currentCalendar];
        self.rowPadding = UIEdgeInsetsMake(0, 0, 1, 0);
        self.noOfWeeksInSection = 10000;
        self.startDate = [NSDate date];
        // move it to the middle of the section to reduce paging
        self.startDate = [self.calendar dateByAddingNumberOfWeeks:-self.noOfWeeksInSection/2.0 toDate:self.startDate];
        // Align it
        self.startDate = [self.calendar alignToFirstDayOfWeek:[self.calendar alignToFirstDayOfMonth:self.startDate]];
        self.rowHeight = 50;
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    CalenderCollectionViewDynamicLayout* copy = [[[self class] alloc] init];
    if (copy)
    {
        copy.calendar = self.calendar;
        copy.rowHeight = self.rowHeight;
        copy.rowPadding = self.rowPadding;
        copy.style = self.style;
        copy.startDate = self.startDate;
        copy.noOfWeeksInSection = self.noOfWeeksInSection;
    }
    return copy;
}

-(void) setStyle:(CalenderCollectionStyle)style completion:(void (^ __nullable)(BOOL finished))completion
{
    if(_style != style) {
        
        [self.collectionView performBatchUpdates:^{
            _style = (CalenderCollectionStyle)style;
            self.isUpdatingStyle = YES;
            
        } completion:^(BOOL finished) {
            NSDate* currentDate = self.selectedDay;
            self.isUpdatingStyle = NO;
            self.selectedDay = currentDate;
            
        }];
        completion(true);
    }
}

#pragma mark -

#pragma mark - Helpers
-(CGSize) itemSize {
    return CGSizeMake( floor(self.collectionView.bounds.size.width/7.0), self.rowHeight);
}

-(NSUInteger) noOfItemsInSection {
    return self.noOfWeeksInSection * 7;
}

-(NSUInteger) noOfSections {
    return 3;
}

-(NSUInteger) totalNoOfItems {
    return self.noOfSections * self.noOfItemsInSection;
}

-(NSDate*) firstDayInFirstMonthDate {
    NSDate* alignedStartDate = [self.calendar alignToFirstDayOfMonth:self.startDate];
    if([alignedStartDate isEqual:self.startDate]) {
        return alignedStartDate;
    }else {
        return [self.calendar dateByAddingNumberOfMonths:1 toDate:alignedStartDate];
    }
}

-(NSIndexPath*) indexPathForDate:(NSDate*) date {
    NSInteger delta = [self.calendar daysFromDate:self.startDate toDate:date];
    return [NSIndexPath indexPathForItem:delta % self.noOfItemsInSection inSection:delta / self.noOfItemsInSection];
}
-(NSDate*) dateForItemAtIndexPath:(NSIndexPath*) indexPath {
    return [self.calendar dateByAddingNumberOfDays:indexPath.item+indexPath.section*self.noOfItemsInSection toDate:self.startDate];
}

-(NSIndexPath*) indexPathForItemWithDate:(NSDate*) date {
    NSInteger delta = [self.calendar daysFromDate:self.startDate toDate:date];
    if(delta >=0 && delta<=self.totalNoOfItems) {
        return [NSIndexPath indexPathForItem:delta % self.noOfItemsInSection inSection:delta / self.noOfItemsInSection];
    }else {
        return nil;
    }
}

- (NSMutableArray<CalendarCollectionViewLayoutAttributes *> *)layoutAttributesForRange:(NSRange) range {
    
    NSMutableArray* res = [NSMutableArray array];
    CGSize cellSize = self.itemSize;
    NSUInteger currentRow = 0, currentCol = 0;
    switch (self.style) {
        case CalenderCollectionMonth:
            currentRow = range.location / 7;
            currentCol = range.location % 7;
            break;
        case CalenderCollectionWeek:
            currentCol = range.location;
            break;
    }
    
    NSUInteger extraPixels = self.collectionView.bounds.size.width - cellSize.width * 7;
    for(NSUInteger i = range.location;
        i < self.totalNoOfItems && i < range.location+range.length;
        i++) {
        
        // Create the attribute
        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForItem:i % self.noOfItemsInSection inSection:i / self.noOfItemsInSection];
        CalendarCollectionViewLayoutAttributes* attribute = [CalendarCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndexPath];
        attribute.frame = CGRectMake((currentCol%7)*cellSize.width + floor((CGFloat)currentCol/7.0)*self.collectionView.bounds.size.width,
                                     currentRow*cellSize.height,
                                     cellSize.width + (currentCol%7==6 ? extraPixels : 0),
                                     self.rowHeight - self.rowPadding.bottom );
        attribute.date = [self dateForItemAtIndexPath:cellIndexPath];
        attribute.calendar = self.calendar;
        
        [res addObject:attribute];
        if(self.style == CalenderCollectionMonth && ++currentCol == 7) {
            //we have to start a new row
            currentCol = 0;
            currentRow++;
        }else if(self.style == CalenderCollectionWeek){
            currentCol++;
        }
    }
    return res;
}


#pragma mark - Overrides
-(Class) layoutAttributesClass {
    return [CalendarCollectionViewLayoutAttributes class];
}

-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

-(void) invalidateLayout {
    //self.alwaysBounceHorizontal = NO;
    [super invalidateLayout];
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self layoutAttributesForRange:NSMakeRange(indexPath.item+indexPath.section*self.noOfItemsInSection, 1)].firstObject;
    //return [self.cellItemsAttribute objectAtIndex:indexPath.item];
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    //Get the start & end indexpath
    NSUInteger maxIndex = self.totalNoOfItems - 1;
    NSUInteger startIndex = 0, endIndex = 0;
    switch (self.style) {
        case CalenderCollectionWeek:
            startIndex = floor(MAX(0,CGRectGetMinX(rect)) / self.collectionView.bounds.size.width) * 7 + floor(fmod(MAX(0,CGRectGetMinX(rect)) , self.collectionView.bounds.size.width) / self.itemSize.width);
            endIndex = ceil(MAX(0,CGRectGetMaxX(rect)) / self.collectionView.bounds.size.width) * 7 + ceil(fmod(MAX(0,CGRectGetMaxX(rect)) , self.collectionView.bounds.size.width) / self.itemSize.width);
            break;
        case CalenderCollectionMonth:
            startIndex = floor(MAX(0,CGRectGetMinY(rect)) / self.rowHeight) * 7;
            endIndex = ceil(CGRectGetMaxY(rect) / self.rowHeight) * 7 + 6;
            break;
    }
    
    endIndex = MIN(maxIndex,endIndex);
    
    if(endIndex>=startIndex) {
        return [self layoutAttributesForRange:NSMakeRange(startIndex, endIndex-startIndex+1)];
        //return [self.cellItemsAttribute subarrayWithRange:NSMakeRange(startIndex, endIndex-startIndex+1)];
    }else {
        return nil;
    }
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attribute = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    return attribute;
}

-(CGSize) collectionViewContentSize {
    switch (self.style) {
        case CalenderCollectionWeek:
            return CGSizeMake(self.noOfSections*self.noOfWeeksInSection*self.collectionView.bounds.size.width,
                              self.rowHeight);
        case CalenderCollectionMonth:
            return CGSizeMake(self.collectionView.bounds.size.width,
                              self.noOfSections*self.noOfWeeksInSection*self.rowHeight);
    }
}


#pragma mark - Rotation Logic

-(void) rotateSections:(NSInteger) noOfSection {
    //+ve means adding more future days
    //-ve means adding more past days
    NSLog(@"rotation called");
    
    BOOL currentAnimationState = [UIView areAnimationsEnabled];
    
    [UIView setAnimationsEnabled:NO];
    
    if(noOfSection < 0) {
        // get some future dates and put it in the paste
        self.startDate = [self.calendar dateByAddingNumberOfWeeks:-self.noOfWeeksInSection toDate:self.startDate];
        [self.collectionView moveSection:self.noOfSections-1 toSection:0];
    }else {
        // get some past dates and put it in the future
        self.startDate = [self.calendar dateByAddingNumberOfWeeks:self.noOfWeeksInSection toDate:self.startDate];
        [self.collectionView moveSection:0 toSection:self.noOfSections-1];
    }
    
    [UIView setAnimationsEnabled:currentAnimationState];
    
    // adjust the content offset
    switch (self.style) {
        case CalenderCollectionMonth:
        {
            CGFloat delta = (noOfSection < 0 ? -1 : 1) * (CGFloat)self.noOfWeeksInSection*(CGFloat)self.rowHeight;
            [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y - delta )];
        }
            break;
        case CalenderCollectionWeek:
        {
            CGFloat delta = (noOfSection < 0 ? -1 : 1) * (CGFloat)self.noOfWeeksInSection*(CGFloat)self.collectionView.bounds.size.width;
            [self.collectionView setContentOffset:CGPointMake( self.collectionView.contentOffset.x - delta ,self.collectionView.contentOffset.y)];
        }
    }
}

-(void) rotateIfOutsideRange:(NSRange) range {
    
    CGFloat currentOffset = self.style == CalenderCollectionMonth ? self.collectionView.contentOffset.y : self.collectionView.contentOffset.x;
    
    // Rotate sections if needed
    if(currentOffset < range.location ) {
        //we need to get some dates from the future
        [self rotateSections:-1];
    }else if(currentOffset > range.length + range.location ) {
        [self rotateSections:1];
    }
}

-(void) onCalenderScroll {
    
    // Rotate sections if needed
    CGFloat length = self.style == CalenderCollectionMonth ? [self collectionViewContentSize].height : [self collectionViewContentSize].width;
    CGFloat halfSectionLength = length / self.noOfSections / 2.0;
    [self rotateIfOutsideRange:NSMakeRange(halfSectionLength,halfSectionLength*2*(self.noOfSections -1))];
    
}

-(void) onCalenderIdeal {
    
    // Rotate sections if needed
    CGFloat length = self.style == CalenderCollectionMonth ? [self collectionViewContentSize].height : [self collectionViewContentSize].width;
    CGFloat sectionLength = length / self.noOfSections;
    [self rotateIfOutsideRange:NSMakeRange(sectionLength,sectionLength)];
    
    NSIndexPath* newSelectedIndex = nil;
    if([self isDateVisible:self.selectedDay] == false) {
        //we have to update it to the start of month, or the current day if in the currnet month
        NSDate* today = [self alignToFirstDay:[NSDate date]];
        if([today isEqualToDate:[self alignToFirstDay:[self midPointDate]]]) {
            newSelectedIndex = [self indexPathForDate:[NSDate date]];
        }else {
            newSelectedIndex = [self indexPathForDate:[self alignToFirstDay:[self midPointDate]]];
        }
        [self.collectionView selectItemAtIndexPath:newSelectedIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    
}

#pragma mark - Snapping
-(NSDate*) alignToLastDay:(NSDate*) date {
    if(self.style == CalenderCollectionMonth) {
        return [self.calendar alignToLastDayOfMonth:date];
    }else {
        return [self.calendar alignToLastDayOfWeek:date];
    }
}
-(NSDate*) alignToFirstDayNextPeriod:(NSDate*) date {
    if(self.style == CalenderCollectionMonth) {
        return [self.calendar alignToFirstDayOfNextMonth:date];
    }else {
        return [self.calendar alignToFirstDayOfNextWeek:date];
    }
}
-(NSDate*) alignToFirstDay:(NSDate*) date {
    if(self.style == CalenderCollectionMonth) {
        return [self.calendar alignToFirstDayOfMonth:date];
    }else {
        return [self.calendar alignToFirstDayOfWeek:date];
    }
}

-(BOOL) isDateVisible:(NSDate*) date {
    return [[self alignToFirstDay:date] isEqualToDate:[self alignToFirstDay:[self midPointDate]]];
}

-(NSIndexPath*) indexPathForPoint:(CGPoint) point {
    NSUInteger dateIndex = 0;
    point.x = MAX(0,point.x);
    point.y = MAX(0,point.y);
    switch (self.style) {
        case CalenderCollectionWeek:
            dateIndex = floor(point.x / self.collectionView.bounds.size.width) * 7;
            dateIndex += floor(fmod(point.x, self.collectionView.bounds.size.width) / self.itemSize.width);
            break;
        case CalenderCollectionMonth:
            dateIndex = floor(point.y / self.rowHeight) * 7;
            dateIndex += floor(point.x / self.itemSize.width);
            break;
    }
    return [NSIndexPath indexPathForItem:dateIndex % self.noOfItemsInSection inSection:floor(dateIndex/self.noOfItemsInSection)];
}

-(CGRect) frameForIndexPath:(NSIndexPath*) indexPath {
    
    CGSize cellSize = self.itemSize;
    NSUInteger extraPixels = self.collectionView.bounds.size.width - cellSize.width * 7;
    
    NSUInteger currentRow = 0;
    NSUInteger currentCol = indexPath.item + indexPath.section * self.noOfItemsInSection;
    
    if(self.style == CalenderCollectionMonth) {
        currentRow = floor(currentCol / 7.0);
        currentCol = floor(currentCol % 7);
    }
    
    return CGRectMake((currentCol%7)*cellSize.width + floor((CGFloat)currentCol/7.0)*self.collectionView.bounds.size.width,
                      currentRow*cellSize.height,
                      cellSize.width + (currentCol%7==6 ? extraPixels : 0),
                      cellSize.height - self.rowPadding.bottom );
}

-(CGPoint) offsetForDate:(NSDate*) date {
    return [self frameForIndexPath:[self indexPathForDate:date]].origin;
}

-(NSDate*) selectedDay {
    NSIndexPath* selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if(selectedIndexPath) {
        //make sure it is in the current visible range
        return [self dateForItemAtIndexPath:selectedIndexPath];
    }else {
        return nil;
    }
}

-(NSDate*) midPointDate {
    CGPoint midPoint = CGPointMake(self.collectionView.contentOffset.x + self.suggestedBoundSize.width/2.0,
                                   self.collectionView.contentOffset.y + self.suggestedBoundSize.height/2.0);
    NSIndexPath* indexPath = [self indexPathForPoint:midPoint];
    return [self dateForItemAtIndexPath:indexPath];
}

-(void) setSelectedDay:(NSDate *)selectedDay {
    NSIndexPath * indexPath = [self indexPathForDate:selectedDay];
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    
    // we have to snap to it
    [self snapToDate:[self alignToFirstDay:selectedDay]];
}

-(CGRect) frameForStartDate:(NSDate*) startDate endDate:(NSDate*) endDate {
    CGRect startFrame = [self frameForIndexPath:[self indexPathForDate:startDate]];
    CGRect endFrame = [self frameForIndexPath:[self indexPathForDate:endDate]];
    return CGRectUnion(startFrame, endFrame);
}

-(CGSize) suggestedBoundSize {
    NSDate* currentDate = self.selectedDay;
    NSDate* startDate = [self alignToFirstDay:currentDate];
    NSDate* endDate = [self alignToLastDay:currentDate];
    CGSize res = [self frameForStartDate:startDate endDate:endDate].size;
    return CGSizeMake(res.width, res.height + self.rowPadding.bottom);
}

-(void) snapToIndexPath:(NSIndexPath*) indexPath {
    
    NSIndexPath* targetIndexPath = [self indexPathForDate:[self alignToFirstDay:[self dateForItemAtIndexPath:indexPath]]];
    
    [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionTop | UICollectionViewScrollPositionLeft animated:[UIView areAnimationsEnabled]];
}

-(void) snapToDate:(NSDate*) date {
    [self snapToIndexPath:[self indexPathForDate:date]];
}

// Align to month in case of MonthViewStyle or week in case of WeekViewStyle
-(NSDate*) nearestAligmentDateforProposedContentOffset:(CGPoint) proposedContentOffset {
    
    // center it
    if(self.style == CalenderCollectionMonth){
        proposedContentOffset = CGPointMake(proposedContentOffset.x + self.collectionView.bounds.size.width/2.0, proposedContentOffset.y);
    }else { //week
        proposedContentOffset = CGPointMake(proposedContentOffset.x, proposedContentOffset.y);
    }
    // convert to indexpath
    NSIndexPath* proposedIndexPath = [self indexPathForPoint:proposedContentOffset];
    // convert to date
    NSDate* proposedDate = [self dateForItemAtIndexPath:proposedIndexPath];
    
    NSDate* startDate = [self alignToFirstDay:proposedDate];
    NSDate* endDate = [self alignToFirstDayNextPeriod:proposedDate];
    
    CGFloat distanceToEnd = [self.calendar daysFromDate:proposedDate toDate:endDate];
    CGFloat distanceToStart = [self.calendar daysFromDate:startDate toDate:proposedDate];
    if(distanceToEnd < distanceToStart) {
        return endDate;
    }else {
        return startDate;
    }
}

-(CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    if(CGRectContainsPoint(CGRectMake(0, 0, [self collectionViewContentSize].width, [self collectionViewContentSize].height), proposedContentOffset) == false ) {
        // the user switched the style
        return [self offsetForDate:[self.calendar alignToFirstDayOfWeek:[self alignToFirstDay:self.selectedDay]]];
    }else {
        return proposedContentOffset;
    }
}

-(CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // Snap to the nearest month
    NSDate* date = [self nearestAligmentDateforProposedContentOffset:proposedContentOffset];
    if(date) {
        CGPoint offset = [self offsetForDate:date];
        return CGPointMake(self.style == CalenderCollectionMonth ? 0.0 : offset.x,offset.y);
    }else {
        return proposedContentOffset;
    }
}


@end
