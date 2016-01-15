#import "Base.h"

#ifdef __cplusplus

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class ContainSubset : public Base<> {

    public:
        explicit ContainSubset(const T & element);
        ~ContainSubset();
        // Allow default copy constructor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        template<typename U>
        void validate_container_is_a_dictionary(const U &) const;
        void validate_subset_is_a_dictionary() const;

        const T & element_;
        Comparators::contains_options options_;
        NSString *elementKeyPath_;
    };

    template<typename T>
    inline ContainSubset<T>::ContainSubset(const T & element) : Base<>(), element_(element), options_({}) {
    }

    template<typename T>
    ContainSubset<T>::~ContainSubset() {
    }

    template<typename T>
    inline NSString * ContainSubset<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"contain subset <%@>", Stringifiers::string_for(element_)];
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool ContainSubset<T>::matches(const U & container) const {
        validate_container_is_a_dictionary(container);
        validate_subset_is_a_dictionary();

        NSDictionary *dictionary = (NSDictionary *)container;
        NSDictionary *possibleSubset = (NSDictionary *)element_;

        for (id key in possibleSubset) {
            if (![dictionary.allKeys containsObject:key]) {
                return false;
            }

            id value = possibleSubset[key];
            if (![dictionary[key] isEqual:value]) {
                return false;
            }
        }

        return true;
    }

#pragma mark Validations
    template<typename T> template<typename U>
    inline void ContainSubset<T>::validate_container_is_a_dictionary(const U & container) const {
        BOOL isNotObjcObject = strncmp(@encode(U), "@", 1) != 0;

        if (isNotObjcObject || ![(id)container isKindOfClass:[NSDictionary class]]) {
            NSString *reason = [NSString stringWithFormat:@"Unexpected use of the 'contain_subset' matcher with non-dictionary container <%@>", Stringifiers::string_for(container)];
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
        }
    }

    template<typename T>
    inline void ContainSubset<T>::validate_subset_is_a_dictionary() const {
        BOOL isNotObjcObject = strncmp(@encode(T), "@", 1) != 0;

        if (isNotObjcObject || ![(id)element_ isKindOfClass:[NSDictionary class]]) {
            NSString *reason = [NSString stringWithFormat:@"Unexpected use of the 'contain_subset' matcher with non-dictionary subset <%@>", Stringifiers::string_for(element_)];
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
        }
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarContainSubset = Cedar::Matchers::Private::ContainSubset<T>;

    template<typename T>
    inline CedarContainSubset<T> contain_subset(const T & element) {
        return CedarContainSubset<T>(element);
    }
}}

#endif
