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

    +(UIImage*) PDFPageThumbnailImage:(NSURL*)PDFURL
    {
        UIImage *image = nil;
        
        CGFloat width = 320.0f;
        CGPDFDocumentRef pdfDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef)PDFURL);
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
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }

    @dynamic addedTimeStamp;
    @dynamic thumbnailImageData;

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

    @dynamic isUnread;

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


    -(NSString*) fileSizeDescription
    {
        if (!numberFormatter)
        {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setCurrencySymbol: @""];
            [numberFormatter setMaximumFractionDigits: 0];
        }
        
        NSString *description = nil;
        if ([self.convertedFileSizeInBytes intValue] > 0)
        {
            description = [NSString stringWithFormat: @"File Size: %dKB", [self.convertedFileSizeInBytes intValue] / 1000];
        }
        else
        {
            description = [NSString stringWithFormat: @"File Size: %dKB", [self.originalFileSizeInBytes intValue] / 1000];
        }
        
        return description;
    }

    -(NSString*) fileTimestampDescription
    {
        
        if (!dateFormatter)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle: NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        }
        
        NSString *description = nil;
        if ([self.convertedFileSizeInBytes intValue] > 0)
        {
            description = [NSString stringWithFormat: @"Converted: %@", [dateFormatter stringFromDate: self.conversionCompletedTimeStamp]];
        }
        else
        {
            description = [NSString stringWithFormat: @"Added: %@", [dateFormatter stringFromDate: self.addedTimeStamp]];
        }
        
        return description;
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

    -(void)dealloc
    {
        [super dealloc];
        
        [numberFormatter release]; numberFormatter = nil;
        [dateFormatter release]; dateFormatter = nil;
    }

@end
