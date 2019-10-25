//
//  DLTraceLogger.m
//  Aspects
//
//  Created by miaoy on 2019/10/24.
//

#import "DLTraceLogger.h"
#import <Aspects/Aspects.h>



@interface DLTraceLogger ()

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
        if (![topVc isKindOfClass:NSClassFromString(@"UIInputWindowController")] || ![topVc isKindOfClass:[UINavigationController class]]) {
            [DLTraceLogger traceLogger].presentTracedResponder = topVc;
            NSLog(@"%@ - hooksuccess", className);
        }
        
        if ([topVc isKindOfClass:[UINavigationController class]]) {
            [DLTraceLogger traceLogger].presentTracedNavigationVC = (UINavigationController *)topVc;
        }
        
        
        [self printPresentNavStack];
        
        
    } error:&error];
    
    if (error) {
        
    }
}

+ (void)printNavStackOrderByTimestamp {
    
}

+ (void)printPresentNavStack {
    UINavigationController *stackNavVc = [DLTraceLogger traceLogger].presentTracedNavigationVC;
    
    NSMutableString *stackLinkString = [NSMutableString new];
    for (int i = 0; i < stackNavVc.childViewControllers.count; ++i) {
        UIViewController *stackVc = stackNavVc.childViewControllers[i];
        NSString *nodeClass = NSStringFromClass([stackVc class]);
        [stackLinkString appendFormat:@"->%@", nodeClass];
    }
    
    NSLog(@"Present-Nav-Stack:%@", stackLinkString);
    
}



#else

#endif

@end



@interface DLTraceNode : NSObject

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, copy) NSString *stackPathIdentifier;

@property (nonatomic, strong) DLTraceNode *nextTraceNode;
@end


@implementation DLTraceNode
@end


@interface DLTraceNodeList : NSObject

- (void)dl_addTraceNode:(DLTraceNode *)traceNode;
- (void)dl_deleteTraceNode:(DLTraceNode *)traceNode;

@property (nonatomic, strong) DLTraceNode *traceHeaderNode;

@end

@implementation DLTraceNodeList

- (void)dl_addTraceNode:(DLTraceNode *)traceNode {
    DLTraceNode *nextTraceNode = self.traceHeaderNode;
    while (nextTraceNode) {
        if (!nextTraceNode.nextTraceNode) {
            nextTraceNode.nextTraceNode = traceNode;
        }
        nextTraceNode = nextTraceNode.nextTraceNode;
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
    
}

- (DLTraceNode *)traceHeaderNode {
    if (_traceHeaderNode == nil) {
        _traceHeaderNode = [[DLTraceNode alloc] init];
    }
    return _traceHeaderNode;
}

@end







