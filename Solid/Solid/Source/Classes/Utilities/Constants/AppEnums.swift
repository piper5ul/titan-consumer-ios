//
//  AppEnums.swift
//  Solid
//
//  Created by Solid iOS Team on 10/02/21.

import Foundation
import UIKit
import SwiftUI

public enum IDVStatus: String, Codable {
    case notStarted = "notStarted"
    case completed = "completed"
    case inProgress = "inProgress"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try IDVStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum KYCStatus: String, Codable {
    case notStarted = "notStarted"
    case inReview = "inReview"
    case approved = "approved"
    case declined = "declined"
    case submitted = "submitted"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try KYCStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum KYBStatus: String, Codable {
    case notStarted = "notStarted"
    case inReview = "inReview"
    case approved = "approved"
    case declined = "declined"
    case submitted = "submitted"
    case error = "error"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try KYBStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum DisclosureStatus: String, Codable {
    case notStarted = "notStarted"
    case pending = "pending"
    case completed = "completed"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try DisclosureStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum TaxType: String, Codable {
    case ssn = "ssn"
    case ein = "ein"
    case passport = "passport"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try TaxType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    static var dataNodes: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "SSN", id: TaxType.ssn.rawValue))
        nodes.append(ListItems(title: "Passport", id: TaxType.passport.rawValue))
        return nodes
    }
    
    static func title(for type: String) -> String {
        var title = ""
        _ = TaxType.dataNodes.map { (item)  in
            if item.id == type {
                title = item.title!
            }
        }
        return title
    }

    static func entityId(for type: String) -> String {
        var typeid = ""
        _ = TaxType.dataNodes.map { (item) in
            if item.title == type {
                typeid = item.id!
            }
        }
        return typeid
    }
}

public enum AccountStatus: String, Codable {
    case active = "active"
    case deactivated = "deactivated"
    case approved = "approved"
    case declined = "blocked"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try AccountStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum BusinessEntityType: String, Codable {
    case soleproprietor = "soleProprietor"
    case singlememberllc = "singleMemberLLC"
    case limitedLiabilityCompany = "limitedLiabilityCompany"
    case generalPartnership = "generalPartnership"
    case unlistedCorporation = "unlistedCorporation"
    case publiclyTradedCorporation = "publiclyTradedCorporation"
    case association = "association"
    case nonProfit = "nonProfit"
    case governmentOrganization = "governmentOrganization"
    case revocableTrust = "revocableTrust"
    case irrevocableTrust = "irrevocableTrust"
    case estate = "estate"
    case unknown = "Unknown"

    public init(from decoder: Decoder) throws {
        self = try BusinessEntityType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

    static var dataNodes: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "Association", id: BusinessEntityType.association.rawValue))
        nodes.append(ListItems(title: "Estate", id: BusinessEntityType.estate.rawValue))
        nodes.append(ListItems(title: "General Partnership", id: BusinessEntityType.generalPartnership.rawValue))
        nodes.append(ListItems(title: "Government Organization", id: BusinessEntityType.governmentOrganization.rawValue))
        nodes.append(ListItems(title: "Irrevocable Trust", id: BusinessEntityType.irrevocableTrust.rawValue))
        nodes.append(ListItems(title: "Multi Member LLC", id: BusinessEntityType.limitedLiabilityCompany.rawValue))
        nodes.append(ListItems(title: "Non Profit", id: BusinessEntityType.nonProfit.rawValue))
        nodes.append(ListItems(title: "Publicly Traded Corporation", id: BusinessEntityType.publiclyTradedCorporation.rawValue))
        nodes.append(ListItems(title: "Revocable Trust", id: BusinessEntityType.revocableTrust.rawValue))
        nodes.append(ListItems(title: "Single Member LLC", id: BusinessEntityType.singlememberllc.rawValue))
        nodes.append(ListItems(title: "Sole Proprietor", id: BusinessEntityType.soleproprietor.rawValue))
        nodes.append(ListItems(title: "Unlisted Corporation", id: BusinessEntityType.unlistedCorporation.rawValue))
        return nodes
    }

    var isSoleSingleEntitiy: Bool? {
            switch self {
                case .soleproprietor, .singlememberllc:
                    return true
                default:
                    return false
            }
    }

