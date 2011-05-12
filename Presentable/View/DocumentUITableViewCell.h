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
    
    @public
    IBOutlet UIProgressView *progressView;
    
    @private
    NSString *__titleLabelText;
    NSString *__fileSizeLabelText;
}

+(DocumentUITableViewCell*) createNewCustomCellFromNib;

@property (nonatomic, retain) NSString * titleLabelText;
@property (nonatomic, retain) NSString * fileSizeLabelText;
@property (readonly) IBOutlet UIProgressView * progressViewDelegate;


@end
