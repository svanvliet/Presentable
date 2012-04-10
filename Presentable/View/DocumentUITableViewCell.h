//
//  DocumentUITableViewCell.h
//  Presentable
//
//  Created by Scott Van Vliet on 5/11/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DocumentUITableViewCell : UITableViewCell 
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *fileTimestampLabel;
    IBOutlet UILabel *fileSizeLabel;
    
    IBOutlet UIImageView *thumbnailImageView;
    IBOutlet UIImageView *newDocumentIndicatorView;
    IBOutlet UIView *itemView;
    
}
    @property (nonatomic, retain) NSString * titleLabelText;
    @property (nonatomic, retain) NSString * fileTimestampLabelText;
    @property (nonatomic, retain) NSString * fileSizeLabelText;
    @property (nonatomic, retain) UIImage * thumbnailImage;

    @property (nonatomic, retain) UIImage *
        newDocumentIdicatorImage;

@end
