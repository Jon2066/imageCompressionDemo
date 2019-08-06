//
//  ViewController.m
//  SCImageCompress
//
//  Created by Jonathan on 2019/8/3.
//  Copyright © 2019 Jonathan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSTextField *persentTF;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.捆绑包目录
    NSLog(@"bundlePath %@",[NSBundle mainBundle].bundlePath);
    
    // 2.沙盒主目录
    NSString *homeDir = NSHomeDirectory();
    NSLog(@"homeDir %@",homeDir);
    
    NSTextField *persentTF = [[NSTextField alloc] init];
    persentTF.editable = YES;
    persentTF.bordered = NO;
    persentTF.maximumNumberOfLines = 0;
    persentTF.frame = CGRectMake(10, 10, 100, 40);
    persentTF.stringValue = @"百分比";
    self.persentTF = persentTF;
    [self.view addSubview:persentTF];
    
    // Do any additional setup after loading the view.
    NSButton *imagebutton  = [[NSButton alloc] init];
    [imagebutton setTitle:@"选择图片文件夹"];
    imagebutton.frame = CGRectMake(10, 65, 100, 30);
    imagebutton.target = self;
    [imagebutton setAction:@selector(selectImagesFiles)];
    [self.view addSubview:imagebutton];
}

- (void)selectImagesFiles
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    NSInteger finded = [panel runModal];
    if (finded == NSModalResponseOK) {
        NSString *path = panel.URLs.firstObject.path;
        [self readAndHandleImageWithDicPath:path];
        NSAlert * alert = [[NSAlert alloc]init];
        alert.messageText = @"完成";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        }];
    }
}

- (void)readAndHandleImageWithDicPath:(NSString *)path
{
    double rotio = self.persentTF.stringValue.doubleValue;
    NSLog(@"压缩比例 = %lf", rotio);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arr =  [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in arr) {
        NSString *first = [fileName substringToIndex:1];
        if ([first isEqualToString:@"."]) { //隐藏文件 过滤
            continue;
        }
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        if ([self isDirectory:filePath]) { //有子文件夹遍历子文件夹
            [self readAndHandleImageWithDicPath:filePath];
            continue;
        }
        NSString *last = [fileName componentsSeparatedByString:@"."].lastObject;
        if ([last isEqualToString:@"png"]) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:filePath];
            NSImage *newImage = [self resizedImage:image toPixelDimensions:CGSizeMake((int)(image.size.width * rotio), (int)(image.size.height * rotio))];
            [self saveImage:newImage toPath:filePath];
            
        }
        
    }
}

- (void )saveImage:(NSImage *)image toPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.8] forKey:NSImageCompressionFactor];
    NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:options];
    
//    NSData *imageData = [image TIFFRepresentation];
    //设定好文件路径后进行存储就ok了
    BOOL y = [imageData writeToFile:path atomically:YES];
    if (!y) {
        NSLog(@"写入失败 = %@", path);
    }
}

- (NSImage *)resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize
{
    if (! sourceImage.isValid) return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:newSize.width
                             pixelsHigh:newSize.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    return newImage;
}

- (BOOL)isDirectory:(NSString *)filePath
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
