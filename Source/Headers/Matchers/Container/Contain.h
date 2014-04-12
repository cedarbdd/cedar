#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class Contain : public Base<> {
    private:
        Contain & operator=(const Contain &);

    public:
        explicit Contain(const T & element);
        ~Contain();
        // Allow default copy ctor.

        Contain<T> & nested();

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        NSString *string_for_element() const;

    private:
        const T & element_;
        bool nested_;
    };

    template<typename T>
    inline Contain<T> contain(const T & element) {
        return Contain<T>(element);
    }

    template<typename T>
    inline Contain<T>::Contain(const T & element)
    : Base<>(), element_(element), nested_(false) {
    }

    template<typename T>
    Contain<T>::~Contain() {
    }

    template<typename T>
    Contain<T> & Contain<T>::nested() {
        nested_ = true;
        return *this;
    }

    template<typename T>
    inline /*virtual*/ NSString * Contain<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"contain <%@>%@", string_for_element(), nested_ ? @" nested" : @""];
    }

    template<typename T>
    inline NSString * Contain<T>::string_for_element() const {
        return Stringifiers::string_for(element_);
    }

    template<>
    inline NSString * Contain<AnInstanceOf>::string_for_element() const {
        return element_.expected_class_string();
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool Contain<T>::matches(const U & container) const {
        return Comparators::compare_contains(container, element_, nested_);
    }

    template<> template<typename U>
    bool Contain<AnInstanceOf>::matches(const U & container) const {
        return element_.matches(container, nested_);
    }
}}
