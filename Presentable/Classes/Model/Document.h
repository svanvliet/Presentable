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
    UIImage *__thumbnailImage;
}

    +(NSString*) documentConversionStateTypeString:(DocumentConversionStateType)forEnumValue;

    -(UIImage*) thumbnailImage;

    @property (nonatomic, retain) NSDate * addedTimeStamp;

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
    @property (readonly) NSString * fileDescription;
    @property (readonly) NSURL * fileURL;

@end
