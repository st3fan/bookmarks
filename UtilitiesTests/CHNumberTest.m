/*
 CHMath.framework -- CHNumberTest.m
 
 Copyright (c) 2008-2009, Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */


#import "CHNumberTest.h"

@implementation CHNumberTest

- (void) setUp {
	return;
}

- (void) tearDown {
	return;
}

- (void) test01_construction {
	CHNumber * t = [CHNumber numberWithString:@"56"];
	NSString * binaryT = [t binaryStringValue];
	NSLog(@"Binary value of %@: %@", t, binaryT);
	
	CHNumber * n = [CHNumber number];
	XCTAssertNotNil(n, @"+[CHNumber number] failed");
	XCTAssertTrue([n integerValue] == 0, @"+[CHNumber number] failed (%@)", n);
	
	n = [CHNumber numberWithHexString:@"abc"];
	XCTAssertNotNil(n, @"+[CHNumber numberWithHexString:] failed");
	XCTAssertTrue([n integerValue] == 2748, @"+[CHNumber numberWithHexString:] failed (%@)", n);
	
	n = [CHNumber numberWithHexString:@"xyz"];
	XCTAssertNil(n, @"+[CHNumber numberWithHexString:] failed validation");
	
	n = [CHNumber numberWithInt:-42];
	XCTAssertNotNil(n, @"+[CHNumber numberWithInt:] failed");
	XCTAssertTrue([n integerValue] == -42, @"+[CHNumber numberWithInt:] failed (%@)", n);
	
	n = [CHNumber numberWithNumber:[NSNumber numberWithInt:42]];
	XCTAssertNotNil(n, @"+[CHNumber numberWithNumber:] failed");
	XCTAssertTrue([n integerValue] == 42, @"+[CHNumber numberWithInt:] failed (%@)", n);
	
	n = [CHNumber numberWithString:@"42"];
	XCTAssertNotNil(n, @"+[CHNumber numberWithString:] failed");
	XCTAssertTrue([n integerValue] == 42, @"+[CHNumber numberWithString:] failed (%@)", n);
	
	n = [CHNumber numberWithString:@"-42"];
	XCTAssertNotNil(n, @"+[CHNumber numberWithString:] failed");
	XCTAssertTrue([n integerValue] == -42, @"+[CHNumber numberWithString:] failed (%@)", n);
	
	n = [CHNumber numberWithString:@"abc"];
	XCTAssertNil(n, @"+[CHNumber numberWithString:] failed validation");
	
	n = [CHNumber numberWithUnsignedInt:42];
	XCTAssertNotNil(n, @"+[CHNumber numberWithUnsignedInt:] failed");
	XCTAssertTrue([n integerValue] == 42, @"+[CHNumber numberWithUnsignedInt:] failed (%@)", n);
}

- (void) test02_stringValues {
	CHNumber * n = [CHNumber numberWithInt:42];
	XCTAssertTrue([[n stringValue] isEqual:@"42"], @"stringValue");
	XCTAssertTrue([[n hexStringValue] isEqual:@"2a"], @"hexStringValue");
	NSString * binary = [n binaryStringValue];
	NSString * exp = @"0101010";
	NSLog(@"%lu =? %lu", (unsigned long)[binary length], (unsigned long)[exp length]);
	XCTAssertTrue([binary isEqual:exp], @"binaryStringValue");
	
	n = [CHNumber numberWithInt:-42];
	XCTAssertTrue([[n stringValue] isEqual:@"-42"], @"stringValue");
	XCTAssertTrue([[n hexStringValue] isEqual:@"-2a"], @"hexStringValue");
	XCTAssertTrue([[n binaryStringValue] isEqual:@"1010110"], @"binaryStringValue");
}

- (void) testDataValues1 {
    unsigned char bytes[] = {0x01};
    NSString *string = @"1";
    

    XCTAssertEqualObjects(
        [CHNumber numberWithData: [NSData dataWithBytes: bytes length: sizeof bytes]],
        [CHNumber numberWithString: string]
    );
}

