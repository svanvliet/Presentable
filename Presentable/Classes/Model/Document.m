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

    -(UIImage*) thumbnailImage
    {
        if ([self.conversionState intValue] == COMPLETED)
        {
            if (__thumbnailImage == nil)
            {
                CGFloat width = 100.0f;
                CGPDFDocumentRef pdfDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef)self.convertedFileURL);
                CGPDFPageRef pdfFirstPage = CGPDFDocumentGetPage(pdfDocumentRef, 1);
                
                CGRect pageRect = CGPDFPageGetBoxRect(pdfFirstPage, kCGPDFMediaBox);
                CGFloat pdfScale = width/pageRect.size.width;
                pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
                pageRect.origin = CGPointZero;
                
                UIGraphicsBeginImageContext(pageRect.size);
                
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                // White BG
                CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
                CGContextFillRect(context,pageRect);
                
                CGContextSaveGState(context);
                
                // ***********
                // Next 3 lines makes the rotations so that the page look in the right direction
                // ***********
                CGContextTranslateCTM(context, 0.0, pageRect.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfFirstPage, kCGPDFMediaBox, pageRect, 0, true));
                
                CGContextDrawPDFPage(context, pdfFirstPage);
                CGContextRestoreGState(context);
                
                __thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
            }
        }
        else if ([self.conversionState intValue] == PENDING)
        {
            //__thumbnailImage = [[UIImage alloc] init];
        }
        return __thumbnailImage;
    }

    -(void)awakeFromInsert
    {
        
    }

    -(void)awakeFromFetch
    {
    }

@end
