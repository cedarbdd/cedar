namespace Cedar { namespace Matchers { namespace Stringifiers {
    template<typename U>
    NSString * string_for(const U & value) {
        std::stringstream temp;
        temp << value;
        return [NSString stringWithCString:temp.str().c_str() encoding:NSUTF8StringEncoding];
    }
    
    inline NSString * string_for(const char value) {
        return string_for(static_cast<const int>(value));
    }
    
    inline NSString * string_for(const BOOL value) {
        return value ? @"YES" : @"NO";
    }
    
    inline NSString * string_for(const id value) {
        return [value description];
    }
    
    inline NSString * string_for(NSObject * const value) {
        return string_for(static_cast<const id>(value));
    }
    
    inline NSString * string_for(NSString * const value) {
        return string_for(static_cast<const id>(value));
    }
    
    inline NSString * string_for(NSNumber * const value) {
        return string_for([value floatValue]);
    }
    
    inline NSString * string_for(NSMutableString * const value) {
        return string_for(static_cast<NSString * const>(value));
    }
}}}
