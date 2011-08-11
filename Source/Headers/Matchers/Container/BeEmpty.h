#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeEmpty : public Base {
    private:
        BeEmpty & operator=(const BeEmpty &);

    public:
        BeEmpty();
        ~BeEmpty();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;
    };

    inline BeEmpty be_empty() {
        return BeEmpty();
    }

    inline BeEmpty::BeEmpty() : Base() {
    }

    inline BeEmpty::~BeEmpty() {
    }

    inline /*virtual*/ NSString * BeEmpty::failure_message_end() const {
        return @"be empty";
    }

#pragma mark Generic
    template<typename U>
    bool BeEmpty::matches(const U & actualValue) const {
        this->build_failure_message_start(actualValue);
        return Comparators::compare_empty(actualValue);
    }
}}
