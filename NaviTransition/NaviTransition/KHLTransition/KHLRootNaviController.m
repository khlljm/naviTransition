//
//  KHLRootViewController.m
//  NaviTransition
//
//  Created by khl on 2016/11/20.
//  Copyright © 2016年 khl. All rights reserved.
//

#import "KHLRootNaviController.h"
#import <objc/runtime.h>

@interface NSArray<ObjectType> (KHLRootNaviController)

- (NSArray *)map:(id(^)(ObjectType obj, NSUInteger index))block;

- (BOOL)any:(BOOL(^)(ObjectType obj))block;

@end

@implementation NSArray (KHLRootNaviController)

- (NSArray *)map:(id (^)(id, NSUInteger))block {
    if (!block) {
        block = ^(id obj, NSUInteger index) {
            return obj;
        };
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:block(obj, idx)];
    }];
    
    return [NSArray arrayWithArray:array];
}

- (BOOL)any:(BOOL (^)(id))block {
    if (!block) {
        return NO;
    }
    
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
@end

@interface KHLContainerController ()

@property (nonatomic, strong) __kindof UIViewController *contentViewController;
@property (nonatomic, strong) UINavigationController *containerNaviController;

+ (instancetype)containerControllerWithController:(UIViewController *)controller;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass
                        withPlaceholderController:(BOOL)yesOrNo;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle;

- (instancetype)initWithController:(UIViewController *)controller;
- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)naviBarClass;
@end

static inline UIViewController *KHLSafeUnwrapViewController(UIViewController *controller) {
    if ([controller isKindOfClass:[KHLContainerController class]]) {
        return ((KHLContainerController *)controller).contentViewController;
    }
    return controller;
}

OS_OVERLOADABLE static inline UIViewController *KHLSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder, UIBarButtonItem *backItem, NSString *backTitle) {
    if (![controller isKindOfClass:[KHLContainerController class]]) {
        return [KHLContainerController containerControllerWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:withPlaceholder backBarButtonItem:backItem backTitle:backTitle];
    }
    return controller;
}

OS_OVERLOADABLE static inline UIViewController *KHLSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder) {
    if (![controller isKindOfClass:[KHLContainerController class]]) {
        return [KHLContainerController containerControllerWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:withPlaceholder];
    }
    return controller;
}

OS_OVERLOADABLE static inline UIViewController *KHLSafeWrapViewController(UIViewController *controller, Class navigationBarClass) {
    return KHLSafeWrapViewController(controller, navigationBarClass, NO);
}

@implementation KHLContainerController