- (void) testDataValues2 {
    XCTAssertEqualObjects(
        [CHNumber numberWithHexString: @"11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff"],
        [CHNumber numberWithString: @"7749745057451750595652775467055142246966702284346501706963511447954841792255"]
    );
}

- (void) testDataValues3 {
    unsigned char bytes[] = {0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0x00,0xaa,0xbb,0xcc,0xdd,0xee,0xff,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0x00,0xaa,0xbb,0xcc,0xdd,0xee,0xff};
    XCTAssertEqualObjects(
        [CHNumber numberWithData: [NSData dataWithBytes: bytes length: sizeof bytes]],
        [CHNumber numberWithString: @"7749745057451750595652775467055142246966702284346501706963511447954841792255"]
    );
}

- (void) test_factorization {
	CHNumber * n = [CHNumber numberWithInt:42];
	NSArray * factors = [[n factors] valueForKey:@"stringValue"];
	NSArray * expected = [NSArray arrayWithObjects:@"2", @"3", @"7", nil];
	XCTAssertTrue([factors isEqual:expected], @"-[CHNumber factors] failed (%@)", factors);
	
	n = [CHNumber numberWithInt:137];
	factors = [[n factors] valueForKey:@"stringValue"];
	expected = [NSArray array];
	XCTAssertTrue([factors isEqual:expected], @"-[CHNumber factors] failed (%@)", factors);
}

- (void) test_zero {
	CHNumber * n = [CHNumber number];
	XCTAssertTrue([n isZero], @"isZero");
	
	n = [CHNumber numberWithInt:1];
	XCTAssertFalse([n isZero], @"isZero");
}

- (void) test_one {
	CHNumber * n = [CHNumber number];
	XCTAssertFalse([n isOne], @"isOne");
	
	n = [CHNumber numberWithInt:1];
	XCTAssertTrue([n isOne], @"isOne");
}

- (void) test_negative {
	CHNumber * n = [CHNumber numberWithInt:1];
	XCTAssertFalse([n isNegative], @"isNegative");
	
	n = [CHNumber numberWithInt:0];
	XCTAssertFalse([n isNegative], @"isNegative");
	
	n = [CHNumber numberWithInt:-1];
	XCTAssertTrue([n isNegative], @"isNegative");
}

- (void) test_positive {
	CHNumber * n = [CHNumber numberWithInt:1];
	XCTAssertTrue([n isPositive], @"isPositive");
	
	n = [CHNumber numberWithInt:0];
	XCTAssertTrue([n isPositive], @"isPositive");
	
	n = [CHNumber numberWithInt:-1];
	XCTAssertFalse([n isPositive], @"isPositive");
}

- (void) test_prime {
	CHNumber * n = [CHNumber numberWithInt:17];
	XCTAssertTrue([n isPrime], @"isPrime");
	
	//561 is a Carmichael number and fails Fermat's little theorem
	n = [CHNumber numberWithInt:561];
	XCTAssertFalse([n isPrime], @"isPrime");
}

- (void) test_odd {
	CHNumber * n = [CHNumber numberWithInt:39];
	XCTAssertTrue([n isOdd], @"isOdd");
	
	n = [CHNumber numberWithInt:42];
	XCTAssertFalse([n isOdd], @"isOdd");
}

- (void) test_even {
	CHNumber * n = [CHNumber numberWithInt:39];
	XCTAssertFalse([n isEven], @"isEven");
	
	n = [CHNumber numberWithInt:42];
	XCTAssertTrue([n isEven], @"isEven");
}

- (void) test_greaterThan {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertTrue([three isGreaterThanNumber:n1], @"isGreaterThanNumber:");
	XCTAssertTrue([three isGreaterThanNumber:one], @"isGreaterThanNumber:");
	XCTAssertTrue([n1 isGreaterThanNumber:one], @"isGreaterThanNumber:");
	
	XCTAssertFalse([one isGreaterThanNumber:n1], @"isGreaterThanNumber:");
	XCTAssertFalse([n1 isGreaterThanNumber:n2], @"isGreaterThanNumber:");
	XCTAssertFalse([n1 isGreaterThanNumber:three], @"isGreaterThanNumber:");
}

