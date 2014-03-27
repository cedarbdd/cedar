#import "Base.h"
#import <UIKit/UIKit.h>

namespace Cedar { namespace Matchers {
    template<typename T>
    class ContainNestedSubview : public Base<> {
    private:
        ContainNestedSubview & operator=(const ContainNestedSubview &);

    public:
        explicit ContainNestedSubview(const T & element);
        ~ContainNestedSubview();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & element_;
    };

    template<typename T>
    inline ContainNestedSubview<T> contain_nested_subview(const T & element) {
        return ContainNestedSubview<T>(element);
    }

    template<typename T>
    inline ContainNestedSubview<T>::ContainNestedSubview(const T & element)
    : Base<>(), element_(element) {
    }

    template<typename T>
    ContainNestedSubview<T>::~ContainNestedSubview() {
    }

    template<typename T>
    inline /*virtual*/ NSString * ContainNestedSubview<T>::failure_message_end() const {
        NSString * elementString = Stringifiers::string_for(element_);
        return [NSString stringWithFormat:@"contain nested subview <%@>", elementString];
    }

#pragma mark Generic
    inline bool compare_contains_nested_subview(UIView * const parentView, UIView * const view) {
        if ([parentView.subviews containsObject:view])
            return YES;
        for (UIView *subview in parentView.subviews) {
            if (compare_contains_nested_subview(subview, view))
                return YES;
        }
        return NO;
    }

    template <typename T> template<typename U>
    bool ContainNestedSubview<T>::matches(const U & actualValue) const {
        UIView *parentView = actualValue;
        UIView *view = element_;
        return compare_contains_nested_subview(parentView, view);
    }
}}
