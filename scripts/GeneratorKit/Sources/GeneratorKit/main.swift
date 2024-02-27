import Foundation
import Files
import ArgumentParser
import Markdown
import Regex
import Yams

struct Generator: ParsableCommand {
    @Option(name: .long, help: "Path to `help` folder.")
    var path: String

    mutating func run() throws {
        let current = try! Folder(path: self.path)
        let config = try! JSONDecoder().decode(Config.self, from: current.file(named: "config.json").read())
        
        let help = try! current.subfolder(named: "help")
        
        var faq = [Faq]()
        
        let process = { (platform: Platform, folder: Folder) in
            try folder.files.forEach { file in
                guard file.extension == "md" else {
                    return
                }
                
                let frontMatter = frontMatter(from: file)
                
                guard let title = frontMatter?.title else {
                    throw "Looks like `title` is missing from file `\(file.name)`, language `\(folder.name)`"
                }
                
                faq.append(Faq(
                    platform: platform,
                    url: URL(string: "\(folder.path(relativeTo: current))/\(file.name)", relativeTo: config.base)!,
                    title: title,
                    icon: icon(frontMatter: frontMatter, config: config)
                ))
            }
        }
        
        // Process all subfolder
        help.subfolders.forEach { subfolder in
            let platform = Platform(rawValue: subfolder.name) ?? .all
            
            try! process(platform, subfolder)
        }
        
        // Process help folder
        try! process(.all, help)
        
        try! help.createFile(named: "help.json", contents: JSONEncoder().encode(faq.sorted(by: { $0.url.absoluteString < $1.url.absoluteString })))
    }
}

func icon(frontMatter: FrontMatter?, config: Config) -> URL {
    guard let icon = frontMatter?.icon else {
        return config.icon
    }
    
    if icon.hasPrefix(config.base.absoluteString) {
        return URL(string: icon)!
    }
    
    return URL(string: icon, relativeTo: config.base)!
}

func frontMatter(from file: File) -> FrontMatter? {
    let document = try! Document(parsing: file.url)
    var walker = HtmlWalker()
    walker.visit(document)
    
    return walker.frontMatter
}

Generator.main()

// MARK: - The same must be in HelpKit

public struct Config: Codable {
    let base: URL
    let icon: URL
}

public struct Faq: Codable {
    let platform: Platform
    let url: URL
    let title: String
    let icon: URL
}

// MARK: -

enum Platform: String, CaseIterable, Codable {
    case all = "all"
    
    case iOS = "iOS"
    case macOS = "macOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
}

struct FrontMatter: Decodable {
    let title: String
    let icon: String?
}

struct HtmlWalker: MarkupWalker {
    private(set) var frontMatter: FrontMatter?
    
    mutating func visitHTMLBlock(_ html: HTMLBlock) -> Void {
        guard html.indexInParent == 0 else {
            return
        }
    
        guard let _yaml = Regex("---([\\s\\S]+?)---").firstMatch(in: html.rawHTML)?.captures.first, let yaml = _yaml, let data = yaml.data(using: .utf8) else {
            return
        }
        
        self.frontMatter = try? YAMLDecoder().decode(FrontMatter.self, from: data)
    }
}