- (void) test_greaterThanOrEqual {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertTrue([three isGreaterThanOrEqualToNumber:n1], @"isGreaterThanOrEqualToNumber:");
	XCTAssertTrue([three isGreaterThanOrEqualToNumber:one], @"isGreaterThanOrEqualToNumber:");
	XCTAssertTrue([n1 isGreaterThanOrEqualToNumber:one], @"isGreaterThanOrEqualToNumber:");
	XCTAssertTrue([n1 isGreaterThanOrEqualToNumber:n2], @"isGreaterThanOrEqualToNumber:");
	
	XCTAssertFalse([one isGreaterThanOrEqualToNumber:n1], @"isGreaterThanOrEqualToNumber:");
	XCTAssertFalse([n1 isGreaterThanOrEqualToNumber:three], @"isGreaterThanOrEqualToNumber:");
}

- (void) test_lessThan {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertFalse([three isLessThanNumber:n1], @"isLessThanNumber:");
	XCTAssertFalse([three isLessThanNumber:one], @"isLessThanNumber:");
	XCTAssertFalse([n1 isLessThanNumber:one], @"isLessThanNumber:");
	XCTAssertFalse([n1 isLessThanNumber:n2], @"isLessThanNumber:");
	
	XCTAssertTrue([one isLessThanNumber:n1], @"isLessThanNumber:");
	XCTAssertTrue([n1 isLessThanNumber:three], @"isLessThanNumber:");
}

- (void) test_lessThanOrEqual {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertFalse([three isLessThanOrEqualToNumber:n1], @"isLessThanOrEqualToNumber:");
	XCTAssertFalse([three isLessThanOrEqualToNumber:one], @"isLessThanOrEqualToNumber:");
	XCTAssertFalse([n1 isLessThanOrEqualToNumber:one], @"isLessThanOrEqualToNumber:");
	
	XCTAssertTrue([n1 isLessThanOrEqualToNumber:n2], @"isLessThanOrEqualToNumber:");
	XCTAssertTrue([one isLessThanOrEqualToNumber:n1], @"isLessThanOrEqualToNumber:");
	XCTAssertTrue([n1 isLessThanOrEqualToNumber:three], @"isLessThanOrEqualToNumber:");
}

- (void) test_equal {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertFalse([n1 isEqualToNumber:one], @"isEqualToNumber:");
	XCTAssertFalse([n1 isEqualToNumber:three], @"isEqualToNumber:");
	XCTAssertFalse([one isEqualToNumber:n1], @"isEqualToNumber:");
	XCTAssertFalse([three isEqualToNumber:n1], @"isEqualToNumber:");
	XCTAssertFalse([three isEqualToNumber:one], @"isEqualToNumber:");
	
	XCTAssertTrue([n1 isEqualToNumber:n2], @"isEqualToNumber:");
}

- (void) test_compare {
	CHNumber * n1 = [CHNumber numberWithInt:2];
	CHNumber * n2 = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * one = [CHNumber numberWithInt:1];
	
	XCTAssertTrue([n1 compare:n2] == NSOrderedSame, @"compareTo:");
	XCTAssertTrue([n1 compare:one] == NSOrderedDescending, @"compareTo:");
	XCTAssertTrue([n1 compare:three] == NSOrderedAscending, @"compareTo:");
}

- (void) test_modularDivision {
	CHNumber * n = [CHNumber numberWithInt:42];
	CHNumber * m = [CHNumber numberWithInt:5];
	
	CHNumber * r = [n numberByModding:m];
	XCTAssertTrue([r integerValue] == 2, @"numberByModding:");
	
	r = [n numberByInverseModding:m];
	//(42 * result) % 5 == 1
	XCTAssertTrue([r integerValue] == 3, @"numberByInverseModding:");
	
	r = [n numberByModding:[CHNumber numberWithInt:-5]];
	XCTAssertTrue([r integerValue] == 2, @"numberByModding:");
}

