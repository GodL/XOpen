
import ArgumentParser
import PathKit
import ShellOut

struct XOpen: ParsableCommand {
    
    @Argument(help: "A keyword to match the file to open")
    var keyword: String?
    
    func run() throws {
    
        let paths: [Path] = try findXocdeProject()
        
        if let key = keyword?.lowercased(), let path = paths.first(where: { $0.lastComponent.lowercased().contains(key) }) {
            try open(path: path)
            return
        }
        
        if let workspace = paths.first(where: { $0.lastComponent.hasSuffix(".xcworkspace") }) {
            try open(path: workspace)
        }else if let xcodeproj = paths.first(where: { $0.lastComponent.hasSuffix(".xcodeproj") }) {
            try open(path: xcodeproj)
        }else if let packageSwift = paths.first(where:  { $0.lastComponent.hasSuffix("Package.swift") }) {
            try open(path: packageSwift)
        }else {
            print("there are noting xcode project to open")
        }
    }
    
    func findXocdeProject() throws -> [Path] {
        let filters = ["Package.swift",".xcworkspace",".xcodeproj"]
        
        let filterHandler: (Path) -> Bool = {
            return $0.lastComponent.hasSuffix(filters.first!) || $0.lastComponent.hasSuffix(filters[1]) || $0.lastComponent.hasSuffix(filters.last!)
        }
        
        let paths = try Path.current.children().filter { filterHandler($0) }
        
        if paths.count > 0 {
            return paths
        }
        
        return try Path.current.recursiveChildren().filter { filterHandler($0) }
    }
    
    func open(path: Path) throws {
        try shellOut(to: "open \(path.string)")
    }
}

XOpen.main()
