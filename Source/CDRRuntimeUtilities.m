#import "CDRRuntimeUtilities.h"
#import <objc/runtime.h>


static void CDRCopyProtocolsFromClass(Class sourceClass, Class destinationClass, NSSet *exclude) {
    unsigned int count = 0;
    Protocol **protocols = class_copyProtocolList(sourceClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        if (![exclude containsObject:NSStringFromProtocol(protocol)]) {
            class_addProtocol(destinationClass, protocol);
        }
    }
    free(protocols);
}

static void CDRCopyInstanceMethodsFromClass(Class sourceClass, Class destinationClass, NSSet *exclude) {
    unsigned int count = 0;
    Method *instanceMethods = class_copyMethodList(sourceClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method m = instanceMethods[i];
        if ([exclude containsObject:NSStringFromSelector(method_getName(m))]) {
            continue;
        }
        if (class_respondsToSelector(destinationClass, method_getName(m))) {
            class_replaceMethod(destinationClass,
                                method_getName(m),
                                method_getImplementation(m),
                                method_getTypeEncoding(m));
        } else {
            class_addMethod(destinationClass,
                            method_getName(m),
                            method_getImplementation(m),
                            method_getTypeEncoding(m));
        }
    }
    free(instanceMethods);
}

static void CDRCopyInstanceVariablesFromClass(Class sourceClass, Class destinationClass, NSSet *exclude) {
    unsigned int count = 0;
    Ivar *instanceVars = class_copyIvarList(sourceClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar v = instanceVars[i];
        if ([exclude containsObject:[NSString stringWithUTF8String:ivar_getName(v)]]) {
            continue;
        }

        NSUInteger size = 0, align = 0;
        NSGetSizeAndAlignment(ivar_getTypeEncoding(v), &size, &align);
        class_addIvar(destinationClass,
                      ivar_getName(v),
                      size,
                      align,
                      ivar_getTypeEncoding(v));
    }
    free(instanceVars);
}

static void CDRCopyPropertiesFromClass(Class sourceClass, Class destinationClass, NSSet *exclude) {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(sourceClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];

        if ([exclude containsObject:[NSString stringWithUTF8String:property_getName(property)]]) {
            continue;
        }

        unsigned int attrCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attrCount);
        class_addProperty(destinationClass,
                          property_getName(property),
                          attributes,
                          attrCount);
        free(attributes);
    }
    free(properties);
}

void CDRCopyClassInternalsFromClass(Class sourceClass, Class destinationClass, NSSet *exclude) {
    CDRCopyProtocolsFromClass(sourceClass, destinationClass, exclude);
    CDRCopyPropertiesFromClass(sourceClass, destinationClass, exclude);
    CDRCopyInstanceVariablesFromClass(sourceClass, destinationClass, exclude);
    CDRCopyInstanceMethodsFromClass(sourceClass, destinationClass, exclude);
}

