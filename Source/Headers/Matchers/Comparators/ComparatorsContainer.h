#import <vector>
#import <map>
#import <set>
#import <algorithm>

// Container
namespace Cedar { namespace Matchers { namespace Comparators {
#pragma mark - compare_empty
    template<typename T>
    bool compare_empty(const T & container) {
        if ([container respondsToSelector:@selector(count)]) {
            return 0 == [container performSelector:@selector(count)];
        } else {
            return 0 == [container performSelector:@selector(length)];
        }
    }

    template<typename T>
    bool compare_empty(const typename std::vector<T> & container) {
        return container.empty();
    }

    template<typename T, typename U>
    bool compare_empty(const typename std::map<T, U> & container) {
        return container.empty();
    }

    template<typename T>
    bool compare_empty(const typename std::set<T> & container) {
        return container.empty();
    }

#pragma mark - compare_contains
    typedef struct {
        bool nested:1;
        bool as_key:1;
        bool as_value:1;
    } contains_options;

    inline void check_for_no_dictionary_options(contains_options options) {
        if (options.as_key) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary" userInfo:nil] raise];
        } else if (options.as_value) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary" userInfo:nil] raise];
        }
    }

    inline void validate_contains_options_for_dictionary(contains_options options) {
        if (!options.as_key && !options.as_value) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'contain' matcher with dictionary; use the .as_a_key() or .as_a_value() modifiers" userInfo:nil] raise];
        }
    }

    inline void validate_contains_options_for_string(contains_options options) {
        check_for_no_dictionary_options(options);
        if (options.nested) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'nested' modifier on 'contain' matcher with string" userInfo:nil] raise];
        }
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, NSString *elementKeyPath, contains_options options, F comparator) {
        check_for_no_dictionary_options(options);

        for (id object in elementKeyPath ? [container valueForKeyPath:elementKeyPath] : container) {
            if (comparator(object, element)) {
                return YES;
            }

            if (options.nested && [(elementKeyPath ? [object valueForKeyPath:elementKeyPath] : object) respondsToSelector:@selector(containsObject:)] && compare_contains(object, element, elementKeyPath, options, comparator)) {
                return YES;
            }
        }

        return NO;
    }

#pragma mark array/vector/set
    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, contains_options options, F comparator) {
        return compare_contains(container, element, nil, options, comparator);
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, F comparator) {
        return container.end() != std::find_if(container.begin(), container.end(), [=](const U &lhs) { return comparator(lhs, element);});
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const std::vector<T> & container, const U & element, contains_options options, F comparator) {
        check_for_no_dictionary_options(options);
        return compare_contains(container, element, comparator);
    }

    template<typename U>
    bool compare_contains(const std::vector<U> & container, const U & element, contains_options options) {
        return compare_contains(container, element, options, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const std::set<T> & container, const U & element, contains_options options, F comparator) {
        check_for_no_dictionary_options(options);
        return compare_contains(container, element, comparator);
    }

    template<typename U>
    bool compare_contains(const std::set<U> & container, const U & element, contains_options options) {
        return compare_contains(container, element, options, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }

#pragma mark dictionary/map
    template<typename U, typename F>
    bool compare_contains(NSDictionary * const container, const U & element, contains_options options, F comparator) {
        validate_contains_options_for_dictionary(options);

        contains_options original_options = options;
        options.as_key = options.as_value = false;

        if (original_options.as_key && compare_contains([container allKeys], element, nil, options, comparator)) {
            return true;
        }
        if (original_options.as_value && compare_contains([container allValues], element, nil, options, comparator)) {
            return true;
        }

        return false;
    }

    template<typename U>
    bool compare_contains(NSDictionary * const container, const U & element, contains_options options) {
        return compare_contains(container, element, options, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }

    template<typename U>
    bool compare_contains(NSMutableDictionary * const container, const U & element, contains_options options) {
        return compare_contains(static_cast<NSDictionary * const>(container), element, options);
    }

    template<typename U, typename F>
    bool compare_contains(NSMutableDictionary * const container, const U & element, contains_options options, F comparator) {
        return compare_contains(static_cast<NSDictionary * const>(container), element, options, comparator);
    }

    template<typename T, typename U, typename V, typename F>
    bool compare_contains(const typename std::map<T, U> & container, const V & element, contains_options options, F comparator) {
        validate_contains_options_for_dictionary(options);
        return container.end() != std::find_if(container.begin(),
                                               container.end(),
                                               [=](const typename std::map<T, U>::value_type mapEntry) {
                                                   if (options.as_key) {
                                                       return comparator(mapEntry.first, element);
                                                   } else {
                                                       return comparator(mapEntry.second, element);
                                                   }
                                               });
    }

    template<typename T, typename U, typename V>
    bool compare_contains(const typename std::map<T, U> & container, const V & element, contains_options options) {
        return compare_contains(container, element, options, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }

#pragma mark string
    template<typename U>
    bool compare_contains(NSString * const container, const U & element, NSString *elementKeyPath, contains_options options) {
        validate_contains_options_for_string(options);
        NSRange range = [container rangeOfString:element];
        return container && range.location != NSNotFound;
    }

    template<typename U>
    bool compare_contains(NSString * const container, const U & element, contains_options options) {
        return compare_contains(container, element, (NSString *)nil, options);
    }

    template<typename U>
    bool compare_contains(NSMutableString * const container, const U & element, NSString *elementKeyPath, contains_options options) {
        return compare_contains(static_cast<NSString * const>(container), element, elementKeyPath, options);
    }

    template<typename U>
    bool compare_contains(NSMutableString * const container, const U & element, contains_options options) {
        return compare_contains(static_cast<NSString * const>(container), element, (NSString *)nil, options);
    }

    template<typename U>
    bool compare_contains(char *actualValue, const U & expectedContains, NSString *elementKeyPath, contains_options options) {
        validate_contains_options_for_string(options);
        return actualValue != NULL && strstr(actualValue, expectedContains) != NULL;
    }

    template<typename U>
    bool compare_contains(char *actualValue, const U & expectedContains, contains_options options) {
        return compare_contains(actualValue, expectedContains, (NSString *)nil, options);
    }

    template<typename U>
    bool compare_contains(const char *actualValue, const U & expectedContains, NSString *elementKeyPath, contains_options options) {
        return compare_contains((char *)actualValue, expectedContains, elementKeyPath, options);
    }

    template<typename U>
    bool compare_contains(const char *actualValue, const U & expectedContains, contains_options options) {
        return compare_contains((char *)actualValue, expectedContains, (NSString *)nil, options);
    }
}}}
