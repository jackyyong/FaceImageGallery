//
//  TTFaceIndexCollectionViewLayout.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewFlowLayout.h"
#import "TTIndexCollectionViewLayoutAttributes.h"

@interface TTIndexCollectionViewFlowLayout()

@property (nonatomic, strong) NSDictionary *shelfRects;

@end

@implementation TTIndexCollectionViewFlowLayout

- (id)init
{
    self = [super init];
    if (self)
        {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = (CGSize){100, 100};
        // 定义缩进, 上左下右, 即左右各10个像素
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
            //self.headerReferenceSize = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad? (CGSize){50, 50} : (CGSize){43, 43}; // 100
            //self.footerReferenceSize = (CGSize){44, 44}; // 88
        self.minimumInteritemSpacing = 0; // 40;
        self.minimumLineSpacing = 0;//40;
         //TODO
        //[self registerClass:[ShelfView class] forDecorationViewOfKind:[ShelfView kind]];
        
    }
    return self;
}

+ (Class)layoutAttributesClass
{
    return [TTIndexCollectionViewLayoutAttributes class];
}

// Do all the calculations for determining where shelves go here
- (void)prepareLayout
{
    // call super so flow layout can do all the math for cells, headers, and footers
    [super prepareLayout];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
   // 如果垂直
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
        {
        // 获取分组数量
        NSInteger sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        
        int itemsAcross = floorf((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        // 遍历每一个分组
        for (int section = 0; section < sectionCount; section++) {
            // 加上header高度
            y += self.headerReferenceSize.height;
            // 加上top缩进
            y += self.sectionInset.top;
            // 获取当前分组数量
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            // 计算出当前分组的行数
            int rows = ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++) {
                y += self.itemSize.height;
                // Rect x = 0, y = y -32; width = self.collectionViewContentSize.width, 返回collectionView的内容的尺寸
                // Height=37
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] = [NSValue valueWithCGRect:CGRectMake(0, y - 32, self.collectionViewContentSize.width, 37)];
                
                //如果不是最后一行, 则加上行间距
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            
                y += self.sectionInset.bottom;
                y += self.footerReferenceSize.height;
            }
        } else {
        // Calculate where shelves go in a horizontal layout - 如果水平
        CGFloat y = self.sectionInset.top;
        CGFloat availableHeight = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom);
        int itemsAcross = floorf((availableHeight + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing));
        CGFloat interval = ((availableHeight - self.itemSize.height) / (itemsAcross <= 1? 1 : itemsAcross - 1)) - self.itemSize.height;
        for (int row = 0; row < itemsAcross; row++) {
            y += self.itemSize.height;
            dictionary[[NSIndexPath indexPathForItem:row inSection:0]] = [NSValue valueWithCGRect:CGRectMake(0, roundf(y - 32), self.collectionViewContentSize.width, 37)];
            
            y += interval;
            }
        }
    
    self.shelfRects = [NSDictionary dictionaryWithDictionary:dictionary];
}

// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
        // call super so flow layout can return default attributes for all cells, headers, and footers
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
        // tweak the attributes slightly
    for (UICollectionViewLayoutAttributes *attributes in array)
        {
        attributes.zIndex = 1;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
            {
                // make label vertical if scrolling is horizontal
            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
            }
        
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView && [attributes isKindOfClass:[TTIndexCollectionViewLayoutAttributes class]])
            {
            TTIndexCollectionViewLayoutAttributes *conferenceAttributes = (TTIndexCollectionViewLayoutAttributes *)attributes;
            conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
            }
        }
    
        // Add our decoration views (shelves)
    NSMutableArray *newArray = [array mutableCopy];
    
    /*[self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect)) {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:key];
            attributes.frame = [obj CGRectValue];
            attributes.zIndex = 0;
                //attributes.alpha = 0.5; // screenshots
            [newArray addObject:attributes];
         }
    }];*/
    
    array = [NSArray arrayWithArray:newArray];
    
    return array;
}

// 特定cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.zIndex = 1;
    return attributes;
}

// header 或 footer的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
   /* if ([kind isEqualToString:[SmallConferenceHeader kind]])
        return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    attributes.zIndex = 1;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
        {
            // make label vertical if scrolling is horizontal
        attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
        attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
        }
    
    if ([attributes isKindOfClass:[TTIndexCollectionViewLayoutAttributes class]]) {
        TTIndexCollectionViewLayoutAttributes *conferenceAttributes = (TTIndexCollectionViewLayoutAttributes *)attributes;
        conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
     }
    
    return attributes;*/
    return nil;
}

// 装饰视图的布局属性layout attributes for a specific decoration view
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    /*id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil; // no shelf at this index (this is probably an error)
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0; // shelves go behind other views
    
    return attributes;*/
    return nil;
}

@end
