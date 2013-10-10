#import "Base.h"

namespace Cedar { namespace Matchers {
    
    class RespondsTo : public Base<> {
    private:
        RespondsTo & operator=(const RespondsTo &);
        
    public:
        explicit RespondsTo(NSString *);
        RespondsTo(SEL selector);
        ~RespondsTo();
        // Allow default copy ctor.
        
        bool matches(const id) const;
        
    protected:
        virtual NSString * failure_message_end() const;
        
    private:
        NSString *const expectedSelectorName_;
    };
    
    inline RespondsTo responds_to(const SEL selector) {
        return RespondsTo(selector);
    }
    
    inline RespondsTo responds_to(NSString *selectorName) {
        return RespondsTo(selectorName);
    }
}}
