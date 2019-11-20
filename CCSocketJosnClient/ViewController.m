//
//  ViewController.m
//  CCSocketJosnClient
//
//  Created by CC on 2019/11/19.
//  Copyright © 2019 CC (deng you hua | cworld1000@gmail.com). All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>
#import <CCSugar/CCSugar.h>
#import <CCTips/CCTips.h>
#import <CCDebug/CCDebug.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *timesTextField;
@property (weak, nonatomic) IBOutlet UITextView *leftTextView;
@property (weak, nonatomic) IBOutlet UITextView *rightTextView;

@property (nonatomic, strong) NSMutableArray<NSString *> *sendCache;
@property (nonatomic, strong) NSMutableArray<NSString *> *receiveCache;

@end

@implementation ViewController

- (NSMutableArray<NSString *> *)sendCache {
    if (!_sendCache) {
        _sendCache = [NSMutableArray array];
    }
    
    return _sendCache;
}

- (NSMutableArray<NSString *> *)receiveCache {
    if (!_receiveCache) {
        _receiveCache = [NSMutableArray array];
    }
    
    return _receiveCache;
}

- (void)dealloc {
    [self disconnectServerHandle:nil];
}

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    
    return _socket;
}

- (IBAction)connectServerHandle:(UIButton *)button {
    if (self.socket.isConnected) {
        CCTipsForView(@"already connect to server");
        return;
    }
    
    NSError *error = nil;
    [self.socket connectToHost:@"127.0.0.1" onPort:1234 error:&error];
    if (error) {
        NSLog(@"Socket Connect to Host Error: %@", error);
    } else {
        CCTipsForView(@"Ready connect to server ....");
    }
}

- (IBAction)clearResultHandle:(UIButton *)button {
    if (button) {
        CCTipsForView(@"clear result");
    }
    
    [self.sendCache removeAllObjects];
    [self.receiveCache removeAllObjects];
    self.leftTextView.text = @"";
    self.rightTextView.text = @"";
}

- (IBAction)disconnectServerHandle:(UIButton *)button {
    CCTipsForView(@"discnnect server");
    
    [self.socket disconnect];
    _socket = nil;
}

- (IBAction)sendDataHandle:(UIButton *)sender {
    CCDebugPrint(@"sendDataHandle");
    if (!self.socket.isConnected) {
        CCTipsForView(@"You should connect server first!");
        return;
    }
    
    NSInteger times = [self.timesTextField.text integerValue];
    if (times <= 0 || times >= 10000) {
        times = 1;
        
        self.timesTextField.text = [NSString stringWithFormat:@"%ld", times];
    }
    
    NSString *testString = @"CC Test";
    __block NSMutableArray *list = [NSMutableArray array];
    
    [@(times) timesWithIndex:^(NSUInteger index) {
        [list addObject: [NSString stringWithFormat:@"%@ %@!\n", testString, @(index + 1)]];
    }];
    
    if (list.count) {
        NSData *data = [[list componentsJoinedByString:@""] dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:-1 tag:0];
        [self.sendCache concat:list];
        self.leftTextView.text = [_sendCache componentsJoinedByString:@""];
    }
}

- (IBAction)tapHandle{
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle)];
    [self.view addGestureRecognizer:g];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self tapHandle];
    [self clearResultHandle:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (data.length > 0) {
        NSString *testString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.receiveCache addObject:testString];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rightTextView.text = [self.receiveCache componentsJoinedByString:@""];
        });
    }
    
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if (err) {
        NSLog(@"err : %@", err);
    }
}


@end
