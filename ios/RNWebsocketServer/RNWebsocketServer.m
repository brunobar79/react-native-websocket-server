//
//  RNWebsocketServer.m
//  RNWebsocketServer
//
//  Created by Unexus on 04/12/2017.
//  Copyright © 2017 Unexus. All rights reserved.
//

#import "RNWebsocketServer.h"
#import "PSWebSocketServer.h"

@interface RNWebsocketServer () <PSWebSocketServerDelegate>

@property (nonatomic, strong) PSWebSocketServer *server;

@end


@implementation RNWebsocketServer

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onStart",  @"onStop", @"onOpen",  @"onClose", @"onMessage",  @"onError"];
}

RCT_EXPORT_METHOD(start: (NSString *) ipAddress
                  port: (int) port)
{
    self.server = [PSWebSocketServer serverWithHost:ipAddress port:port];
    self.server.delegate = self;
    
    [self.server start];
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketFrom:(NSData*)address withRequest:(NSURLRequest *)request trust:(SecTrustRef)trust response:(NSHTTPURLResponse **)response {
    NSLog(@"Websocket Request: %@", request);

    return YES;
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Websocket serverDidStart");
    [self sendEventWithName:@"onStart" body:nil];
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"Websocket didFailWithError");
    [self sendEventWithName:@"onError" body:nil];

    [NSException raise:NSInternalInconsistencyException format:error.localizedDescription];
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Websocket serverDidStop");
     [self sendEventWithName:@"onStop" body:nil];
    [NSException raise:NSInternalInconsistencyException format:@"Server stopped unexpected."];
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Websocket serverDidOpen");
    [self sendEventWithName:@"onOpen" body:nil];

}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {


    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    [dictionary setObject:[NSString stringWithFormat:@"%@", [webSocket remoteHost]] forKey:@"origin"];
    
    [self sendEventWithName:@"onMessage" body:dictionary];

    
    NSError *error;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    for (PSWebSocket *connection in [server getWebsocketConnections]) {
        NSLog(@"Websocket onmessage send: %@", [connection request]);
        [connection send:[[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding]];
    }
    
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self sendEventWithName:@"onError" body:nil];

}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self sendEventWithName:@"onClose" body:nil];

}
@end
