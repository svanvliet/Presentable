//
//  DocumentUITableViewCell.m
//  Presentable
//
//  Created by Scott Van Vliet on 5/11/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import "DocumentUITableViewCell.h"
#import <QuartzCore/CALayer.h>


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

    -(UIImage*) thumbnailImage
    {
        return thumbnailImageView.image;
    }

    -(void) setThumbnailImage:(UIImage *)thumbnailImage
    {
        if (thumbnailImageView != nil)
        {
            thumbnailImageView.image = thumbnailImage;
        }
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

    - (void) awakeFromNib
    {
        //CALayer *shadowLayer = [CALayer layer];
        //shadowLayer.bounds = thumbnailImageView.bounds;
        
        thumbnailImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        thumbnailImageView.layer.shadowRadius = 3.0f;
        thumbnailImageView.layer.shadowOpacity = 0.5f;
        thumbnailImageView.layer.shadowOffset = CGSizeMake(0, 0);
        
        
        thumbnailImageView.clipsToBounds = NO;
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
