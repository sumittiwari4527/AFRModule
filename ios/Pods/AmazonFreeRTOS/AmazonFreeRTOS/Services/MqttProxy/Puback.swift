/// Mqtt proxy message of Puback.
public struct Puback: Encborable {

    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt message id.
    public var msgID: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: type.rawValue, CborKey.msgID.rawValue: msgID]
    }
}
