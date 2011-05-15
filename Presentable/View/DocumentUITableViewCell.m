//
//  DocumentUITableViewCell.m
//  Presentable
//
//  Created by Scott Van Vliet on 5/11/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import "DocumentUITableViewCell.h"


@implementation DocumentUITableViewCell
{
}

    -(NSString*) titleLabelText
    {
        return titleLabel.text;
    }

    -(void) setTitleLabelText:(NSString*)withText
    {	
        titleLabel.text = withText;
    }

    -(NSString*) fileSizeLabelText
    {
        return fileSizeLabel.text;
    }

    -(void) setFileSizeLabelText:(NSString*)withText
    {	
        fileSizeLabel.text = withText;
    }

    -(IBOutlet) progressViewDelegate
    {
        return progressView;
    }

+ (DocumentUITableViewCell*) createNewCustomCellFromNib: (NSString*)withReuseIdentifier 
    {
        NSArray* nibContents = [[NSBundle mainBundle]
                                loadNibNamed:@"DocumentUITableViewCell" owner:self options:NULL];
        NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
        DocumentUITableViewCell *customCell= nil;
        NSObject* nibItem = nil;
        while ( (nibItem = [nibEnumerator nextObject]) != nil) {
            if ( [nibItem isKindOfClass: [DocumentUITableViewCell class]]) {
                customCell = (DocumentUITableViewCell*)nibItem;
                break; // we have a winner
            }
        }
        return customCell;
    }

    - (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
    {
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        if (self) {
            // Initialization code
        }
        return self;
    }

    - (void)setSelected:(BOOL)selected animated:(BOOL)animated
    {
        [super setSelected:selected animated:animated];

        // Configure the view for the selected state
    }

    - (void)dealloc
    {
        [titleLabel release];
        [fileSizeLabel release];
        [progressView release];
        [super dealloc];
    }

@end
