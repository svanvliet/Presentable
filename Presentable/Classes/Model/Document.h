//
//  Document.h
//  Presentable
//
//  Created by Scott Van Vliet on 5/8/11.
//  Copyright (c) 2011 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum
{
    ACTIVE,
    PENDING,
    CANCELLED,
    FAILED,
    COMPLETED
} 
DocumentConversionStateType;


@interface Document : NSManagedObject 
{
    @private
    NSDateFormatter *dateFormatter;
    NSNumberFormatter *numberFormatter;
}

    +(NSString*) documentConversionStateTypeString:(DocumentConversionStateType)forEnumValue;
    +(UIImage*) PDFPageThumbnailImage:(NSURL*)PDFURL;

    @property (nonatomic, retain) NSDate * addedTimeStamp;
    @property (nonatomic, retain) NSData * thumbnailImageData;

    @property (nonatomic, retain) NSString * originalFileName;
    @property (nonatomic, retain) NSString * originalFileType;
    @property (nonatomic, retain) NSNumber * originalFileSizeInBytes;
    @property (nonatomic, retain) NSURL * originalFileURL;

    @property (nonatomic, retain) NSString * convertedFileType;
    @property (nonatomic, retain) NSString * convertedFileName;
    @property (nonatomic, retain) NSNumber * convertedFileSizeInBytes;
    @property (nonatomic, retain) NSURL * convertedFileURL;

    @property (nonatomic, retain) NSNumber * conversionState;
    @property (nonatomic, retain) NSNumber * conversionProgressPercent;
    @property (nonatomic, retain) NSDate * conversionStartedTimeStamp;
    @property (nonatomic, retain) NSDate * conversionCompletedTimeStamp;

    @property (readonly) NSString * fileName;
    @property (readonly) NSString * fileType;
    @property (readonly) NSNumber * fileSizeInBytes;
    @property (readonly) NSString * fileSizeDescription;
    @property (readonly) NSString * fileTimestampDescription;
    @property (readonly) NSURL * fileURL;

    @property (nonatomic, retain) NSNumber * isUnread;

@end
