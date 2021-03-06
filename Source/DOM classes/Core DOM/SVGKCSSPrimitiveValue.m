#import "SVGKCSSPrimitiveValue.h"
#import "SVGKCSSValue_ForSubclasses.h"
#import "SVGKCSSPrimitiveValue_ConfigurablePixelsPerInch.h"

#import "SVGKDOMGlobalSettings.h"
#import "SVGKCGFloatAdditions.h"

#define INCHES_PER_CENTIMETRE ( (CGFloat)(0.393700787) )
#define INCHES_PER_MILLIMETER ( (CGFloat)(0.0393700787) )

@interface SVGKCSSPrimitiveValue()

@property(nonatomic) CGFloat internalValue;
@property(nonatomic,strong) NSString* internalString;

@end

@implementation SVGKCSSPrimitiveValue

@synthesize pixelsPerInch;

@synthesize internalValue;
@synthesize internalString;

@synthesize primitiveType;

- (instancetype)init
{
    self = [super initWithUnitType:CSS_PRIMITIVE_VALUE];
    if (self) {
		self.pixelsPerInch = 1.0; // this can be overridden by classes that import the CSSPrimitiveValue_ConfigurablePixelsPerInch.h header
    }
    return self;
}

-(void) setFloatValue:(CSSPrimitiveType) unitType floatValue:(CGFloat) floatValue
{
	self.primitiveType = unitType;
	self.internalValue = floatValue;
	
	self.internalString = nil;
}

-(CGFloat) getFloatValue:(CSSPrimitiveType) unitType
{
	/** Easy case: you're asking for the same unit as the originally stored units */
	if( unitType == self.primitiveType )
		return self.internalValue;
	
	switch( self.primitiveType )
	{
		case CSS_UNKNOWN:
		{
			if( self.internalValue == 0.0 )
				return self.internalValue;
			else
			{
				NSAssert( FALSE, @"Asked to convert a UNKNOWN value to a different type (%i)", unitType );
			}
		}
			
		case CSS_CM:
		case CSS_IN:
		case CSS_MM:
		case CSS_PT:
		case CSS_PC:
		{
			float valueAsInches = 0;
			switch( self.primitiveType )
			{
				case CSS_CM:
				{
					valueAsInches = self.internalValue * INCHES_PER_CENTIMETRE;
				}break;
				case CSS_MM:
				{
					valueAsInches = self.internalValue * INCHES_PER_MILLIMETER;
				}break;
				case CSS_PT:
				{
					valueAsInches = self.internalValue / 72.0;
				}break;
				case CSS_PC:
				{
					valueAsInches = self.internalValue * 12.0 / 72.0;
				}break;
				case CSS_IN:
				{
					valueAsInches = self.internalValue;
				}break;
					
				default:
				{
					NSAssert( FALSE, @"This line is impossible but Apple's compiler is crap" );
				}
			}
			
			switch( unitType )
			{
				case CSS_CM:
				{
					return valueAsInches / INCHES_PER_CENTIMETRE;
				}break;
				case CSS_MM:
				{
					return valueAsInches / INCHES_PER_MILLIMETER;
				}break;
				case CSS_PT:
				{
					return valueAsInches * 72.0;
				}break;
				case CSS_PC:
				{
					return valueAsInches / 12.0 * 72.0;
				}break;
				case CSS_PX:
				{
					return valueAsInches * self.pixelsPerInch;
				}break;
					
				default:
				{
					NSAssert( FALSE, @"Asked to convert a value in centimetres to an incompatible unit type (%i)", unitType );
				}
			}
		} break;
			
		case CSS_DEG:
		case CSS_GRAD:
		case CSS_RAD:
		{
			NSAssert( FALSE, @"Asked to convert an Angle value to a different type (NO conversions for this type are currently supported) (%i)", unitType );
		} break;
			
		case CSS_COUNTER:
		{
			NSAssert( FALSE, @"Asked to convert a Counter value to a different type (NO conversions for this type are currently supported) (%i)", unitType );
		} break;
			
		case CSS_DIMENSION:
		{
			NSAssert( FALSE, @"Asked to convert a Dimension value to a different type (NO conversions for this type are currently supported) (%i)", unitType );
		} break;
			
		case CSS_EMS:
		case CSS_EXS:
		case CSS_PX:
		{
			NSAssert( FALSE, @"Asked to convert a Relative Length value to a different type (NO conversions for this type are currently supported) (%i)", unitType );
		}break;
			
		case CSS_HZ:
		case CSS_MS:
		case CSS_KHZ:
		case CSS_S:
		{
			NSAssert( FALSE, @"Asked to convert a Time or Frequency value to a different type (NO conversions for this type are currently supported) (%i)", unitType );
		}break;
			
		case CSS_NUMBER:
		{
			if( unitType == CSS_PX ) /** Dom 1 spec allows this, SVG Spec says "this is correct by spec", and DOM 2 spec says this is illegal. Most CSS interpreters do it... */
			{
				return self.internalValue;
			}
			else
			{
				NSAssert( FALSE, @"Asked to convert a Number to a different type (NO conversions for this type are currently supported) (%i)", unitType );
			}
		}break;
			
		case CSS_PERCENTAGE:
		{
			if( unitType == CSS_NUMBER )
			{
				return self.internalValue / 100.0; // convert percentages to values from 0.0 - 1.0
			}
			else
				NSAssert( FALSE, @"Asked to convert a Percentage value to a different type (%i)", unitType );
		}break;
			
		default:
		{
			NSAssert( FALSE, @"Asked to convert a (%i) value to a (%i) (couldn't find a valid conversion route). Float (4 d.p.) = %2.4f, String = %@", self.primitiveType, unitType, self.internalValue, self.internalString );
		}
	}
	
	return 0.0; // this will never happen. you should have Asserted by now, or else returned early with the correct value
}

