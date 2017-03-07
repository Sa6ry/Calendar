
//
//  CalendarEventsViewController.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/26/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalendarEventsViewController.h"
#import "CalendarCollectionView.h"
#import "AgendaView.h"
#import "CalendarDataSource.h"

@interface CalendarEventsViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet CalendarCollectionView *calendarView;
@property (weak, nonatomic) IBOutlet AgendaView *agendaView;
@property (nonatomic,retain) CalendarDataSource* calendarDataSource;

@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;

@end

@implementation CalendarEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // load our datasour and connect our delegates
    self.calendarDataSource = [[CalendarDataSource alloc] initWithCompletion:^(NSError *error) {
        if(error == nil) {
            self.calendarView.calendarDelegate = self;
            self.calendarView.calendarDataSource = self;
        }else {
            // show an error message    
        }
    }];
    
    [UIView performWithoutAnimation:^{
        [self updateCalendarHeight];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // update the navigation bar item with the current date
    NSInteger day = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]] day];
    self.currentDayLabel.text = [NSString stringWithFormat:@"%ld",(long)day];
}

#pragma mark - Helpers

-(void) updateCalendarHeight {
    self.calendarHeightConstraint.constant = self.calendarView.suggestedBoundSize.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:nil];
}

-(void) updateTitleWithDate:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    NSString* formatedTitle = [dateFormatter stringFromDate:date];
    self.selectedDateLabel.text = formatedTitle;
}

#pragma mark - CalendarDataSource
-(NSUInteger) calendarView:(CalendarCollectionView *)calenderView noOfEventsInDay:(NSDate *)date {
    // this method is async, for now return 0, then update it later
    return [self.calendarDataSource getEventsCountForDay:date withCompletion:^(NSUInteger noOfEvents) {
        // update the view here
        [self.calendarView updateNoOfEvents:noOfEvents forVisibleCellWithDate:date];
    }];
}

#pragma mark - CalendarDelegate
- (void) calendarView:(CalendarCollectionView *)calenderView didSelectDate:(NSDate *)date {
    
    // update the day events
    [self.calendarDataSource getEventsForDay:date withCompletion:^(NSArray<CalendarEvent *> * eventsArray) {
        if([calenderView.selectedDay isEqualToDate:date]) {
            if(self.calendarView.style == CalenderViewWeek) {
                [self updateTitleWithDate:calenderView.selectedDay];
            }
            [self.agendaView reloadWithEvents:eventsArray];
        }
    }];
}

- (void) calendarViewDidScroll:(CalendarCollectionView *)calenderView {
    // pause the data source for better performance
    [self.calendarDataSource pause];
    [self updateTitleWithDate:calenderView.visibleDay];
}

-(void) calendarViewDidStopAnimation:(CalendarCollectionView *)calenderView
{
    [self.calendarDataSource resume];
    [self updateTitleWithDate:calenderView.selectedDay];
    // change the size of the header
    [self updateCalendarHeight];
}

#pragma mark - Toolbar Events

- (IBAction)onAlternateStyle:(id)sender {
    self.calendarView.style = (self.calendarView.style + 1 ) % 2;
}

- (IBAction)onSnapToCurrentDate:(id)sender {
    self.calendarView.selectedDay = [NSDate date];
}

- (IBAction)onCreateNewEvent:(id)sender {
    
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"TODO: Add new calendar event here"  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
