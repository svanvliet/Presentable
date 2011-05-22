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

    -(NSString*) fileTimestampLabelText
    {
        return fileTimestampLabel.text;
    }

    -(void) setFileTimestampLabelText:(NSString*)withText
    {	
        fileTimestampLabel.text = withText;
    }

    -(UIImage*) thumbnailImage
    {
        return thumbnailImageView.image;
    }

    -(void) setThumbnailImage:(UIImage *)image
    {
        if (thumbnailImageView)
        {
            thumbnailImageView.image = image;
        }
    }

    - (void) awakeFromNib
    {
        /*
        thumbnailImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        thumbnailImageView.layer.shadowRadius = 2.0f;
        thumbnailImageView.layer.shadowOpacity = 0.5f;
        thumbnailImageView.layer.shadowOffset = CGSizeMake(0, 0);
        thumbnailImageView.layer.shouldRasterize = YES;
        
        itemView.layer.cornerRadius = 5.0f;
        itemView.layer.shadowOpacity = 0.5f;
        itemView.layer.shadowRadius = 5.0f;
        itemView.layer.shadowOffset = CGSizeMake(1,1);
        itemView.layer.shadowColor = [[UIColor blackColor] CGColor];
        itemView.layer.shouldRasterize = YES;
        
        self.clipsToBounds = NO;
        */
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
        [thumbnailImageView release];
        [super dealloc];
    }

@end
