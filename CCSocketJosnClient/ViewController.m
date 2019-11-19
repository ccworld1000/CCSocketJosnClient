//
//  ViewController.m
//  CCSocketJosnClient
//
//  Created by CC on 2019/11/19.
//  Copyright © 2019 CC (deng you hua | cworld1000@gmail.com). All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *timesTextField;
@property (weak, nonatomic) IBOutlet UITextView *leftTextView;
@property (weak, nonatomic) IBOutlet UITextView *rightTextView;

@end

@implementation ViewController

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
    NSLog(@"connectServerHandle");
    if (self.socket.isConnected) {
        return;
    }
    
    NSError *error = nil;
    [self.socket connectToHost:@"127.0.0.1" onPort:1234 error:&error];
    if (error) {
        NSLog(@"Socket Connect to Host Error: %@", error);
    }
}

- (IBAction)clearResultHandle:(UIButton *)button {
    NSLog(@"clearResultHandle");
    
    self.leftTextView.text = @"";
    self.rightTextView.text = @"";
}

- (IBAction)disconnectServerHandle:(UIButton *)button {
    NSLog(@"disconnectServerHandle");
    
    [self.socket disconnect];
    _socket = nil;
}

- (IBAction)sendDataHandle:(UIButton *)sender {
    NSLog(@"sendDataHandle");
    if (!self.socket.isConnected) {
        NSLog(@"You should connect server first!");
        return;
    }
    
    NSInteger times = [self.timesTextField.text integerValue];
    if (times <= 0 || times >= 10000) {
        times = 1;
        
        self.timesTextField.text = [NSString stringWithFormat:@"%ld", times];
    }
    
    NSString *testString = @"CC Test";
    for (int i = 0; i < times; i++) {
        NSData *data = [[NSString stringWithFormat:@"%@ %@!\n", testString, @(i + 1)] dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:-1 tag:0];
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
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if (err) {
        NSLog(@"err : %@", err);
    }
}


@end
