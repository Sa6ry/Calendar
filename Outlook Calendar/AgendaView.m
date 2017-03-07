//
//  AgendaView.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 3/3/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "AgendaView.h"
#import "AgendaEventTableViewCell.h"

#define kAgendaViewCell @"AgnedaViewCell"

@interface AgendaView()
@property (nonatomic,strong) NSArray<CalendarEvent*> * _Nullable calendarEvents;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UILabel* noEventsLabel;
@end

@implementation AgendaView

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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 30.0;
    [self.tableView registerNib:[UINib nibWithNibName:@"AgendaEventTableViewCell" bundle:nil] forCellReuseIdentifier:kAgendaViewCell];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.noEventsLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.noEventsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.noEventsLabel.textAlignment = NSTextAlignmentCenter;
    self.noEventsLabel.font = [UIFont boldSystemFontOfSize:28];
    self.noEventsLabel.textColor = [UIColor lightGrayColor];
    self.noEventsLabel.text = @"No Events";
    [self.tableView addSubview:self.noEventsLabel];
}

-(void) reloadWithEvents:(NSArray<CalendarEvent*>* _Nullable) events {
    self.calendarEvents = events;
    self.noEventsLabel.hidden = events.count != 0;
    [self.tableView reloadData];
}


#pragma mark - datasource
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgendaEventTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kAgendaViewCell forIndexPath:indexPath];
    [cell updateWithEvent:self.calendarEvents[indexPath.item]];
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
#pragma mark - delegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.calendarEvents.count;
}


@end
