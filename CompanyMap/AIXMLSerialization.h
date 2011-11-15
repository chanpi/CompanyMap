//
//  AIXMLSerialization.h
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef CompanyMap_AIXMLSerialization_h
#define CompanyMap_AIXMLSerialization_h

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import "DDXML.h"

#ifndef NSXMLNode
#define NSXMLNode       DDXMLNode
#endif
#ifndef NSXMLElement
#define NSXMLElement    DDXMLElement
#endif
#ifndef NSXMLDocument
#define NSXMLDocument   DDXMLDocument
#endif

#ifndef NSXMLNodeKind
#define NSXMLInvalidKind                DDXXMLInvalidKind
#define NSXMLDocumentKind               DDXMLDocumentKind
#define NSXMLElementKind                DDXMLElementKind
#define NSXMLAttributeKind              DDXMLAttributeKind
#define NSXMLNamespaceKind              DDXMLNamespaceKind
#define NSXMLProcessingInstructionKind  DDXMLProcessingInstructionKind
#define NSXMLCommentKind                DDXMLCommentKind
#define NSXMLTextKind                   DDXMLTextKind
#define NSXMLDTDKind                    DDXMLDTDKind
#define NSXMLEntityDeclarationKind      DDXMLEntityDeclarationKind    
#define NSXMLAttributeDeclarationKind   DDXMLAttributeDeclarationKind 
#define NSXMLElementDeclarationKind     DDXMLElementDeclarationKind   
#define NSXMLNotationDeclarationKind    DDXMLNotationDeclarationKind  

#define NSXMLNodeKind                   DDXMLNodeKind
#endif

#ifndef NSXMLNodeOptionsNone
#define NSXMLNodeOptionsNone            DDXMLNodeOptionsNone        
#define NSXMLNodeExpandEmptyElement     DDXMLNodeExpandEmptyElement 
#define NSXMLNodeCompactEmptyElement    DDXMLNodeCompactEmptyElement
#define NSXMLNodePrettyPrint            DDXMLNodePrettyPrint 
#endif

#ifndef NSXMLDocumentXMLKind
#define NSXMLDocumentXMLKind            DDXMLDocumentXMLKind
#define NSXMLDocumentXHTMLKind          DDXMLDocumentXHTMLKind
#define NSXMLDocumentHTMLKind           DDXMLDocumentHTMLKind
#define NSXMLDocumentTextKind           DDXMLDocumentTextKind

#define NSXMLDocumentContentKind        DDXMLDocumentContentKind
#endif

#ifndef NSXMLDocumentTidyHTML
#define NSXMLDocumentTidyHTML 1 << 9
#define NSXMLDocumentTidyXML  1 << 10
#define NSXMLDocumentValidate 1 << 13
#define NSXMLDocumentXInclude 1 << 16
#endif

#endif

#import "AIXMLDocumentSerialize.h"
#import "AIXMLElementSerialize.h"

#endif