    static func title(for type: String) -> String {
        var title = ""
        _ = BusinessEntityType.dataNodes.map { (item)  in
            if item.id == type {
                title = item.title!
            }
        }
        return title
    }

    static func entityId(for type: String) -> String {
        var entityid = ""
        _ = BusinessEntityType.dataNodes.map { (item) in
            if item.title == type {
                entityid = item.id!
            }
        }
        return entityid
    }
}

public enum OwnerDesignationType: String, Codable {
    case accountManager = "accountManager"
    case accountant = "accountant"
    case analyst = "analyst"
    case chairman = "chairman"
    case chairmanOfTheBoardOfDirectors = "chairmanOfTheBoardOfDirectors"
    case chiefBrandOfficer = "chiefBrandOfficer"
    case chiefBusinessOfficer = "chiefBusinessOfficer"
    case chiefCreditOfficer = "chiefCreditOfficer"
    case chiefExecutiveOfficer = "chiefExecutiveOfficer"
    case chiefFinancialOfficer = "chiefFinancialOfficer"
    case chiefInnovationOfficer = "chiefInnovationOfficer"
    case chiefLegalOfficer = "chiefLegalOfficer"
    case chiefMarketingOfficer = "chiefMarketingOfficer"
    case chiefOperatingOfficer = "chiefOperatingOfficer"
    case chiefOfStaff = "chiefOfStaff"
    case chiefProductOfficer = "chiefProductOfficer"
    case chiefRevenueOfficer = "chiefRevenueOfficer"
    case chiefTechnologyOfficer = "chiefTechnologyOfficer"
    case comptroller = "comptroller"
    case controller = "controller"
    case designer = "designer"
    case digitalMarketingManager = "digitalMarketingManager"
    case engineer = "engineer"
    case executiveVicePresident = "executiveVicePresident"
    case financeManager = "financeManager"
    case financialAdvisor = "financialAdvisor"
    case founder = "founder"
    case generalCounsel = "generalCounsel"
    case generalManager = "generalManager"
    case generalPartner = "generalPartner"
    case headOfFinance = "headOfFinance"
    case headOfOperations = "headOfOperations"
    case humanResourcesManager = "humanResourcesManager"
    case managingDirector = "managingDirector"
    case managingMember = "managingMember"
    case managingPartner = "managingPartner"
    case manager = "manager"
    case member = "member"
    case partner = "partner"
    case president = "president"
    case productManager = "productManager"
    case projectManager = "projectManager"
    case salesManager = "salesManager"
    case secretary = "secretary"
    case taxSpecialist = "taxSpecialist"
    case treasurer = "treasurer"
    case vicePresident = "vicePresident"
    case other = "other"
    case unknown = "unknown"

