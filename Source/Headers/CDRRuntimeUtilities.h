#import <Foundation/Foundation.h>

extern void CDRCopyClassInternalsFromClass(Class sourceClass, Class destinationClass, NSSet *exclude);
extern Class CDRCreateClassByMergingClassInternalsIntoClass(NSString *newClassName, Class sourceClass, Class parentClass, NSSet *excludes);