-(void) setStringValue:(CSSPrimitiveType) stringType stringValue:(NSString*) stringValue
{
	self.primitiveType = stringType;
	self.internalString = stringValue;
	
	self.internalValue = 0.0;
}

-(NSString*) getStringValue
{
	return self.internalString;
}

-(/* FIXME: have to add this type: Counter*/ void) getCounterValue
{
	NSAssert(FALSE, @"This method not supported");
}

-(/* FIXME: have to add this type: Rect*/ void) getRectValue
{
	NSAssert(FALSE, @"This method not supported");
}

-(/* FIXME: have to add this type: RGBColor*/ void) getRGBColorValue
{
	NSAssert(FALSE, @"This method not supported");
}

#pragma mark - non DOM spec methods needed to implement Objective-C code for this class

-(void)setCssText:(NSString *)newCssText
{
	_cssText = newCssText;
	
	/** the css text value has been set, so we need to split the elements up and save them in the internal array */
	if( _cssText == nil
	   || _cssText.length == 0 )
	{
		self.internalValue = 0.0;
		self.internalString = @"";
		self.primitiveType = CSS_UNKNOWN;
	}
	else if( [_cssText hasSuffix:@"%"])
		[self setFloatValue:CSS_PERCENTAGE floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"em"])
		[self setFloatValue:CSS_EMS floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"ex"])
		[self setFloatValue:CSS_EXS floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"px"])
		[self setFloatValue:CSS_PX floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"cm"])
		[self setFloatValue:CSS_CM floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"mm"])
		[self setFloatValue:CSS_MM floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"in"])
		[self setFloatValue:CSS_IN floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"pt"])
		[self setFloatValue:CSS_PT floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"pc"])
		[self setFloatValue:CSS_PC floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"deg"])
		[self setFloatValue:CSS_DEG floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"rad"])
		[self setFloatValue:CSS_RAD floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"grad"])
		[self setFloatValue:CSS_GRAD floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"ms"])
		[self setFloatValue:CSS_MS floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"s"])
		[self setFloatValue:CSS_S floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"khz"]) // -----------NB: check this before checking HZ !
		[self setFloatValue:CSS_KHZ floatValue:[_cssText SVGKCGFloatValue]];
	else if( [_cssText hasSuffix:@"hz"])
		[self setFloatValue:CSS_HZ floatValue:[_cssText SVGKCGFloatValue]];
	else
	{
#if CGFLOAT_IS_DOUBLE
#define SCANCGFLOAT(scanner, cgfloatVal) [scanner scanDouble:cgfloatVal]
#else
#define SCANCGFLOAT(scanner, cgfloatVal) [scanner scanFloat:cgfloatVal]
#endif
		
		/**
		 Three possible outcomes left:
		 
		 1. It's a pure number, no units (in CSS, that's rare - but in SVG it's common, and defined by Spec to be "the same as PX")
		 2. It's a string, one of many different CSS string types
		 3. It's a corrupt file
		 */
		
		/**
		 NSScaner is an Apple class that SPECIFICALLY will refuse to return a number if there are any non-numberic characters in the string */
		NSScanner *scanner = [NSScanner scannerWithString: _cssText];
		CGFloat floatToHoldTheOutput;
		if( SCANCGFLOAT(scanner, &floatToHoldTheOutput))
		{
			/* Option 1: it's a pure number */
			[self setFloatValue:CSS_NUMBER floatValue:floatToHoldTheOutput];
		}
		else
		{
			/* Option 2: it's a string - or corrupt, which we're not going to handle here */
#if DEBUG_DOM_PARSING
			DDLogVerbose(@"[%@] WARNING: not bothering to work out 'what kind of CSS string' this string is. CSS is stupid. String = %@", [self class], _cssText );
#endif
			[self setStringValue:CSS_STRING stringValue:_cssText]; // -------- NB: we allow any string-to-string conversion, so it's not a huge problem that we dont correctly detect "url" versus "other kind of string". I hate CSS Parsing...
		}
	}
#undef SCANCGFLOAT
}

@end