    public init(from decoder: Decoder) throws {
        self = try OwnerDesignationType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

    static var ownerDesignations: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "Account Manager", id: OwnerDesignationType.accountManager.rawValue))
        nodes.append(ListItems(title: "Accountant", id: OwnerDesignationType.accountant.rawValue))
        nodes.append(ListItems(title: "Analyst", id: OwnerDesignationType.analyst.rawValue))
        nodes.append(ListItems(title: "Chairman", id: OwnerDesignationType.chairman.rawValue))
        nodes.append(ListItems(title: "Chairman of the Board of Directors", id: OwnerDesignationType.chairmanOfTheBoardOfDirectors.rawValue))
        nodes.append(ListItems(title: "Chief Brand Officer", id: OwnerDesignationType.chiefBrandOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Business Officer", id: OwnerDesignationType.chiefBusinessOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Credit Officer", id: OwnerDesignationType.chiefCreditOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Executive Officer", id: OwnerDesignationType.chiefExecutiveOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Financial Officer", id: OwnerDesignationType.chiefFinancialOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Innovation Officer", id: OwnerDesignationType.chiefInnovationOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Legal Officer", id: OwnerDesignationType.chiefLegalOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Marketing Officer", id: OwnerDesignationType.chiefMarketingOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Operating Officer", id: OwnerDesignationType.chiefOperatingOfficer.rawValue))
        nodes.append(ListItems(title: "Chief of Staff", id: OwnerDesignationType.chiefOfStaff.rawValue))
        nodes.append(ListItems(title: "Chief Product Officer", id: OwnerDesignationType.chiefProductOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Revenue Officer", id: OwnerDesignationType.chiefRevenueOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Technology Officer", id: OwnerDesignationType.chiefTechnologyOfficer.rawValue))
        nodes.append(ListItems(title: "Comptroller", id: OwnerDesignationType.comptroller.rawValue))
        nodes.append(ListItems(title: "Controller", id: OwnerDesignationType.controller.rawValue))
        nodes.append(ListItems(title: "Designer", id: OwnerDesignationType.designer.rawValue))
        nodes.append(ListItems(title: "Digital Marketing Manager", id: OwnerDesignationType.digitalMarketingManager.rawValue))
        nodes.append(ListItems(title: "Engineer", id: OwnerDesignationType.engineer.rawValue))
        nodes.append(ListItems(title: "Executive Vice President", id: OwnerDesignationType.executiveVicePresident.rawValue))
        nodes.append(ListItems(title: "Finance Manager", id: OwnerDesignationType.financeManager.rawValue))
        nodes.append(ListItems(title: "Financial Advisor", id: OwnerDesignationType.financialAdvisor.rawValue))
        nodes.append(ListItems(title: "Founder", id: OwnerDesignationType.founder.rawValue))
        nodes.append(ListItems(title: "General Counsel", id: OwnerDesignationType.generalCounsel.rawValue))
        nodes.append(ListItems(title: "General Manager", id: OwnerDesignationType.generalManager.rawValue))
        nodes.append(ListItems(title: "General Partner", id: OwnerDesignationType.generalPartner.rawValue))
        nodes.append(ListItems(title: "Head of Finance", id: OwnerDesignationType.headOfFinance.rawValue))
        nodes.append(ListItems(title: "Head of Operations", id: OwnerDesignationType.headOfOperations.rawValue))
        nodes.append(ListItems(title: "Human Resources Manager", id: OwnerDesignationType.humanResourcesManager.rawValue))
        nodes.append(ListItems(title: "Managing Director", id: OwnerDesignationType.managingDirector.rawValue))
        nodes.append(ListItems(title: "Managing Member", id: OwnerDesignationType.managingMember.rawValue))
        nodes.append(ListItems(title: "Managing Partner", id: OwnerDesignationType.managingPartner.rawValue))
        nodes.append(ListItems(title: "Manager", id: OwnerDesignationType.manager.rawValue))
        nodes.append(ListItems(title: "Member", id: OwnerDesignationType.member.rawValue))
        nodes.append(ListItems(title: "Partner", id: OwnerDesignationType.partner.rawValue))
        nodes.append(ListItems(title: "President", id: OwnerDesignationType.president.rawValue))
        nodes.append(ListItems(title: "Product Manager", id: OwnerDesignationType.productManager.rawValue))
        nodes.append(ListItems(title: "Project Manager", id: OwnerDesignationType.projectManager.rawValue))
        nodes.append(ListItems(title: "Sales Manager", id: OwnerDesignationType.salesManager.rawValue))
        nodes.append(ListItems(title: "Tax Specialist", id: OwnerDesignationType.taxSpecialist.rawValue))
        nodes.append(ListItems(title: "Treasurer", id: OwnerDesignationType.treasurer.rawValue))
        nodes.append(ListItems(title: "Vice President", id: OwnerDesignationType.vicePresident.rawValue))
        nodes.append(ListItems(title: "Other", id: OwnerDesignationType.other.rawValue))
        return nodes
    }

    static var controlPersonDesignations: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "Chairman of the Board of Directors", id: OwnerDesignationType.chairmanOfTheBoardOfDirectors.rawValue))
        nodes.append(ListItems(title: "Chief Executive Officer", id: OwnerDesignationType.chiefExecutiveOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Financial Officer", id: OwnerDesignationType.chiefFinancialOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Legal Officer", id: OwnerDesignationType.chiefLegalOfficer.rawValue))
        nodes.append(ListItems(title: "Chief Operating Officer", id: OwnerDesignationType.chiefOperatingOfficer.rawValue))
        nodes.append(ListItems(title: "Comptroller", id: OwnerDesignationType.comptroller.rawValue))
        nodes.append(ListItems(title: "Executive Vice President", id: OwnerDesignationType.executiveVicePresident.rawValue))
        nodes.append(ListItems(title: "General Counsel", id: OwnerDesignationType.generalCounsel.rawValue))
        nodes.append(ListItems(title: "General Partner", id: OwnerDesignationType.generalPartner.rawValue))
        nodes.append(ListItems(title: "Managing Director", id: OwnerDesignationType.managingDirector.rawValue))
        nodes.append(ListItems(title: "Managing Member", id: OwnerDesignationType.managingMember.rawValue))
        nodes.append(ListItems(title: "Managing Partner", id: OwnerDesignationType.managingPartner.rawValue))
        nodes.append(ListItems(title: "Member", id: OwnerDesignationType.member.rawValue))
        nodes.append(ListItems(title: "Partner", id: OwnerDesignationType.partner.rawValue))
        nodes.append(ListItems(title: "President", id: OwnerDesignationType.president.rawValue))
        nodes.append(ListItems(title: "Treasurer", id: OwnerDesignationType.treasurer.rawValue))
        nodes.append(ListItems(title: "Vice President", id: OwnerDesignationType.vicePresident.rawValue))
        return nodes
    }

    static func title(for type: String) -> String {
        var title = ""
        _ = OwnerDesignationType.ownerDesignations.map { (item)  in
            if item.id == type {
                title = item.title!
            }
        }
        return title
    }

    static func entityId(for type: String) -> String {
        var entityid = ""
        _ = OwnerDesignationType.ownerDesignations.map { (item) in
            if item.title == type {
                entityid = item.id!
            }
        }
        return entityid
    }
    
    static func entityType(for type: String) -> OwnerDesignationType {
        switch type {
        case "accountManager":
            return .accountManager
        case "accountant":
            return .accountant
        case "analyst":
            return .analyst
        case "chairman":
            return .chairman
        case "chairmanOfTheBoardOfDirectors":
            return .chairmanOfTheBoardOfDirectors
        case "chiefBrandOfficer":
            return .chiefBrandOfficer
        case "chiefBusinessOfficer":
            return .chiefBusinessOfficer
        case "chiefCreditOfficer":
            return .chiefCreditOfficer
        case "chiefExecutiveOfficer":
            return .chiefExecutiveOfficer
        case "chiefFinancialOfficer":
            return .chiefFinancialOfficer
        case "chiefInnovationOfficer":
            return .chiefInnovationOfficer
        case "chiefLegalOfficer":
            return .chiefLegalOfficer
        case "chiefMarketingOfficer":
            return .chiefMarketingOfficer
        case "chiefOperatingOfficer":
            return .chiefOperatingOfficer
        case "chiefOfStaff":
            return .chiefOfStaff
        case "chiefProductOfficer":
            return .chiefProductOfficer
        case "chiefRevenueOfficer":
            return .chiefRevenueOfficer
        case "chiefTechnologyOfficer":
            return .chiefTechnologyOfficer
        case "comptroller":
            return .comptroller
        case "controller":
            return .controller
        case "designer":
            return .designer
        case "digitalMarketingManager":
            return .digitalMarketingManager
        case "engineer":
            return .engineer
        case "executiveVicePresident":
            return .executiveVicePresident
        case "financeManager":
            return .financeManager
        case "financialAdvisor":
            return .financialAdvisor
        case "founder":
            return .founder
        case "generalCounsel":
            return .generalCounsel
        case "generalManager":
            return .generalManager
        case "generalPartner":
            return .generalPartner
        case "headOfFinance":
            return .headOfFinance
        case "headOfOperations":
            return .headOfOperations
        case "humanResourcesManager":
            return .humanResourcesManager
        case "managingDirector":
            return .managingDirector
        case "managingMember":
            return .managingMember
        case "managingPartner":
            return .managingPartner
        case "manager":
            return .manager
        case "member":
            return .member
        case "partner":
            return .partner
        case "president":
            return .president
        case "productManager":
            return .productManager
        case "projectManager":
            return .projectManager
        case "salesManager":
            return .salesManager
        case "secretary":
            return .secretary
        case "taxSpecialist":
            return .taxSpecialist
        case "treasurer":
            return .treasurer
        case "vicePresident":
            return .vicePresident
        case "other":
            return .other
        default:
            return .unknown
        }
    }
}