+ (instancetype)containerControllerWithController:(UIViewController *)controller {
    return [[self alloc] initWithController:controller];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass {
    return [[self alloc] initWithController:controller
                         navigationBarClass:naviBarClass];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass
                        withPlaceholderController:(BOOL)yesOrNo {
    return [[self alloc] initWithController:controller
                         navigationBarClass:naviBarClass
                  withPlaceholderController:yesOrNo];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)naviBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle {
    return [[self alloc] initWithController:controller
                         navigationBarClass:naviBarClass
                  withPlaceholderController:yesOrNo
                          backBarButtonItem:backItem
                                  backTitle:backTitle];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(__unsafe_unretained Class)naviBarClass
         withPlaceholderController:(BOOL)yesOrNo
                 backBarButtonItem:(UIBarButtonItem *)backItem
                         backTitle:(NSString *)backTitle {
    
    if (self == [super init]) {
        self.contentViewController = controller;
        self.containerNaviController = [[KHLContainerNavigationController alloc] initWithNavigationBarClass:naviBarClass toolbarClass:nil];
        
        if (yesOrNo) {
            UIViewController *vc = [UIViewController new];
            vc.title = backTitle;
            vc.navigationItem.backBarButtonItem = backItem;
            self.containerNaviController.viewControllers = @[vc, controller];
        }else {
            self.containerNaviController.viewControllers = @[controller];
        }
        
        [self addChildViewController:self.containerNaviController];
        [self.containerNaviController didMoveToParentViewController:self];
    }
    
    return self;
}

- (instancetype)initWithController:(UIViewController *)controller {
    return [self initWithController:controller navigationBarClass:nil];
}

- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(__unsafe_unretained Class)naviBarClass {
    return [self initWithController:controller navigationBarClass:naviBarClass withPlaceholderController:NO];
}

- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(__unsafe_unretained Class)naviBarClass withPlaceholderController:(BOOL)yesOrNo {
    return [self initWithController:controller navigationBarClass:naviBarClass withPlaceholderController:yesOrNo backBarButtonItem:nil backTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.containerNaviController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.containerNaviController.view];
    self.containerNaviController.view.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.contentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.contentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)shouldAutorotate {
    return [self.contentViewController shouldAutorotate];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}
#endif

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.contentViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.contentViewController.preferredInterfaceOrientationForPresentation;
}

- (UIView *)rotatingHeaderView {
    return self.contentViewController.rotatingHeaderView;
}

- (UIView *)rotatingFooterView {
    return self.contentViewController.rotatingFooterView;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender {
    return [self.contentViewController viewControllerForUnwindSegueAction:action
                                                       fromViewController:fromViewController
                                                               withSender:self];
}

- (BOOL)hidesBottomBarWhenPushed {
    return self.contentViewController.hidesBottomBarWhenPushed;
}

- (NSString *)title {
    return self.contentViewController.title;
}

- (UITabBarItem *)tabBarItem {
    return self.contentViewController.tabBarItem;
}

@end

@interface UIViewController (KHLContainerNaviController)
@property (nonatomic, assign, readonly) BOOL hasSetInteractivePop;
@end

@implementation UIViewController (KHLContainerNaviController)

- (BOOL)hasSetInteractivePop {
    return !!objc_getAssociatedObject(self, @selector(disableInteractivePop));
}

@end

@implementation KHLContainerNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self == [super initWithNavigationBarClass:rootViewController.navigationBarClass toolbarClass:nil]) {
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.enabled = NO;
    if (self.transNaviController.transferNavigationBarAttributes) {
        self.navigationBar.translucent = self.navigationController.navigationBar.isTranslucent;
        self.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        self.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
        
        [self.navigationBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTitleVerticalPositionAdjustment:[self.navigationController.navigationBar titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        
        self.navigationBar.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
        self.navigationBar.shadowImage = self.navigationController.navigationBar.shadowImage;
        self.navigationBar.backIndicatorImage = self.navigationController.navigationBar.backIndicatorImage;
        self.navigationBar.backIndicatorTransitionMaskImage = self.navigationController.navigationBar.backIndicatorTransitionMaskImage;
    }
    [self.view layoutIfNeeded];
}

- (UITabBarController *)tabBarController {
    UITabBarController *tabController = [super tabBarController];
    KHLRootNaviController *naviController = self.transNaviController;
    if (tabController) {
        if (naviController.tabBarController != tabController) {
            // tabController is child of root VC
            return tabController;
        }else {
            return  !tabController.tabBar.isTranslucent || [naviController.transitionControllers any:^BOOL(__kindof UIViewController *obj) {
                return obj.hidesBottomBarWhenPushed;
            }] ? nil : tabController;
        }
    }
    return nil;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    if (self.navigationController) {
        return [self.navigationController viewControllerForUnwindSegueAction:action fromViewController:self.parentViewController withSender:sender];
    }
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

- (NSArray<__kindof UIViewController *> *)allowedChildViewControllersForUnwindingFromSource:(UIStoryboardUnwindSegueSource *)source {
    if (self.navigationController) {
        return [self.navigationController allowedChildViewControllersForUnwindingFromSource:source];
    }
    return [super allowedChildViewControllersForUnwindingFromSource:source];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
    }else {
        [super pushViewController:viewController animated:animated];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.navigationController respondsToSelector:aSelector]) {
        return self.navigationController;
    }
    return nil;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) {
        return [self.navigationController popViewControllerAnimated:animated];
    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) {
        return [self.navigationController popToRootViewControllerAnimated:animated];
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        return [self.navigationController popToViewController:viewController animated:animated];
    }
    return [super popToViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController setViewControllers:viewControllers animated:animated];
    }else {
        [super setViewControllers:viewControllers animated:animated];
    }
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (self.navigationController) {
        self.navigationController.delegate = delegate;
    }else {
        [super setDelegate:delegate];
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    if (!self.visibleViewController.hasSetInteractivePop) {
        self.visibleViewController.disableInteractivePop = hidden;
    }
}

@end

@interface KHLRootNaviController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> transDelegate;
@property (nonatomic, copy) void(^animationBlock)(BOOL finished);

@end

@implementation KHLRootNaviController

#pragma mark - PersonalMethods

- (void)onBack:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)commonInit {
    
}

#pragma mark Overrides

- (void)awakeFromNib {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_0
    [super awakeFromNib];
#endif
    self.viewControllers = [super viewControllers];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    if (self == [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootVC {
    if (self == [super init]) {
        [super pushViewController:rootVC animated:NO];
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [super setDelegate:self];
    [super setNavigationBarHidden:YES animated:NO];
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    UIViewController *controller = [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
    if (!controller) {
        NSInteger index = [self.viewControllers indexOfObject:fromViewController];
        if (index != NSNotFound) {
            for (NSInteger i = index-1; i >= 0; i--) {
                controller = [self.viewControllers[i] viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
                if (controller) {
                    break;
                }
            }
        }
    }
    return controller;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        UIViewController *currentLast = KHLSafeUnwrapViewController(self.viewControllers.lastObject);
        [super pushViewController:KHLSafeWrapViewController(viewController, viewController.navigationBarClass, self.useSystemBackBarButtonItem, currentLast.navigationItem.backBarButtonItem, currentLast.title) animated:animated];
    }else {
        [super pushViewController:KHLSafeWrapViewController(viewController, viewController.navigationBarClass) animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return KHLSafeUnwrapViewController([super popViewControllerAnimated:animated]);
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    return [[super popToRootViewControllerAnimated:animated] map:^id(__kindof UIViewController *obj, NSUInteger index) {
        return KHLSafeUnwrapViewController(obj);
    }];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    __block UIViewController *controllerToPop = nil;
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (KHLSafeUnwrapViewController(obj) == viewController) {
            controllerToPop = obj;
            *stop = YES;
        }
    }];
    if (controllerToPop) {
        return [[super popToViewController:controllerToPop animated:animated] map:^id(__kindof UIViewController *obj, NSUInteger index) {
            return KHLSafeUnwrapViewController(obj);
        }];
    }
    return nil;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:[viewControllers map:^id(UIViewController *obj, NSUInteger index) {
        if (self.useSystemBackBarButtonItem && index > 0) {
            return KHLSafeWrapViewController(obj, obj.navigationBarClass, self.useSystemBackBarButtonItem, viewControllers[index-1].navigationItem.backBarButtonItem, viewControllers[index-1].title);
        }else {
            return KHLSafeWrapViewController(obj, obj.navigationBarClass);
        }
    }] animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.transDelegate = delegate;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}
#endif

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIView *)rotatingHeaderView {
    return self.topViewController.rotatingHeaderView;
}

- (UIView *)rotatingFooterView {
    return self.topViewController.rotatingFooterView;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.transDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.transDelegate;
}

#pragma mark - PublicMethods

- (UIViewController *)transTopViewController {
    return KHLSafeUnwrapViewController([super topViewController]);
}

- (UIViewController *)transVisiableController {
    return KHLSafeUnwrapViewController([super visibleViewController]);
}

- (NSArray<__kindof UIViewController *> *)transitionControllers {
    return [[super viewControllers] map:^id(__kindof UIViewController *obj, NSUInteger index) {
        return KHLSafeUnwrapViewController(obj);
    }];
}

- (void)removeViewController:(UIViewController *)controller {
    [self removeViewController:controller animated:NO];
}

- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag {
    NSMutableArray<__kindof UIViewController *> *controllers = [self.viewControllers mutableCopy];
    __block UIViewController *controllerToRemove = nil;
    [controllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (KHLSafeUnwrapViewController(obj) ==  controller) {
            controllerToRemove = obj;
            *stop = YES;
        }
    }];
    if (controllerToRemove) {
        [controllers removeObject:controllerToRemove];
        [super setViewControllers:[NSArray arrayWithArray:controllers] animated:flag];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    [self pushViewController:viewController animated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    NSArray <__kindof UIViewController *> *array = [self popToViewController:viewController animated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    
    NSArray <__kindof UIViewController *> *array = [self popToRootViewControllerAnimated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    if (!isRootVC) {
        viewController = KHLSafeUnwrapViewController(viewController);
        if (!self.useSystemBackBarButtonItem && !viewController.navigationItem.leftBarButtonItem) {
            viewController.navigationItem.leftBarButtonItem = [viewController customBackItemWithTarget:self action:@selector(onBack:)];
        }
    }
    
    if ([self.transDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.transDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    viewController = KHLSafeUnwrapViewController(viewController);
    if (viewController.disableInteractivePop) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    }else {
        self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }
    
    [KHLRootNaviController attemptRotationToDeviceOrientation];
    
    if (self.animationBlock) {
        self.animationBlock(YES);
        self.animationBlock = nil;
    }
    
    if ([self.transDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.transDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if ([self.transDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.transDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if ([self.transDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.transDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([self.transDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.transDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([self.transDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.transDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
