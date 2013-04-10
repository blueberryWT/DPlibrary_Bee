//
//	 ______    ______    ______    
//	/\  __ \  /\  ___\  /\  ___\   
//	\ \  __<  \ \  __\_ \ \  __\_ 
//	 \ \_____\ \ \_____\ \ \_____\ 
//	  \/_____/  \/_____/  \/_____/ 
//
//	Copyright (c) 2012 BEE creators
//	http://www.whatsbug.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the "Software"),
//	to deal in the Software without restriction, including without limitation
//	the rights to use, copy, modify, merge, publish, distribute, sublicense,
//	and/or sell copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//	IN THE SOFTWARE.
//
//
//  Bee_ActiveRecordTest.h
//

#import "Bee.h"

#if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__

#pragma mark -

@interface User : BeeActiveRecord
{
	NSNumber *	_uid;
	NSString *	_name;
	NSString *	_gender;
	NSString *	_city;
	NSDate *	_birth;
}

@property (nonatomic, retain) NSNumber *	uid;
@property (nonatomic, retain) NSString *	name;
@property (nonatomic, retain) NSString *	gender;
@property (nonatomic, retain) NSString *	city;
@property (nonatomic, retain) NSDate *		birth;

@end

#pragma mark -

@implementation User

@synthesize uid = _uid;
@synthesize name = _name;
@synthesize gender = _gender;
@synthesize city = _city;
@synthesize birth = _birth;

@end

#pragma mark -

TEST_CASE(BeeActiveRecord_BeeDatabase)
{
	// Clear table
	
	User.DB.EMPTY();
	
	// Insert 2 records into table 'table_User'
	
	User.DB
	.SET( @"name", @"gavin" )
	.SET( @"gender", @"male" )
	.INSERT();
	
	User.DB
	.SET( @"name", @"amanda" )
	.SET( @"gender", @"female" )
	.SET( @"city", @"Columbus" )
	.SET( @"birth", [NSDate date] )
	.INSERT();
	
	// Update records
	
	User.DB
	.WHERE( @"name", @"gavin" )
	.SET( @"city", @"Columbus" )
	.UPDATE();
	
	// Query records
	
	User.DB.WHERE( @"city", @"Columbus" ).GET();	// Results are NSDictionary
	NSAssert( User.DB.succeed, @"" );
	NSAssert( User.DB.resultCount == 2, @"" );
	
	for ( NSDictionary * dict in User.DB.resultArray )
	{
		VAR_DUMP( dict );
	}
	
	// Delete records
	
	User.DB.WHERE( @"city", @"Columbus" ).DELETE();
	
	// Count records
	
	User.DB.COUNT();
	NSAssert( User.DB.succeed, @"" );
	NSAssert( User.DB.resultCount == 0, @"" );
}
TEST_CASE_END

#pragma mark -