enum DashboardSectionEnums: String, CaseIterable {
    case accounts = "accounts"
    case movemoney = "movemoney"
    case contacts = "contacts"
    case transactions = "transactions"
    case cards = "cards"

    var localizedString: String {
        switch self {
            case .accounts:
                return Utility.localizedString(forKey: "dashboard_section_acc")
            case .movemoney:
                return Utility.localizedString(forKey: "dashboard_section_movemoney")
            case .contacts:
                return Utility.localizedString(forKey: "cotacts_list_header")
            case .transactions:
                return Utility.localizedString(forKey: "dashboard_section_transactions")
            case .cards:
                return Utility.localizedString(forKey: "dashboard_section_cards")
        }
    }

    static let allValues = [accounts, transactions, cards]
}

// MARK: - Cards
public enum CardSpendLimitTypes: String, Codable, CaseIterable {
    case perMonth = "monthly"
    case perTransaction = "perTransaction"
    case perWeek = "weekly"
    case perYear = "yearly"
    case perDay = "daily"
    case allTime = "allTime"
    case unknown = ""

    func localizeLimit() -> String {
        switch self {
            case .perMonth: return Utility.localizedString(forKey: "limitMonth")
            case .perTransaction: return Utility.localizedString(forKey: "limitTransaction")
            case .perWeek: return Utility.localizedString(forKey: "limitWeek")
            case .perYear: return Utility.localizedString(forKey: "limitYear")
            case .perDay: return Utility.localizedString(forKey: "limitDay")
            case .allTime: return Utility.localizedString(forKey: "limitAllTime")
            case .unknown: return ""
        }
    }

