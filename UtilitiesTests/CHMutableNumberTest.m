/*
 CHMath.framework -- CHMutableNumberTest.m
 
 Copyright (c) 2008-2009, Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */


#import "CHMutableNumberTest.h"

@implementation CHMutableNumberTest

- (void) setUp {
	return;
}

- (void) tearDown {
	return;
}

- (void) test_setAndClear {
	CHMutableNumber * n = [CHMutableNumber number];
	[n setIntegerValue:42];
	XCTAssertTrue([n integerValue] == 42, @"setIntegerValue:");
	
	[n setStringValue:@"138"];
	XCTAssertTrue([n integerValue] == 138, @"setStringValue:");
	
	[n setHexStringValue:@"2A"];
	XCTAssertTrue([n integerValue] == 42, @"setHexStringValue:");
	
	[n clear];
	XCTAssertTrue([n integerValue] == 0, @"clear");
}

- (void) test_modularDivision {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:42];
	[n modByInteger:4];
	XCTAssertTrue([n integerValue] == 2, @"modByInteger:");
	
	n = [CHMutableNumber numberWithInt:42];
	CHNumber * mod = [CHNumber numberWithInt:9];
	[n modByNumber:mod];
	XCTAssertTrue([n integerValue] == 6, @"modByNumber:");
}

- (void) test_addition {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:42];
	[n addInteger:17];
	XCTAssertTrue([n integerValue] == 59, @"addInteger:");
	
	[n addNumber:[CHNumber numberWithInt:17]];
	XCTAssertTrue([n integerValue] == 76, @"addNumber:");
	
	[n addNumber:[CHNumber numberWithInt:1] mod:[CHNumber numberWithInt:3]];
	XCTAssertTrue([n integerValue] == 2, @"addNumber:mod:");
	
}

- (void) test_subtraction {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:42];
	[n subtractInteger:17];
	XCTAssertTrue([n integerValue] == 25, @"subtractInteger:");
	
	[n subtractNumber:[CHNumber numberWithInt:17]];
	XCTAssertTrue([n integerValue] == 8, @"subtractNumber:");
	
	[n subtractNumber:[CHNumber numberWithInt:1] mod:[CHNumber numberWithInt:3]];
	XCTAssertTrue([n integerValue] == 1, @"subtractNumber:mod:");
}

- (void) test_multiplication {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:7];
	[n multiplyByInteger:3];
	XCTAssertTrue([n integerValue] == 21, @"multiplyByInteger:");
	
	[n multiplyByNumber:[CHNumber numberWithInt:2]];
	XCTAssertTrue([n integerValue] == 42, @"multiplyByNumber:");
	
	[n multiplyByNumber:[CHNumber numberWithInt:2] mod:[CHNumber numberWithInt:5]];
	XCTAssertTrue([n integerValue] == 4, @"multiplyByNumber:mod:");
}

- (void) test_division {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:21];
	[n divideByInteger:3];
	XCTAssertTrue([n integerValue] == 7, @"divideByInteger:");
	
	//division is integer division, and results are rounded down
	n = [CHMutableNumber numberWithInt:21];
	[n divideByInteger:4];
	XCTAssertTrue([n integerValue] == 5, @"divideByInteger:");
	
	n = [CHMutableNumber numberWithInt:21];
	[n divideByNumber:[CHNumber numberWithInt:3]];
	XCTAssertTrue([n integerValue] == 7, @"divideByInteger:");
	
	//division is integer division, and results are rounded down
	n = [CHMutableNumber numberWithInt:21];
	[n divideByNumber:[CHNumber numberWithInt:4]];
	XCTAssertTrue([n integerValue] == 5, @"divideByInteger:");
}

- (void) test_squaring {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:2];
	[n square];
	XCTAssertTrue([n integerValue] == 4, @"square");
	
	n = [CHMutableNumber numberWithInt:3];
	CHNumber * mod = [CHNumber numberWithInt:4];
	[n squareMod:mod];
	XCTAssertTrue([n integerValue] == 1, @"squareMod:");
}

- (void) test_exponents {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:2];
	[n raiseToInteger:5];
	XCTAssertTrue([n integerValue] == 32, @"raiseToInteger:");
	
	n = [CHMutableNumber numberWithInt:2];
	[n raiseToNumber:[CHNumber numberWithInt:5]];
	XCTAssertTrue([n integerValue] == 32, @"raiseToNumber:");
	
	n = [CHMutableNumber numberWithInt:2];
	[n raiseToNumber:[CHNumber numberWithInt:5] mod:[CHNumber numberWithInt:3]];
	XCTAssertTrue([n integerValue] == 2, @"raiseToNumber:mod:");
}

- (void) test_negation {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:-42];
	[n negate];
	XCTAssertTrue([n integerValue] == 42, @"negate");
	
	[n negate];
	XCTAssertTrue([n integerValue] == -42, @"negate");
	
}

- (void) test_bitSetting {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:15];
	[n setBit:0];
	XCTAssertTrue([n integerValue] == 15, @"setBit:");
	
	[n clearBit:0];
	XCTAssertTrue([n integerValue] == 14, @"clearBit:");
	
	[n flipBit:1];
	XCTAssertTrue([n integerValue] == 12, @"flipBit:");
}

- (void) test_bitShiftLeft {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:3];
	[n shiftLeftOnce];
	XCTAssertTrue([n integerValue] == 6, @"shiftLeftOnce");
	
	n = [CHMutableNumber numberWithInt:3];
	[n shiftLeft:3];
	XCTAssertTrue([n integerValue] == 24, @"shiftLeft:");
}

- (void) test_bitShiftRight {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:24];
	[n shiftRightOnce];
	XCTAssertTrue([n integerValue] == 12, @"shiftRightOnce");
	
	n = [CHMutableNumber numberWithInt:24];
	[n shiftRight:3];
	XCTAssertTrue([n integerValue] == 3, @"shiftRight:");
}

- (void) test_bitMasking {
	CHMutableNumber * n = [CHMutableNumber numberWithInt:13];
	[n maskWithInt:3];
	XCTAssertTrue([n integerValue] == 5, @"maskWithInt:");
}

@end
