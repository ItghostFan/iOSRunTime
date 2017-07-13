//
//  ObjectProperty.h
//  iOSAppFramework
//
//  Created by FanChunxing on 2016/11/17.
//  Copyright © 2016年 itghost. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Do not support reference under.
 * P            The property is eligible for garbage collection.
 * t<encoding>  Specifies the type using old-style encoding.
 * Ivar.
 */

typedef NS_ENUM(unsigned char, PropertyAssign) {
    Property_Assign         = '\0',
    Property_Copy           = 'C',
    Property_Strong         = '&',
    Property_Weak           = 'W',
};

typedef NS_ENUM(unsigned char, PropertyAccess) {
    Property_ReadWirte      = '\0',
    Property_ReadOnly       = 'R',
};

typedef NS_ENUM(unsigned char, PropertyAutomic) {
    Property_Automic        = '\0',
    Property_NonAutomic     = 'N',
};

typedef NS_ENUM(unsigned char, PropertySynthesize) {
    Property_Synthesize     = '\0',
    Property_Dynamic        = 'D',
};

typedef NS_ENUM(unsigned char, PropertyType) {
    Property_Type           = 'T',
    property_type           = 't',          // Old version.
};

typedef NS_ENUM(unsigned char, PropertyUnknow) {
    Property_PUnknow        = 'P',
};

typedef NS_ENUM(unsigned char, PropertyName) {
    Property_Name           = 'V',
};

typedef NS_ENUM(unsigned char, Propertyer) {
    Property_Setter           = 'S',
    Property_Getter           = 'G',
};

extern const char TChar;
extern const char TUChar;
extern const char TShort;
extern const char TUShort;
extern const char TInt;
extern const char TUInt;
extern const char TLong;
extern const char TULong;
extern const char TFloat;
extern const char TDouble;
extern const char TBool;
extern const char TPointer;             // T^v void指针，以此类推。
extern const char TVoid;                // Tv void成员，以此类推。
extern const char TObject;              // T@"NSString"
extern const char TFunction;            // T^?

@interface ObjectProperty : NSObject

@property (assign, nonatomic) const char *type;
@property (assign, nonatomic) const char *ivarName;                 // Ivar set.
@property (assign, nonatomic) const char *name;
@property (assign, nonatomic) PropertyAssign assign;
@property (assign, nonatomic) PropertyAccess access;
@property (assign, nonatomic) PropertySynthesize synthesize;
@property (assign, nonatomic) PropertyAutomic automic;
@property (assign, nonatomic) const char *getter;
@property (assign, nonatomic) const char *setter;

+ (NSArray *)parseProperties:(Class)prototype
__attribute((deprecated("Use propertiesOfClass:prototype instead.")));
+ (NSDictionary *)parsePropertiesInMap:(Class)prototype
__attribute((deprecated("Use namedPropertiesOfClass:prototype instead.")));

+ (NSArray *)propertiesOfClass:(Class)prototype;
+ (NSDictionary *)namedPropertiesOfClass:(Class)prototype;

@end