TEST_CASE(BeeActiveRecord)
{
// Clear table

	User.DB.EMPTY();

// test
	
	User * me;
	User * copy;

	me = [User record];
	me.name = @"gavin";			// set value by property
	me.city = @"beijing";		// set value by property
	[me.JSON setObject:@"m" forKey:@"gender"];							// set value by JSON
	[me.JSON setObject:[[NSDate date] description] forKey:@"birth"];	// set value by JSON
	me.SAVE();

	NSAssert( [me.name isEqualToString:@"gavin"], @"" );							// get value by property
	NSAssert( [me.city isEqualToString:@"beijing"], @"" );							// get value by property
	NSAssert( [me.gender isEqualToString:@"m"], @"" );								// get value by property

	NSAssert( [[me.JSON objectForKey:@"name"] isEqualToString:@"gavin"], @"" );		// get value by JSON
	NSAssert( [[me.JSON objectForKey:@"city"] isEqualToString:@"beijing"], @"" );	// get value by JSON
	NSAssert( [[me.JSON objectForKey:@"gender"] isEqualToString:@"m"], @"" );		// get value by JSON

	VAR_DUMP( me.JSON );		// convert object to JSON object
	VAR_DUMP( me.JSONString );	// convert object to JSON string
	VAR_DUMP( me.JSONData );	// convert object to JSON data

// create by ActiveRecord

	copy = [User record:me];
	NSAssert( [copy.name isEqualToString:me.name], @"" );
	NSAssert( [copy.city isEqualToString:me.city], @"" );
	NSAssert( [copy.gender isEqualToString:me.gender], @"" );
	copy.INSERT();
	copy.DELETE();

// create by JSON

	copy = [User record:me.JSON];
	NSAssert( [copy.name isEqualToString:me.name], @"" );
	NSAssert( [copy.city isEqualToString:me.city], @"" );
	NSAssert( [copy.gender isEqualToString:me.gender], @"" );
	copy.INSERT();
	copy.DELETE();

// create by JSON String

	copy = [User record:me.JSONString];
	NSAssert( [copy.name isEqualToString:me.name], @"" );
	NSAssert( [copy.city isEqualToString:me.city], @"" );
	NSAssert( [copy.gender isEqualToString:me.gender], @"" );
	copy.INSERT();
	copy.DELETE();

// create by JSON Data

	copy = [User record:me.JSONData];
	NSAssert( [copy.name isEqualToString:me.name], @"" );
	NSAssert( [copy.city isEqualToString:me.city], @"" );
	NSAssert( [copy.gender isEqualToString:me.gender], @"" );
	copy.INSERT();
	copy.DELETE();

// create by String

	copy = [User record:@"{ \"name\" : \"gavin\", \"city\" : \"beijing\", \"gender\" : \"m\" }"];
	NSAssert( [copy.name isEqualToString:me.name], @"" );
	NSAssert( [copy.city isEqualToString:me.city], @"" );
	NSAssert( [copy.gender isEqualToString:me.gender], @"" );
	copy.INSERT();
	copy.DELETE();

	me.DELETE();
	
// Insert 2 records into table 'table_User'

	User * record1 = [User record];
	record1.name = @"gavin";
	record1.gender = @"male";
	record1.SAVE();

	User * record2 = [User record];
	record2.name = @"amanda";
	record2.gender = @"female";
	record2.city = @"Columbus";
	record2.birth = [NSDate date];
	record2.SAVE();
		
	VAR_DUMP( record1.JSON );
	VAR_DUMP( record1.JSONString );
	VAR_DUMP( record1.JSONData );
	
	[record1.JSON setObject:@"1234" forKey:@"undefinedKey"];
	[record1.JSON setObject:@"gavin.kwoe" forKey:@"name"];

// Update records

	record1.city = @"Columbus";
	record1.SAVE();		

// Query records
	
	User.DB.GET_RECORDS();	// Results are BeeActiveRecord
	NSAssert( User.DB.succeed, @"" );
	NSAssert( User.DB.resultCount > 0, @"" );

	for ( User * info in User.DB.resultArray )
	{
		VAR_DUMP( info );
	}

	User.DB.WHERE( @"city", @"Columbus" ).GET_RECORDS(); // Results are BeeActiveRecord
	NSAssert( User.DB.succeed, @"" );
	NSAssert( User.DB.resultCount == 2, @"" );
	
	for ( User * info in User.DB.resultArray )
	{
		VAR_DUMP( info );
	}

// Delete records

	record1.DELETE();
	record2.DELETE();

	User.DB.GET_RECORDS();	// Results are BeeActiveRecord
//	NSAssert( User.DB.succeed, @"" );
//	NSAssert( User.DB.resultCount == 0, @"" );
	
	for ( User * info in User.DB.resultArray )
	{
		VAR_DUMP( info );
	}
	
// Count records

	User.DB.COUNT();
	NSAssert( User.DB.succeed, @"" );
	NSAssert( User.DB.resultCount == 0, @"" );
}
TEST_CASE_END

#endif	// #if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__
