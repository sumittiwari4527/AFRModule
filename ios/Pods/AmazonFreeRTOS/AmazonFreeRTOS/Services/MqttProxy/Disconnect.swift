/// Mqtt proxy message of Disconnect.
public struct Disconnect: Decborable {

    init?(dictionary: NSDictionary) {
        guard let typeRawValue = dictionary.object(forKey: CborKey.type.rawValue) as? Int, let type = MqttMessageType(rawValue: typeRawValue) else {
            return nil
        }
        self.type = type
    }

    /// Mqtt message type.
    public var type: MqttMessageType

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return Disconnect(dictionary: dictionary) as? T
    }
}
