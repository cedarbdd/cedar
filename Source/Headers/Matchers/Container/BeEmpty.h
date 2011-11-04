#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeEmpty : public Base {
    private:
        BeEmpty & operator=(const BeEmpty &);

    public:
        BeEmpty();
        ~BeEmpty();
        // Allow default copy ctor.

        const BeEmpty & operator()() const;

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;
    };

    static const BeEmpty be_empty = BeEmpty();

    // For backwards compatible parenthesis syntax
    inline const BeEmpty & BeEmpty::operator()() const {
        return *this;
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
