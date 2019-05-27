import { NativeModules, NativeEventEmitter } from 'react-native';
const { RNWebsocketServer } = NativeModules;

export default class WebsocketServer {
    constructor (ipAddress, port = 3770) {
        this.ipAddress = ipAddress;
        this.port = port;
    }
    

    /**
     * Starts websocket server
     */
    start () {
        RNWebsocketServer.start(this.ipAddress, this.port);
        this.eventEmitter = new NativeEventEmitter(RNWebsocketServer);
    }

    /**
     * Stops/closes websocket server
     */
    stop () {
        RNWebsocketServer.stop();
    }
}