- (void) test_addition {
	CHNumber * one = [CHNumber numberWithInt:1];
	CHNumber * two = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	
	CHNumber * r = [one numberByAdding:two];
	XCTAssertTrue([r integerValue] == 3, @"numberByAdding:");
	
	CHNumber * ten = [CHNumber numberWithInt:10];
	r = [ten numberByAdding:three mod:two];
	XCTAssertTrue([r integerValue] == 1, @"numberByAdding:mod:");
}

- (void) test_subtraction {
	CHNumber * two = [CHNumber numberWithInt:2];
	CHNumber * three = [CHNumber numberWithInt:3];
	
	CHNumber * r = [three numberBySubtracting:two];
	XCTAssertTrue([r integerValue] == 1, @"numberBySubtracting:");
	
	CHNumber * ten = [CHNumber numberWithInt:10];
	r = [ten numberBySubtracting:three mod:two];
	XCTAssertTrue([r integerValue] == 1, @"numberBySubtracting:mod:");
}

- (void) test_multiplication {
	CHNumber * three = [CHNumber numberWithInt:3];
	CHNumber * seven = [CHNumber numberWithInt:7];
	
	CHNumber * r = [three numberByMultiplyingBy:seven];
	XCTAssertTrue([r integerValue] == 21, @"numberByMultiplyingBy:");
	
	CHNumber * two = [CHNumber numberWithInt:2];
	
	r = [three numberByMultiplyingBy:seven mod:two];
	XCTAssertTrue([r integerValue] == 1, @"numberByMultiplyingBy:mod:");
}

- (void) test_division {
	CHNumber * twentyone = [CHNumber numberWithInt:21];
	CHNumber * three = [CHNumber numberWithInt:3];
	
	CHNumber * r = [twentyone numberByDividingBy:three];
	XCTAssertTrue([r integerValue] == 7, @"numberByDividingBy:");
	
	//division is integer division, and results are rounded down
	CHNumber * four = [CHNumber numberWithInt:4];
	r = [twentyone numberByDividingBy:four];
	XCTAssertTrue([r integerValue] == 5, @"numberByDividingBy:");
}

- (void) test_squaring {
	CHNumber * two = [CHNumber numberWithInt:2];
	
	CHNumber * r = [two squaredNumber];
	XCTAssertTrue([r integerValue] == 4, @"squaredNumber");
	
	CHNumber * three = [CHNumber numberWithInt:3];
	
	r = [two squaredNumberMod:three];
	XCTAssertTrue([r integerValue] == 1, @"squaredNumberMod:");
}

- (void) test_exponents {
	CHNumber * two = [CHNumber numberWithInt:2];
	CHNumber * five = [CHNumber numberWithInt:5];
	
	CHNumber * r = [two numberByRaisingToPower:five];
	XCTAssertTrue([r integerValue] == 32, @"numberByRaisingToPower:");
	
	CHNumber * three = [CHNumber numberWithInt:3];
	r = [two numberByRaisingToPower:five mod:three];
	XCTAssertTrue([r integerValue] == 2, @"numberByRaisingToPower:mod:");
}

- (void) test_negation {
	CHNumber * n = [CHNumber numberWithInt:42];
	
	CHNumber * r = [n negatedNumber];
	XCTAssertTrue([r integerValue] == -42, @"negatedNumber");
}

- (void) test_bitSet {
	CHNumber * thirteen = [CHNumber numberWithInt:13];
	NSUInteger iThirteen = 13;
	for (int i = 0; i < sizeof(NSUInteger)*8; ++i) {
		BOOL isBitSet = (iThirteen >> i) & 1;
		XCTAssertTrue([thirteen isBitSet:i] == isBitSet, @"isBitSet:");
	}
}

- (void) test_bitShiftLeft {
	CHNumber * three = [CHNumber numberWithInt:3];
	
	CHNumber * r = [three numberByShiftingLeftOnce];
	XCTAssertTrue([r integerValue] == 6, @"numberByShiftingLeftOnce");
	
	r = [three numberByShiftingLeft:3];
	XCTAssertTrue([r integerValue] == 24, @"numberByShiftingLeft:");
}

