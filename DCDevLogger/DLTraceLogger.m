//
//  DLTraceLogger.m
//  Aspects
//
//  Created by miaoy on 2019/10/24.
//

#import "DLTraceLogger.h"
#import <Aspects/Aspects.h>



@interface DLTraceNode : NSObject

@property (nonatomic, weak) UIViewController *stackTopVC;
@property (nonatomic, copy) NSString *stackTopName;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, copy) NSString *stackPathIdentifier;

@property (nonatomic, strong) DLTraceNode *nextTraceNode;
@end


@implementation DLTraceNode

- (void)setNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
    
    NSMutableString *stackLinkString = [NSMutableString new];
    for (int i = 0; i < navigationController.childViewControllers.count; ++i) {
        UIViewController *stackVc = navigationController.childViewControllers[i];
        NSString *nodeClass = NSStringFromClass([stackVc class]);
        [stackLinkString appendFormat:@"->%@", nodeClass];
    }
    _stackPathIdentifier = stackLinkString.copy;
}

- (void)setStackTopVC:(UIViewController *)stackTopVC {
    _stackTopVC = stackTopVC;
    if (stackTopVC.navigationController) {
        self.navigationController = stackTopVC.navigationController;
    }
}

@end


@interface DLTraceNodeList : NSObject

- (void)dl_addTraceNode:(DLTraceNode *)traceNode;
- (void)dl_deleteTraceNode:(DLTraceNode *)traceNode;

- (void)dl_printTopstackMsg;
- (void)dl_printAllNavMessage;

@property (nonatomic, strong) DLTraceNode *traceHeaderNode;
@property (nonatomic, assign) NSUInteger nodeNum;

@end

@implementation DLTraceNodeList

- (void)dl_addTraceNode:(DLTraceNode *)traceNode {
    DLTraceNode *nextTraceNode = self.traceHeaderNode;
    if (!nextTraceNode.nextTraceNode) {
        nextTraceNode.nextTraceNode = traceNode;
        self.nodeNum ++;
    } else {
        BOOL repitition = NO;
        while (nextTraceNode) {
            @autoreleasepool {
                DLTraceNode *forwardNode = nextTraceNode.nextTraceNode;

                if ([forwardNode.navigationController isEqual:traceNode.navigationController]) {
                    repitition = YES;
                    nextTraceNode.nextTraceNode = forwardNode.nextTraceNode;
                    break;
                }
                nextTraceNode = forwardNode;
            }
        }
        
        if (!repitition) {
            self.nodeNum ++;
        }
        
        traceNode.nextTraceNode = self.traceHeaderNode.nextTraceNode;
        self.traceHeaderNode.nextTraceNode = traceNode;
    }
}

- (void)dl_deleteTraceNode:(DLTraceNode *)traceNode {
    DLTraceNode *stayTraceNode = self.traceHeaderNode;
    
    while (stayTraceNode) {
        if ([stayTraceNode.nextTraceNode.stackPathIdentifier isEqualToString:traceNode.stackPathIdentifier]) {
            stayTraceNode.nextTraceNode = nil;
        }
        stayTraceNode = stayTraceNode.nextTraceNode;
    }
    
    self.nodeNum --;
}

- (DLTraceNode *)dl_getStackTopNode {
    if (self.nodeNum >= 1) {
        return self.traceHeaderNode.nextTraceNode;
    } else {
        return nil;
    }
}

#pragma mark - Logger

- (void)dl_printTopstackMsg {
    DLTraceNode *topstackNode = [self dl_getStackTopNode];
    NSLog(@"top-Nav-Stack:%@\ntop-stack-VC -- %@\n", topstackNode.stackPathIdentifier, topstackNode.stackTopName);
}

- (void)dl_printAllNavMessage {
    DLTraceNode *presentNode = self.traceHeaderNode.nextTraceNode;
    if (!presentNode) {
        return;
    }
    NSUInteger counter = 0;
    while (presentNode) {
        NSLog(@"%ld-nav-stack%@\n", counter, presentNode.stackPathIdentifier);
        counter ++;
        presentNode = presentNode.nextTraceNode;
    }
}

#pragma mark - Getter

- (DLTraceNode *)traceHeaderNode {
    if (_traceHeaderNode == nil) {
        _traceHeaderNode = [[DLTraceNode alloc] init];
    }
    return _traceHeaderNode;
}

@end



@interface DLTraceLogger ()

@property (nonatomic, strong) DLTraceNodeList *nodeList;
@property (nonatomic, weak) UINavigationController *presentTracedNavigationVC;
@property (nonatomic, weak) id presentTracedResponder;
@end

@implementation DLTraceLogger

+ (instancetype)traceLogger {
    static DLTraceLogger *_traceLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _traceLogger = [[DLTraceLogger alloc] init];
    });
    return _traceLogger;
}

#ifdef DEBUG
+ (void)load {
    NSError *error = nil;
    [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo) {
        
        id instance = [aspectInfo instance];
        NSString *className = NSStringFromClass([instance class]);
        UIViewController *topVc = (UIViewController *)instance;
        
        //初始化展示页面时会在加载完目标控制器后加载该控制器
        if (![topVc isKindOfClass:NSClassFromString(@"UIInputWindowController")] && ![topVc isKindOfClass:[UINavigationController class]]) {
            [DLTraceLogger traceLogger].presentTracedResponder = topVc;
            DLTraceNode *traceNode = [[DLTraceLogger traceLogger].nodeList dl_getStackTopNode];
            traceNode.stackTopVC = topVc;
            traceNode.stackTopName = className;
            
            [[DLTraceLogger traceLogger].nodeList dl_printTopstackMsg];
            [[DLTraceLogger traceLogger].nodeList dl_printAllNavMessage];
        }
        
        if ([topVc isKindOfClass:[UINavigationController class]]) {
            [DLTraceLogger traceLogger].presentTracedNavigationVC = (UINavigationController *)topVc;
            DLTraceNode *node = [[DLTraceNode alloc] init];
            node.navigationController = (UINavigationController *)topVc;
            [[DLTraceLogger traceLogger].nodeList dl_addTraceNode: node];
        }
        
    } error:&error];
    
    if (error) {
        
    }
}

- (DLTraceNodeList *)nodeList {
    if (_nodeList == nil) {
        _nodeList = [[DLTraceNodeList alloc] init];
    }
    return _nodeList;
}

#else

#endif

@end










