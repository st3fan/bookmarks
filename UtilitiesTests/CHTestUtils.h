//
//  CHTestUtils.h
//  CHMath
//
//  Created by Dave DeLong on 9/30/09.
//  Copyright 2009 Home. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CHMath.h"

#define ASSERTTRUE(expr,obj,sel) { \
XCTAssertTrue((expr), [NSString stringWithFormat:@"-[%@ %@] failed (%@)", NSStringFromClass([obj class]), sel, obj]); \
}

#define ASSERTFALSE(expr,obj,sel) { \
XCTAssertFalse(expr, [NSString stringWithFormat:@"-[%@ %@] failed (%@)", NSStringFromClass([obj class]), sel, obj]); \
}