- (void) test_bitShiftRight {
	CHNumber * twentyfour = [CHNumber numberWithInt:24];
	
	CHNumber * r = [twentyfour numberByShiftingRightOnce];
	XCTAssertTrue([r integerValue] == 12, @"numberByShiftingRightOnce");
	
	r = [twentyfour numberByShiftingRight:3];
	XCTAssertTrue([r integerValue] == 3, @"numberByShiftingRight:");
}

- (void) test_bitMasking {
	CHNumber * thirteen = [CHNumber numberWithInt:13];
	
	CHNumber * r = [thirteen numberByMaskingWithInt:3];
	XCTAssertTrue([r integerValue] == 5, @"numberByMaskingWithInt:");
}

#pragma mark - Some Practical Tests

- (void) testSomePracticalMath
{
    {
        CHNumber *a = [CHNumber numberWithString: @"7749745057451750595652775467055142246966702284346501706963511447954841792255"];

        NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
        CHNumber *N = [CHNumber numberWithHexString: Ns];
        
        // g = 2
        CHNumber *g = [CHNumber numberWithInt: 2];
        
        // A = pow(g, self.a, N)
        CHNumber *A = [g numberByRaisingToPower: a mod: N];
        XCTAssertEqualObjects([A stringValue], @"5315792223274871908341719856356461224693833615588533234332712711986475774935693842262255487614110535620934041878285782198521382592030693269851605708054101462119312204478591935800598072856011881887468654910468318568902326100459704222437087644383941292745616978042837076451981888179980036782868574752493658383143316237517558570740337151012017347258571208986167053278002743125067247007431337743093030807930939428843125750143524958920569550213540810788444668240810818157414478735882113078400177582590413459712455997746581251640655770520928254493056985125873087580171216304968636531858751194605991258802898107337387249123");
    }
    
    {
        CHNumber *a = [CHNumber numberWithHexString: @"11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff"];

        NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
        CHNumber *N = [CHNumber numberWithHexString: Ns];
        
        // g = 2
        CHNumber *g = [CHNumber numberWithInt: 2];
        
        // A = pow(g, self.a, N)
        CHNumber *A = [g numberByRaisingToPower: a mod: N];
        XCTAssertEqualObjects([A stringValue], @"5315792223274871908341719856356461224693833615588533234332712711986475774935693842262255487614110535620934041878285782198521382592030693269851605708054101462119312204478591935800598072856011881887468654910468318568902326100459704222437087644383941292745616978042837076451981888179980036782868574752493658383143316237517558570740337151012017347258571208986167053278002743125067247007431337743093030807930939428843125750143524958920569550213540810788444668240810818157414478735882113078400177582590413459712455997746581251640655770520928254493056985125873087580171216304968636531858751194605991258802898107337387249123");
    }

    {
        unsigned char Abytes[] = {
            0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0x00,0xaa,0xbb,0xcc,0xdd,0xee,0xff,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0x00,0xaa,0xbb,0xcc,0xdd,0xee,0xff
        };

        CHNumber *a = [CHNumber numberWithData: [NSMutableData dataWithBytes: Abytes length: 32]];

        NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
        CHNumber *N = [CHNumber numberWithHexString: Ns];
        
        // g = 2
        CHNumber *g = [CHNumber numberWithInt: 2];
        
        // A = pow(g, self.a, N)
        CHNumber *A = [g numberByRaisingToPower: a mod: N];
        XCTAssertEqualObjects([A stringValue], @"5315792223274871908341719856356461224693833615588533234332712711986475774935693842262255487614110535620934041878285782198521382592030693269851605708054101462119312204478591935800598072856011881887468654910468318568902326100459704222437087644383941292745616978042837076451981888179980036782868574752493658383143316237517558570740337151012017347258571208986167053278002743125067247007431337743093030807930939428843125750143524958920569550213540810788444668240810818157414478735882113078400177582590413459712455997746581251640655770520928254493056985125873087580171216304968636531858751194605991258802898107337387249123");
    }
}

@end
