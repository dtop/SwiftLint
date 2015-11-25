//
//  XMLReporter.swift
//  SwiftLint
//
//  Created by Danilo Topalovic on 25.11.15.
//  Copyright © 2015 Realm. All rights reserved.
//

import Foundation

public struct XMLAndroidLintReporter: Reporter {

    public static let identifier = "android-lint"
    public static let isRealtime = false

    private static let root: NSXMLElement = NSXMLElement(name: "issues")

    public var description: String {
        return "Reports violations as a xml readable by Android-Lint on Jenkins"
    }

    public static func generateReport(violations: [StyleViolation]) -> String {

        root.addAttribute(self.makeAttribute(key: "format", stringValue: "4"))
        root.addAttribute(self.makeAttribute(key: "by", stringValue: "swiftlint"))

        let results = violations.map(generateViolationXml)

        for result in results {
            root.addChild(result)
        }

        return root.XMLString
    }

    public static func generateViolationXml(violation: StyleViolation) -> NSXMLElement {

        let issue = NSXMLElement(name: "issue")

        let severity = violation.severity
        let ruleDesc = violation.ruleDescription

//        issue.addAttribute(NSXMLNode.attributeWithName("id", stringValue: violation.) as! NSXMLNode)
        issue.addAttribute(self.makeAttribute(key: "severity", stringValue: severity.rawValue))
        issue.addAttribute(self.makeAttribute(key: "message", stringValue: violation.reason))
        issue.addAttribute(self.makeAttribute(key: "category", stringValue: ruleDesc.identifier))
        issue.addAttribute(self.makeAttribute(key: "priority", stringValue: "7"))
        issue.addAttribute(self.makeAttribute(key: "summary", stringValue: ruleDesc.description))
        issue.addAttribute(self.makeAttribute(key: "explanation", stringValue: ruleDesc.description))
        issue.addAttribute(self.makeAttribute(key: "errorLine1", stringValue: violation.reason))
        issue.addAttribute(self.makeAttribute(key: "errorLine2", stringValue: ""))

        let location = NSXMLElement(name: "location")

        if let file = violation.location.file {
            location.addAttribute(self.makeAttribute(key: "file", stringValue: file))
        }

        if let line = violation.location.line?.description {
            location.addAttribute(self.makeAttribute(key: "line", stringValue: line))
        }

        if let col = violation.location.character?.description {
            location.addAttribute(self.makeAttribute(key: "column", stringValue: col))
        }

        issue.addChild(location)

        return issue
    }

    private static func makeAttribute(key key: String, stringValue value: String) -> NSXMLNode {

        guard let attr = NSXMLNode.attributeWithName(key, stringValue: value) as? NSXMLNode else {

            // this can never happen
            return NSXMLNode()
        }

        return attr
    }

    private static func textualSeverity(severity: ViolationSeverity) -> String {

        switch severity {
        case .Warning:
            return "Warning"

        case .Error:
            return "Error"
        }
    }
}
