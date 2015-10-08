#ifndef __cplusplus
#error Cedar may only be imported from Objective-C++ (.mm) files.
#endif

#pragma mark - Cedar Core

#import "CDRVersion.h"


#pragma mark - Cedar Runner

#import "CDRSpec.h"
#import "CDRHooks.h"
#import "CDRExample.h"
#import "CDRFunctions.h"
#import "CDRSpecHelper.h"
#import "CDRSpecFailure.h"
#import "CDRExampleBase.h"
#import "CDRExampleGroup.h"
#import "CDRExampleParent.h"
#import "CDRSharedExampleGroupPool.h"

#if TARGET_OS_IPHONE && !TARGET_OS_WATCH
#import "Cedar-iOS.h"
#endif


#pragma mark - Cedar Runner/Matchers

#import "Equal.h"
#import "BeCloseTo.h"
#import "ActualValue.h"
#import "ShouldSyntax.h"


#pragma mark - Cedar Matchers

#import "Base.h"
#import "BeLTE.h"
#import "BeNil.h"
#import "BeGTE.h"
#import "Exist.h"
#import "BeEmpty.h"
#import "Contain.h"
#import "BeFalsy.h"
#import "BeTruthy.h"
#import "ConformTo.h"
#import "RespondTo.h"
#import "BeLessThan.h"
#import "BeInstanceOf.h"
#import "AnInstanceOf.h"
#import "BeGreaterThan.h"
#import "RaiseException.h"
#import "BeSameInstanceAs.h"
#import "StringifiersBase.h"
#import "StringifiersContainer.h"

#ifdef CEDAR_CUSTOM_STRINGIFIERS
#import CEDAR_CUSTOM_STRINGIFIERS
#endif


#pragma mark - Cedar Matcher Comparators

#import "CompareEqual.h"
#import "CompareCloseTo.h"
#import "ComparatorsBase.h"
#import "CedarComparators.h"
#import "CompareGreaterThan.h"
#import "ComparatorsContainer.h"
#import "ComparatorsContainerConvenience.h"

#if TARGET_OS_IPHONE
#import "UIGeometryCompareEqual.h"
#import "UIGeometryStringifiers.h"

#if !TARGET_OS_WATCH
#import "UIKitComparatorsContainer.h"
#endif

#endif

#ifdef CEDAR_CUSTOM_MATCHERS
#import CEDAR_CUSTOM_MATCHERS
#endif


#pragma mark - Cedar Doubles

#import "CDRSpy.h"
#import "CDRFake.h"
#import "CedarDouble.h"
#import "CDRClassFake.h"
#import "CDRProtocolFake.h"


#pragma mark - Cedar Doubles/Matchers

#import "Argument.h"
#import "ReturnValue.h"
#import "AnyArgument.h"
#import "HaveReceived.h"
#import "ValueArgument.h"
#import "StubbedMethod.h"
#import "RejectedMethod.h"
#import "AnyInstanceArgument.h"
#import "AnyInstanceOfClassArgument.h"
#import "AnyInstanceConformingToProtocolArgument.h"
