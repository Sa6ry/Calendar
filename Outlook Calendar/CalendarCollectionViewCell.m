//
//  CalendarCollectionViewCell.m
//  Outlook Calendar
//
//  Created by Ahmed Sabry on 2/26/17.
//  Copyright © 2017 Sabry. All rights reserved.
//

#import "CalendarCollectionViewCell.h"
#import "CalendarCollectionViewLayoutAttributes.h"
#import "NSCalendar+Arithmetic.h"

@interface CalendarCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (nonatomic,copy) CalendarCollectionViewLayoutAttributes *recentLayoutAttributes;

@property (weak, nonatomic) IBOutlet UIStackView *circlesContainerView;
@end

@implementation CalendarCollectionViewCell

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
    UIView *xibView = [[NSBundle bundleForClass:self.class] loadNibNamed:NSStringFromClass(self.class)
                                                                   owner:self
                                                                 options:nil].firstObject;
    xibView.frame = self.contentView.bounds;
    xibView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.userInteractionEnabled = NO;
    //self.selectedView.layer.shouldRasterize = YES;
    [self.contentView addSubview: xibView];
    [self updateView];
}

-(void) applyLayoutAttributes:(CalendarCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.recentLayoutAttributes = layoutAttributes;
    [self layoutIfNeeded]; // needs to be called to insure that the selectedView.bounds has been updated
    [self updateView];
}

-(void) prepareForReuse {
    // make sure the initial color is clear, so we have smooth transition while updating selection color
    self.selectedView.backgroundColor = [UIColor clearColor];
}

#pragma mark Initilization

-(NSDate*) date {
    return self.recentLayoutAttributes.date;
}

-(void) setNoOfEvents:(NSInteger) events {
    __block NSInteger e = events;
    BOOL beforeState = [CATransaction disableActions];
    [CATransaction setDisableActions: YES];
    [UIView performWithoutAnimation:^{
        for(UIImageView* imageView in self.circlesContainerView.subviews) {
            imageView.hidden = !(--e >= 0);
        }
    }];
    [CATransaction setDisableActions:beforeState];
}

-(void) updateView {    
    self.dayLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.recentLayoutAttributes.day];
    self.selected = self.recentLayoutAttributes.isSelected;
    
    switch (self.recentLayoutAttributes.backgroundStyle) {
        case CalendarCellBackgroundDark:
            self.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
            break;
        case CalendarCellBackgroundLight:
            self.backgroundColor = [UIColor whiteColor];
            break;
    }
}

-(void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedView.hidden = !selected;
    if(self.selectedView.hidden == false) {
        // the cell is selected
        [UIView performWithoutAnimation:^{
            self.selectedView.layer.cornerRadius = self.selectedView.bounds.size.width / 2.0;
            self.dayLabel.textColor = [UIColor whiteColor];
            if(self.recentLayoutAttributes.isToday) {
                self.selectedView.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:117.0/255.0 blue:194.0/255.0 alpha:1.0];
            }else {
                self.selectedView.backgroundColor = [UIColor darkGrayColor];
            }

        }];
    }else {
        self.dayLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0];
    }
    
}

@end
