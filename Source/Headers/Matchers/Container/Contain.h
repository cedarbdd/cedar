#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class Contain : public Base<> {
    private:
        Contain & operator=(const Contain &);

    public:
        explicit Contain(const T & element);
        ~Contain();
        // Allow default copy ctor.

        Contain<T> & nested();
        Contain<T> & as_a_key();
        Contain<T> & as_a_value();

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        NSString *string_for_element() const;
        void validate_options() const;

    private:
        const T & element_;
        Comparators::contains_options options_;
        NSString *elementKeyPath_;
    };

    template<typename T>
    inline Contain<T>::Contain(const T & element) : Base<>(), element_(element), options_({}) {
    }

    template<typename T>
    Contain<T>::~Contain() {
    }

    template<typename T>
    Contain<T> & Contain<T>::nested() {
        options_.nested = true;
        return *this;
    }

    template<typename T>
    Contain<T> & Contain<T>::as_a_key() {
        options_.as_key = true;
        validate_options();
        return *this;
    }

    template<typename T>
    Contain<T> & Contain<T>::as_a_value() {
        options_.as_value = true;
        validate_options();
        return *this;
    }

    template<typename T>
    inline /*virtual*/ NSString * Contain<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"contain <%@>%@%@", string_for_element(), options_.nested ? @" nested" : @"", options_.as_key ? @" as a key" : options_.as_value ? @" as a value" : @""];
    }

    template<typename T>
    inline NSString * Contain<T>::string_for_element() const {
        return Stringifiers::string_for(element_);
    }

    template<>
    inline NSString * Contain<AnInstanceOf>::string_for_element() const {
        return element_.expected_class_string();
    }

    template <typename T>
    void Contain<T>::validate_options() const {
        if (options_.as_key && options_.as_value) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'contain' matcher; use the .as_a_key() or .as_a_value() modifiers, but not both" userInfo:nil] raise];
        }
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool Contain<T>::matches(const U & container) const {
        return Comparators::compare_contains(container, element_, options_);
    }

    template<> template<typename U>
    bool Contain<AnInstanceOf>::matches(const U & container) const {
        return element_.matches(container, options_);
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarContain = Cedar::Matchers::Private::Contain<T>;

    template<typename T>
    inline CedarContain<T> contain(const T & element) {
        return CedarContain<T>(element);
    }
}}
