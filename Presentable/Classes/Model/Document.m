//
//  Document.m
//  Presentable
//
//  Created by Scott Van Vliet on 5/8/11.
//  Copyright (c) 2011 Personal. All rights reserved.
//

#import "Document.h"


@implementation Document

    NSString * const DocumentConversionStateTypeStrings[] = 
    {
        @"Active",
        @"Pending",
        @"Cancelled",
        @"Failed",
        @"Completed"
    };

    +(NSString*) documentConversionStateTypeString:(DocumentConversionStateType)forEnumValue
    {
        return DocumentConversionStateTypeStrings[forEnumValue];
    }

    @dynamic addedTimeStamp;

    @dynamic originalFileName;
    @dynamic originalFileType;
    @dynamic originalFileSizeInBytes;
    @dynamic originalFileURL;

    @dynamic convertedFileType;
    @dynamic convertedFileName;
    @dynamic convertedFileSizeInBytes;
    @dynamic convertedFileURL;

    @dynamic conversionState;
    @dynamic conversionProgressPercent;
    @dynamic conversionStartedTimeStamp;
    @dynamic conversionCompletedTimeStamp;

    -(NSString*) fileName
    {
        if (self.convertedFileName != nil)
        {
            return self.convertedFileName;
        }
        return self.originalFileName;
    }

    -(NSString*) fileType
    {
        if (self.convertedFileType != nil)
        {
            return self.convertedFileType;
        }
        return self.originalFileType;
    }

    -(NSNumber*) fileSizeInBytes
    {
        if ([self.convertedFileSizeInBytes intValue] > 0)
        {
            return self.convertedFileSizeInBytes;
        }
        return self.originalFileSizeInBytes;
    }

    -(NSString*) fileDescription
    {
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencySymbol: @""];
        [numberFormatter setMaximumFractionDigits: 0];
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle: NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        
        if ([self.convertedFileSizeInBytes intValue] > 0)
        {
            return [NSString stringWithFormat: @"Converted %@  |  File Size: %dKB", [dateFormatter stringFromDate: self.conversionCompletedTimeStamp], [self.convertedFileSizeInBytes intValue] / 1000];
        }
        return [NSString stringWithFormat: @"Added %@  |  File Size: %dKB", [dateFormatter stringFromDate: self.addedTimeStamp], [self.originalFileSizeInBytes intValue] / 1000];
    }

    -(NSURL*) fileURL
    {
        if (self.convertedFileURL != nil)
        {
            return self.convertedFileURL;
        }
        return self.originalFileURL;
    }

    -(UIImage*) documentThumbnailImage
    {
        if (__documentThumbnailImage == nil)
        {
            
        }
        return __documentThumbnailImage;
    }

    -(void)awakeFromInsert
    {
        
    }

    -(void)awakeFromFetch
    {
    }

@end
