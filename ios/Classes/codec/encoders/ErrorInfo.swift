import Foundation

public class Encoders: NSObject {
    @objc
    public static let encodeErrorInfo: (ARTErrorInfo) -> Dictionary<String, Any> = { errorInfo in
        return [
            TxErrorInfo_message: errorInfo.message,
            TxErrorInfo_statusCode: errorInfo.statusCode as Any
            // code, href, requestId and cause - not available in ably-cocoa
            // track @ https://github.com/ably/ably-flutter/issues/14
            ];
    }
}
