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
    @dynamic originalFileBinary; // Should remove; but issues with Xcode and git
    @dynamic originalFileURL;

    @dynamic convertedFileType;
    @dynamic convertedFileName;
    @dynamic convertedFileSizeInBytes;
    @dynamic convertedFileBinary; // Should remove; but issues with Xcode and git
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

    -(NSData*) fileBinary
    {
        if (self.convertedFileBinary != nil)
        {
            return self.convertedFileBinary;
        }
        return self.originalFileBinary;
    }

    -(NSNumber*) fileSizeInBytes
    {
        if (self.convertedFileSizeInBytes != nil)
        {
            return self.convertedFileSizeInBytes;
        }
        return self.originalFileSizeInBytes;
    }

    -(NSURL*) fileURL
    {
        if (self.convertedFileURL != nil)
        {
            return self.convertedFileURL;
        }
        return self.originalFileURL;
    }

    -(void)awakeFromInsert
    {
        
    }

    -(void)awakeFromFetch
    {
    }

@end
