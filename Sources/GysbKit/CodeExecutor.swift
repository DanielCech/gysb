import Foundation
import GysbBase

class CodeExecutor {
    init(state: Driver.State,
         workIndex: Int,
         output: @escaping (String) -> Void)
    {
        self.state = state
        self.workIndex = workIndex
        self.output = output
    }
    
    func deploy() throws {
        let fm = FileManager.default
        
        let includeFiles = buildWork.config.includesFiles
        let targetNames = buildWork.entryIndices.map { state.targetName(index: $0) }
        let generator = SPMManifestoGenerator(config: buildWork.config,
                                              targetNames: targetNames,
                                              includeFilesTargetName: state.includeFilesTargetName,
                                              hasIncludeFiles: includeFiles.count > 0)
        let manifesto = generator.generate()
        try manifesto.write(to: buildWork.workDir
            .appendingPathComponent("Package.swift"),
                            atomically: true, encoding: .utf8)

        for i in buildWork.entryIndices {
            let targetName = state.targetName(index: i)
            let code = state.entries[i].code!
            
            let targetDir = buildWork.workDir
                .appendingPathComponent("Sources")
                .appendingPathComponent(targetName)
            try fm.createDirectory(at: targetDir, withIntermediateDirectories: true)
            
            try code.write(to: targetDir.appendingPathComponent("main.swift"),
                           atomically: true, encoding: .utf8)
        }
        
        if includeFiles.count > 0 {
            let targetDir = buildWork.workDir
                .appendingPathComponent("Sources")
                .appendingPathComponent(state.includeFilesTargetName)
            try fm.createDirectory(at: targetDir, withIntermediateDirectories: true)
            
            for includeFile in includeFiles {
                let fileName = includeFile.lastPathComponent
                let destPath = targetDir.appendingPathComponent(fileName)
                
                try? fm.removeItem(at: destPath)
                try fm.copyItem(at: includeFile, to: destPath)
            }
        }
        

        output("swift build\n")
        
        let swiftPath = try getSwiftPath()
        let args = ["build",
                    "--package-path", buildWork.workDir.path]
        
        try execPrintOrCapture(path: swiftPath, arguments: args,
                               print: state.logPrintEnabled ? output : nil)        
    }
    
    func execute(entryIndex: Int) throws -> String {
        let dir = state.entries[entryIndex].path.deletingLastPathComponent()
        let cdBack = changeCurrentDirectory(path: dir)
        defer { cdBack() }
        
        let targetName = state.targetName(index: entryIndex)
        let swiftPath = try getSwiftPath()
        let args = ["run",
                    "--package-path", buildWork.workDir.path,
                    targetName]
        return try execCapture(path: swiftPath,
                               arguments: args)
    }
    
    private let state: Driver.State
    private let workIndex: Int
    private var buildWork: Driver.State.BuildWork {
        get {
            return state.buildWorks[workIndex]
        }
        set {
            state.buildWorks[workIndex] = newValue
        }
    }
    private let output: (String) -> Void
}
