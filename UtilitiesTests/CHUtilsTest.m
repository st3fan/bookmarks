/*
 CHMath.framework -- CHUtilsTest.m
 
 Copyright (c) 2008-2009, Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */


#import "CHUtilsTest.h"

@implementation CHUtilsTest

- (void)test_gcd {
	CHNumber * n = [CHNumber numberWithInt:39];
	CHNumber * s = [CHNumber numberWithInt:65];
	
	CHNumber * r = [CHUtils greatestCommonDivisorOf:n and:s];
	XCTAssertTrue([r integerValue] == 13, @"+[CHUtils greatestCommonDivisorOf:and:] failed (%@)", r);
	
	n = [CHNumber numberWithInt:17];
	s = [CHNumber numberWithInt:23];
	r = [CHUtils greatestCommonDivisorOf:n and:s];
	XCTAssertTrue([r integerValue] == 1, @"+[CHUtils greatestCommonDivisorOf:and:] failed (%@)", r);
}

- (void) test_primesUpTo {
	CHNumber * n = [CHNumber numberWithInt:43];
	NSArray * p = [[CHUtils primesUpTo:n] valueForKey:@"stringValue"];
	NSArray * expected = [NSArray arrayWithObjects:@"2", @"3", @"5", @"7", @"11", @"13", @"17", @"19", @"23", @"29", @"31", @"37", @"41", nil];
	XCTAssertTrue([p isEqual:expected], @"+[CHUtils primesUpTo:] failed (%@)", p);
}

@end
