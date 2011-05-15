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
    IBOutlet UILabel *fileSizeLabel;
    
    IBOutlet UIProgressView *progressView;
    IBOutlet UIImageView *thumbnailImageView;
    
    @private
    NSString *__titleLabelText;
    NSString *__fileSizeLabelText;
}

+(DocumentUITableViewCell*) createNewCustomCellFromNib: (NSString*)withReuseIdentifier;

@property (nonatomic, retain) NSString * titleLabelText;
@property (nonatomic, retain) NSString * fileSizeLabelText;
@property (nonatomic, retain) UIImage * thumbnailImage;
@property (readonly) IBOutlet UIProgressView * progressViewDelegate;


@end
