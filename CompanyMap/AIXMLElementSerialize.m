//
//  AIXMLElementSerialize.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AIXMLElementSerialize.h"

@implementation NSXMLElement (Serialize)

// Should this be configurable?  Ruby's XmlSimple handles nodes with 
// string values and attributes by assigning the string value to a 
// 'content' key, although that seems like a pretty generic key which 
// could cause collisions if an element has a 'content' attribute.
static NSString* contentItem;

+ (void)initialize
{
    if (!contentItem) {
        contentItem = @"content";
    }
}

- (NSDictionary*)attributesAsDictionary
{
    NSArray* attributes = [self attributes];
    NSUInteger attributeCount = [attributes count];
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:attributeCount];
    
    uint i;
    for (i = 0; i < attributeCount; i++) {
        NSXMLNode* node = [attributes objectAtIndex:i];
        [result setObject:[node stringValue] forKey:[node name]];
    }
    return result;
}

- (NSMutableDictionary*)toDictionary
{
    id out, rawObject, nodeObject;
    NSXMLNode* node;
    NSArray* nodes = [self children];
    NSString* elementName = [self name];
    NSString* key;
    NSDictionary* attributes = [self attributesAsDictionary];
    NSString* type = [attributes valueForKey:@"type"];
    NSMutableDictionary* groups = [NSMutableDictionary dictionary];
    NSMutableArray* objects;
    
    for (node in nodes) {
        // It's an element, lets create the proper groups for these elements
        // consolidating any duplicate elements at this level.
        if([node kind] == NSXMLElementKind)
        {
            NSString *childName = [node name];
            NSMutableArray *group = [groups objectForKey:childName];
            if(!group)
            {
                group = [NSMutableArray array];
                [groups setObject:group forKey:childName];
            }
            
            [group addObject:node];
        } 
        
        // We're on a text node so the parent node will be this nodes name.
        // Once we get done parsing this text node we can go ahead and return 
        // its dictionary rep because there is no need for further processing.
        else if([node kind] == NSXMLTextKind) 
        {
            NSXMLElement *containerObject = (NSXMLElement *)[node parent];
            NSDictionary *nodeAttributes = [containerObject attributesAsDictionary]; 
            NSString *contents = [node stringValue];
            
            
            // If this node has attributes and content text we need to 
            // create a dictionary for it and use the static contentItem 
            // value as a place to store the stringValue.
            if([nodeAttributes count] > 0 && contents)
            {
                nodeObject = [NSMutableDictionary dictionaryWithObject:contents forKey:contentItem];
                [nodeObject addEntriesFromDictionary:nodeAttributes];
            }
            // Else this node only has a string value or is empty so we set 
            // it's value to a string.
            else
            {
                nodeObject = contents;
            }
            
            return [NSMutableDictionary dictionaryWithObject:nodeObject forKey:[containerObject name]];
        }
    }
    
    // Array
    // We have an element who says it's children should be treated as an array.
    // Instead of creating {:child_name => {:other, :attrs}} children, we create 
    // an array of anonymous dictionaries. [{:other, :attrs}, {:other, :attrs}]
    if ([type isEqualToString:@"array"]) {
        out = [NSMutableArray array];
        for (key in groups) {
            NSMutableDictionary* dictionaryRep;
            objects = [groups objectForKey:key];
            for (rawObject in objects) {
                dictionaryRep = [rawObject toDictionary];
                [out addObject:[dictionaryRep valueForKey:key]];
            }
        }
    }
    // Dictionary
    else {
        out = [NSMutableDictionary dictionary];
        for (key in groups) {
            NSMutableDictionary* dictionaryRep;
            objects = [groups objectForKey:key];
            if ([objects count] == 1) {
                dictionaryRep = [[objects objectAtIndex:0] toDictionary];
                [out addEntriesFromDictionary:dictionaryRep];
            } else {
                NSMutableArray* dictionaryCollection = [NSMutableArray array];
                for (rawObject in objects) {
                    dictionaryRep = [rawObject toDictionary];
                    id finalItems = [dictionaryRep valueForKey:key];
                    [dictionaryCollection addObject:finalItems];
                }
                
                [out setObject:dictionaryCollection forKey:key];
            }
        }
        
        if ([attributes count] > 0) {
            [out addEntriesFromDictionary:attributes];
        }
    }
    
    return [NSMutableDictionary dictionaryWithObject:out forKey:elementName];
}

@end





































