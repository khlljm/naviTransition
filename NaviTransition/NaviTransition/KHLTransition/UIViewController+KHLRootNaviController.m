//
//  UIViewController+KHLRootNaviController.m
//  NaviTransition
//
//  Created by khl on 2016/11/20.
//  Copyright © 2016年 khl. All rights reserved.
//

#import "UIViewController+KHLRootNaviController.h"
#import <objc/runtime.h>
#import "KHLRootNaviController.h"

@implementation UIViewController (KHLRootNaviController)
@dynamic disableInteractivePop;

- (void)setDisableInteractivePop:(BOOL)disableInteractivePop {
    objc_setAssociatedObject(self, @selector(disableInteractivePop), @(disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableInteractivePop {
    return [objc_getAssociatedObject(self, @selector(disableInteractivePop)) boolValue];
}

- (Class)navigationBarClass {
    return nil;
}

- (KHLRootNaviController *)transNaviController {
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[KHLRootNaviController class]]) {
        vc = vc.navigationController;
    }
    return (KHLRootNaviController *)vc;
}

- (UIBarButtonItem *)customBackItemWithTarget:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                            style:UIBarButtonItemStylePlain
                                           target:target
                                           action:action];
}

@end
