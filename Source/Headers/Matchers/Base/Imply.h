#import <Foundation/Foundation.h>
#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    
    template<typename T>
    class Imply : public Base<> {
    private:
        Imply<T> & operator=(const Imply<T> &);
        
    public:
        explicit Imply(const T & expectedValue);
        ~Imply();
        // Allow default copy ctor.
        
        template<typename U>
        bool matches(const U &) const;
        
    protected:
        virtual NSString * failure_message_end() const;
        
    private:
        const T & expectedValue_;
    };
    
    template<typename T>
    Imply<T>::Imply(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }
    
    template<typename T>
    Imply<T>::~Imply() {
    }
    
    template<typename T>
    /*virtual*/ NSString * Imply<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"imply <%@>", expectedValueString];
    }
    
    template<typename T> template<typename U>
    bool Imply<T>::matches(const U & actualValue) const {
        return !!expectedValue_ || !actualValue;
    }
    
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarImply = Cedar::Matchers::Private::Imply<T>;
    
    template<typename T>
    CedarImply<T> imply(const T & expectedValue) {
        return CedarImply<T>(expectedValue);
    }
}}
