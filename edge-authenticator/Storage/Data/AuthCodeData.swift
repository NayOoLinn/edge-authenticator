//
import RealmSwift

class AuthCodeData: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var key: String = ""
    var code: String = ""
    
    convenience init(name: String, key: String) {
        self.init()
        self.name = name
        self.key = key
    }
    
    override class func ignoredProperties() -> [String] {
        return ["code"]
    }
}

extension AuthCodeData {
    
    static func findInRealm(_ key: String) -> AuthCodeData? {
        return RealmManager.shared.realm.objects(AuthCodeData.self)
            .filter("key == %@", key)
            .first
    }
}
