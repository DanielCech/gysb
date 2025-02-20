import Foundation
import GysbBase

public struct Config : Decodable {
    public struct PackageDependency : Decodable {
        public enum Requirement : Decodable {
            case exact(String)
            case revision(String)
            
            public enum CodingKeys : String, CodingKey {
                case type
                case identifier
            }
        }
        
        public var url: String
        public var requirement: Requirement
    }

    public struct TargetDependency : Decodable {
        public var name: String
    }
    
    public init() {}
    
    public var configPath: URL? = nil
    public var packageDependencies: [PackageDependency] = []
    public var targetDependencies: [TargetDependency] = []
    public var includes: [String] = []
    
    public var includesFiles: [URL] = []
    
    public enum CodingKeys : String, CodingKey {
        case packageDependencies
        case targetDependencies
        case includes
    }
}

public extension Config {
    init(from decoder: Decoder) throws {
        let kc = try decoder.container(keyedBy: CodingKeys.self)
        self.packageDependencies = try kc.decodeIfPresent([PackageDependency].self, forKey: .packageDependencies) ?? []
        self.targetDependencies = try kc.decodeIfPresent([TargetDependency].self, forKey: .targetDependencies) ?? []
        self.includes = try kc.decodeIfPresent([String].self, forKey: .includes) ?? []
    }
    
    mutating func updateIncludePaths() throws {
        guard let configPath = configPath else {
            self.includesFiles = []
            return
        }
        
        let dir = configPath.deletingLastPathComponent()
        let paths: [URL] = try includes.flatMap { (include: String) -> [URL] in
            try glob(pattern: include, in: dir)
        }
        self.includesFiles = paths
    }

    static func fromJSON(path: URL) throws -> Config {
        let data = try Data.init(contentsOf: path)
        var config = try JSONDecoder().decode(Config.self, from: data)
        config.configPath = path
        try config.updateIncludePaths()
        return config
    }
    
    static func searchForSource(path: URL) -> URL? {
        let fm = FileManager.default
        
        var dir = path.deletingLastPathComponent().absoluteURL
        
        while true {
            let checkPath = dir.appendingPathComponent("gysb.json")
            if fm.fileExists(atPath: checkPath.path) {
                return checkPath
            }
            if dir.pathComponents.count == 1 {
                return nil
            }
            dir.deleteLastPathComponent()
        }
    }
}