    func localizeDescription() -> String {
        switch self {
            case .perMonth: return Utility.localizedString(forKey: "limitPerMonth")
            case .perTransaction: return Utility.localizedString(forKey: "limitPerTransaction")
            case .perWeek: return Utility.localizedString(forKey: "limitPerWeek")
            case .perYear: return Utility.localizedString(forKey: "limitPerYear")
            case .perDay: return Utility.localizedString(forKey: "limitPerDay")
            case .allTime: return Utility.localizedString(forKey: "allTime")
            case .unknown: return ""
        }
    }

    static let allValues = [perMonth, perTransaction, perWeek, perYear, perDay, allTime]

    var index: Int {
        return CardSpendLimitTypes.allValues.firstIndex(of: self) ?? -1
    }
}

// Card Types
public enum CardType: String, Codable {
    case physical = "physical"
    case virtual = "virtual"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try CardType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

    func localizeDescription() -> String {
        switch self {
        case .physical:
            return Utility.localizedString(forKey: "cardType_physical")
        case .virtual:
            return Utility.localizedString(forKey: "cardType_virtual")
        case .unknown:
            return ""
        }
    }
    
    func localizecardTypeDescription() -> String {
        switch self {
            case .physical:
                return Utility.localizedString(forKey: "create_cardType_physical")
            case .virtual:
                return Utility.localizedString(forKey: "create_cardType_virtual")
            case .unknown:
                return ""
        }
    }

    func localizeCardDetail() -> String {
        switch self {
            case .physical:
                return Utility.localizedString(forKey: "cardType_physical_Description")
            case .virtual:
                return Utility.localizedString(forKey: "cardType_virtual_Description")
            case .unknown:
                return ""
        }
    }

    static let allValues = [physical, virtual]

    var index: Int {
        return CardType.allValues.firstIndex(of: self) ?? -1
    }
}

// Card Status
public enum CardStatus: String, Codable {
    case pendingActivation = "pendingActivation"
    case active = "active"
    case inactive = "inactive"
    case canceled = "canceled"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try CardStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

    func localizeDescription() -> String {
        switch self {
        case .pendingActivation:
            return Utility.localizedString(forKey: "cardStatus_pendingActivation")
        case .active:
            return Utility.localizedString(forKey: "cardStatus_active")
        case .inactive:
            return Utility.localizedString(forKey: "cardStatus_inActive")
        case .canceled:
            return Utility.localizedString(forKey: "cardStatus_canceled")
        case .unknown:
            return ""
        }
    }

