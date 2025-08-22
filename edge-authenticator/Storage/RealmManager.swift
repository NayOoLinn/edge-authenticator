import RealmSwift

struct RealmManager {
    
    static func configure() {
        let config = Realm.Configuration(
            encryptionKey: KeychainData.realmEncryptKey,
            schemaVersion: 1,
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
            //            print("✅ Realm ready at:", Realm.Configuration.defaultConfiguration.fileURL ?? "")
        } catch {
            print("❌ Failed to open Realm:", error)
        }
        
    }
    
    static let shared = RealmManager()
    let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("❌ Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) {
        do {
            try realm.write {
                realm.add(object, update: update)
            }
        } catch {
            print("❌ Error adding object:", error)
        }
    }
    
    func getAll<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func getByPrimaryKey<T: Object>(_ type: T.Type, key: Any) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    func update(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            print("❌ Error updating object:", error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("❌ Error deleting object:", error)
        }
    }
    
    func deleteAll<T: Object>(_ type: T.Type) {
        do {
            try realm.write {
                realm.delete(realm.objects(type))
            }
        } catch {
            print("❌ Error deleting all objects:", error)
        }
    }
    
}

