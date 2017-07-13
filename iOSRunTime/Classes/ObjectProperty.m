//
//  ObjectProperty.m
//  iOSAppFramework
//
//  Created by FanChunxing on 2016/11/17.
//  Copyright © 2016年 itghost. All rights reserved.
//

#import "ObjectProperty.h"

#import <objc/runtime.h>

const char TChar            = 'c';
const char TUChar           = 'C';
const char TShort           = 's';
const char TUShort          = 'S';
const char TInt             = 'i';
const char TUInt            = 'I';
const char TLong            = 'q';
const char TULong           = 'Q';
const char TFloat           = 'f';
const char TDouble          = 'd';
const char TBool            = 'B';
const char TPointer         = '^';          // T^v void指针，以此类推。
const char TVoid            = 'v';          // Tv void成员，以此类推。
const char TObject          = '@';          // T@"NSString"
const char TFunction        = '?';          // T^?

@implementation ObjectProperty

- (void)dealloc {
    free((void *)self.type);
    free((void *)self.name);
    free((void *)self.getter);
    free((void *)self.setter);
}

+ (NSArray *)parseProperties:(Class)prototype {
    NSMutableArray *objectProperties = nil;
    uint32_t propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(prototype, &propertyCount);
    Class superClass = [prototype superclass];
    if (superClass != [NSObject class]) {
        objectProperties = (NSMutableArray *)[self parseProperties:superClass];
    }
    if (propertyCount) {
        if (!objectProperties) {
            objectProperties = [NSMutableArray arrayWithCapacity:propertyCount];
        }
        for (int propertyIndex = 0; propertyIndex < propertyCount; ++propertyIndex) {
            objc_property_t property = properties[propertyIndex];
            ObjectProperty *objectProperty = [ObjectProperty new];
            [objectProperties addObject:objectProperty];
            const char *propertyName = property_getName(property);
            objectProperty.name = [self copyString:propertyName];
            const char *propertyAttributes = property_getAttributes(property);
            NSLog(@"%s", propertyAttributes);
            unsigned int attributeCount = 0;
            objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
            for (uint32_t attributeIndex = 0; attributeIndex < attributeCount; ++attributeIndex) {
                objc_property_attribute_t attribute = attributes[attributeIndex];
                NSAssert(strlen(attribute.name), @"attribute.name is empty!");
                [self parseProperty:objectProperty key:attribute.name[0] value:attribute.value];
            }
            free(attributes);
        }
    }
    free(properties);
    return objectProperties;
}

+ (NSDictionary *)parsePropertiesInMap:(Class)prototype {
    NSArray *parseProperties = [self parseProperties:prototype];
    NSMutableDictionary *objectProperties = nil;
    if (parseProperties.count) {
        objectProperties = [NSMutableDictionary dictionaryWithCapacity:parseProperties.count];
        for (ObjectProperty *objectProperty in parseProperties) {
            NSString *key = [NSString stringWithCString:objectProperty.name encoding:NSASCIIStringEncoding];
            [objectProperties setObject:objectProperty forKey:key];
        }
    }
    return objectProperties;
}

typedef void (^FPParseProperty)(ObjectProperty *property, const char *value);

+ (void)parseProperty:(ObjectProperty *)property key:(const char)key value:(const char *)value {
    NSDictionary *syntaxTree = [self syntaxTree];
    FPParseProperty parseProperty = [syntaxTree objectForKey:@(key)];
    parseProperty(property, value);
}

+ (NSDictionary *)syntaxTree {
    return @{
             @(Property_Copy):^(ObjectProperty *property, const char *value) {
                 property.assign = Property_Copy;
             }, @(Property_Strong):^(ObjectProperty *property, const char *value) {
                 property.assign = Property_Strong;
             }, @(Property_Weak):^(ObjectProperty *property, const char *value) {
                 property.assign = Property_Weak;
             }, @(Property_ReadOnly):^(ObjectProperty *property, const char *value) {
                 property.access = Property_ReadOnly;
             }, @(Property_NonAutomic):^(ObjectProperty *property, const char *value) {
                 property.automic = Property_NonAutomic;
             }, @(Property_Dynamic):^(ObjectProperty *property, const char *value) {
                 property.synthesize = Property_Dynamic;
//             }, @(Property_PUnknow):^(ObjectProperty *property, const char *value) {
                 
             }, @(Property_Setter):^(ObjectProperty *property, const char *value) {
                 property.setter = [self copyString:value];
             }, @(Property_Getter):^(ObjectProperty *property, const char *value) {
                 property.getter = [self copyString:value];
             }, @(Property_Name):^(ObjectProperty *property, const char *value) {
                 property.ivarName = [self copyString:value];
             }, @(Property_Type):^(ObjectProperty *property, const char *value) {
                 const char *type = value + 2;
                 property.type = [self copyString:type length:strlen(type) - 1];
             }, @(property_type):^(ObjectProperty *property, const char *value) {
                 const char *type = value + 2;
                 property.type = [self copyString:type length:strlen(type) - 1];
             },
             };
}

+ (const char *)copyString:(const char *)value length:(size_t)length {
    const char *result = calloc(length + 1, 1);
    memcpy((void *)result, value, length);
    return result;
}

+ (const char *)copyString:(const char *)value {
    size_t size = strlen(value) + 1;
    const char *result = malloc(size);
    memcpy((void *)result, value, size);
    return result;
}

@end