    var statusColor: UIColor? {
        var bgColor = UIColor(hexString: "#7A51F0")
        switch self {
            case .active:
                bgColor = UIColor.greenMain
            case .pendingActivation:
                bgColor = UIColor.primaryColor
            case .inactive:
                bgColor = UIColor.redMain
            case .canceled:
                bgColor = UIColor.systemGray
            case .unknown:
                return bgColor
        }
        return bgColor
    }
}

// Card Delivery Status
public enum CardDeliveryStatus: String, Codable {
    case delivered = "delivered"
    case pending = "pending"
    case shipped = "shipped"
    case returned = "returned"
    case failure = "failure"
    case canceled = "canceled"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try CardDeliveryStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

// FOR TRANSACTIONS..
public enum TransactionType: String, Codable {
    case credit = "credit"
    case debit = "debit"
    case card = "card"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum TransferType: String, Codable {
    case ACH = "ach"
    case wire = "domesticWire"
    case card = "card"
    case check = "physicalCheck"
    case cash = "cash"
    case intrabank = "intrabank"
    case solidCard = "solidCard"
    case debitCard = "debitCard"
    case internationalWire = "internationalWire"
    case crossBorder = "crossBorder"

    case unknown

    func localizedDescription() -> String {
        var description = ""
        switch self {
        case .ACH:
            description = Utility.localizedString(forKey: "enum_TransferType_ACH")
        case .wire, .internationalWire:
            description = Utility.localizedString(forKey: "enum_TransferType_wire")
        case .card, .debitCard:
            description = Utility.localizedString(forKey: "enum_TransferType_card")
        case .check:
            description = Utility.localizedString(forKey: "enum_TransferType_check")
        case .cash:
            description = Utility.localizedString(forKey: "enum_TransferType_cash")
        case .intrabank:
            description = Utility.localizedString(forKey: "enum_TransferType_intrabank")
        case .solidCard:
            description = Utility.localizedString(forKey: "enum_TransferType_solidcard")
        case .crossBorder:
            description = Utility.localizedString(forKey: "enum_TransferType_crossBorder")
        default:
            break
        }
        return description
    }

    func colorForType() -> UIColor {
        var aColor = UIColor.clear
        switch self {
        case .card, .debitCard:
            aColor = UIColor.trnsTypeCardColor
        case .intrabank, .crossBorder:
            aColor = UIColor.trnsTypeIntrabankColor
        case .ACH, .solidCard:
            aColor = UIColor.trnsTypeACHColor
        case .check:
            aColor = UIColor.trnsTypeCheckColor
        case .wire:
            aColor = UIColor.trnsTypeWireColor
        default:
            aColor = UIColor.trnsTypeDefaultColor
        }
        return aColor
    }

    public init(from decoder: Decoder) throws {
        self = try TransferType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum TransactionStatus: String, Codable {
    case declined = "declined"
    case settled = "settled"
    case pending = "pending"
    case returned = "returned"
    case unknown

    func colorForType() -> UIColor {
        var aColor = UIColor.clear
        switch self {
            case .declined:
                aColor = UIColor.redMain
            case .settled:
                aColor = UIColor.blueMain
            case .returned:
                aColor = UIColor.redMain
            default:
                aColor = UIColor.yellowMain
        }
        return aColor
    }

    public init(from decoder: Decoder) throws {
        self = try TransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum TransactionTimePeriod: Int, CaseIterable, Codable {
    case week = 1
    case month
    case lastMonth
    case custom
    case NA

    func localizedDescription() -> String {
        var description = ""
        switch self {
        case .week:
            description = Utility.localizedString(forKey: "this_week")
        case .month:
            description = Utility.localizedString(forKey: "this_month")
        case .lastMonth:
            description = Utility.localizedString(forKey: "last_month")
        default:
            break
        }

        return description
    }
}

public enum CheckStatus: String, Codable {
    case declined = "declined"
    case settled = "settled"
    case pending = "pending"
    case returned = "returned"
    case completed = "completed"
    case unknown

    func localizeDescription() -> String {
        switch self {
            case .declined: return Utility.localizedString(forKey: "RCD_declined")
            case .settled: return Utility.localizedString(forKey: "RCD_settled")
            case .returned: return Utility.localizedString(forKey: "RCD_returned")
            case .completed: return Utility.localizedString(forKey: "RCD_completed")
            default: return Utility.localizedString(forKey: "RCD_pending")
        }
    }

    func colorForType() -> UIColor {
        var aColor = UIColor.clear
        switch self {
            case .declined, .returned:
                aColor = UIColor.redMain
            case .settled, .completed:
                aColor = UIColor.blueMain
            default:
                aColor = UIColor.yellowMain
        }
        return aColor
    }

    public init(from decoder: Decoder) throws {
        self = try CheckStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum FundType {
    case checkDeposit
    case unknown
}

public enum PaymentStatus: String, Codable {
    case settled
    case declined
    case completed
    case pending
    case canceled
    case refund
    case unknown

    public init(from decoder: Decoder) throws {
        self = try PaymentStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum OwnerFlow {
    case mainOwner
    case additionalOwner
}

enum ContactFlow {
    case create
    case edit
}

enum AppFlow {
    case AO
    case PO
}

enum POFlow {
    case addBusiness
    case addAccount
}

enum PullFundsFlow {
    case pullFundsIn
    case pullFundsOut
    case debitPull
}

public enum BiometricStatus {
    case success
    case failure
    case notAvailable
    case lockedOut
    case cancel
}

enum CheckImageSide {
    case front
    case rear
}

public enum CaptureActions {
    case upload
    case capture
    case retake
}

public enum TransactionListingType {
    case transaction
    case card
    case payment
}

enum NavigationButton {
    case leftButton
    case rightButton
}

enum PaymentType: String {
    case cash = "USD"
}

// Contact Status
public enum ContactStatus: String, Codable {
    case active = "active"
    case deleted = "deleted"
    case blocked = "blocked"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try ContactStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum InternationalWireAccountType: String, Codable {
    case personal
    case business
    case unknown
    
    static var dataNodes: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "Personal", id: InternationalWireAccountType.personal.rawValue))
        nodes.append(ListItems(title: "Business", id: InternationalWireAccountType.business.rawValue))
        return nodes
    }
    
    public init(from decoder: Decoder) throws {
        self = try InternationalWireAccountType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    static func title(for type: String) -> String {
        var title = ""
        _ = InternationalWireAccountType.dataNodes.map { (item)  in
            if item.id == type {
                title = item.title!
            }
        }
        return title
    }
    
    static func entityId(for type: String) -> String {
        var entityid = ""
        _ = InternationalWireAccountType.dataNodes.map { (item) in
            if item.title == type {
                entityid = item.id!
            }
        }
        return entityid
    }
}

// Contact Status
public enum AccountType: String, Codable {
    case personalChecking = "personalChecking"
    case businessChecking = "businessChecking"
    case personalSavings = "personalSavings"
    case businessSavings = "businessSavings"
    case cardAccount = "cardAccount"
    case unknown

    static var dataNodes: [ListItems] {
        var nodes = [ListItems]()
        nodes.append(ListItems(title: "Personal Checking", id: AccountType.personalChecking.rawValue))
        nodes.append(ListItems(title: "Business Checking", id: AccountType.businessChecking.rawValue))
        nodes.append(ListItems(title: "Personal Savings", id: AccountType.personalSavings.rawValue))
        nodes.append(ListItems(title: "Business Savings", id: AccountType.businessSavings.rawValue))
        return nodes
    }

    public init(from decoder: Decoder) throws {
        self = try AccountType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }

    static func title(for type: String) -> String {
        var title = ""
        _ = AccountType.dataNodes.map { (item)  in
            if item.id == type {
                title = item.title!
            }
        }
        return title
    }

    static func entityId(for type: String) -> String {
        var entityid = ""
        _ = AccountType.dataNodes.map { (item) in
            if item.title == type {
                entityid = item.id!
            }
        }
        return entityid
    }
    
    func localizeType() -> String {
        return self == .cardAccount ? Utility.localizedString(forKey: "card") : Utility.localizedString(forKey: "cash")
    }

    func colorForType() -> UIColor {
        return self == .cardAccount ? UIColor.trnsTypeDefaultColor : UIColor.trnsTypeACHColor
    }
}
