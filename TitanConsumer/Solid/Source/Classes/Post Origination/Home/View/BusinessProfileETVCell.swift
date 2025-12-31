//
//  BusinessProfileETVCell.swift
//  Solid
//
//  Created by Solid iOS Team on 01/01/24.
//  Copyright © 2024 Solid. All rights reserved.
//

import UIKit

class BusinessProfileETVCell: UITableViewCell {
    //...SEND...//
    @IBOutlet weak var lblTitleSend: UILabel!
    
    //HEADER...
    @IBOutlet weak var lblSendTrnsType: UILabel!
    @IBOutlet weak var lblSendExpActivity: UILabel!
    @IBOutlet weak var lblSendExpCount: UILabel!
    
    //TITLE...
    @IBOutlet weak var lblTitleSendACH: UILabel!
    @IBOutlet weak var lblTitleSendIACH: UILabel!
    @IBOutlet weak var lblTitleSendDWire: UILabel!
    @IBOutlet weak var lblTitleSendIWire: UILabel!
    @IBOutlet weak var lblTitleSendCheck: UILabel!
    
    //ETV RANGE...
    @IBOutlet weak var lblETVRangeSendACH: UILabel!
    @IBOutlet weak var lblETVRangeSendIACH: UILabel!
    @IBOutlet weak var lblETVRangeSendDWire: UILabel!
    @IBOutlet weak var lblETVRangeSendIWire: UILabel!
    @IBOutlet weak var lblETVRangeSendCheck: UILabel!
    
    //ETV COUNT...
    @IBOutlet weak var lblETVCountSendACH: UILabel!
    @IBOutlet weak var lblETVCountSendIACH: UILabel!
    @IBOutlet weak var lblETVCountSendDWire: UILabel!
    @IBOutlet weak var lblETVCountSendIWire: UILabel!
    @IBOutlet weak var lblETVCountSendCheck: UILabel!
    
    //...RECEIVE...//
    @IBOutlet weak var lblTitleReceive: UILabel!
    
    //HEADER...
    @IBOutlet weak var lblReceiveTrnsType: UILabel!
    @IBOutlet weak var lblReceiveExpActivity: UILabel!
    @IBOutlet weak var lblReceiveExpCount: UILabel!
    
    //TITLE...
    @IBOutlet weak var lblTitleReceiveACH: UILabel!
    @IBOutlet weak var lblTitleReceiveCheck: UILabel!
    
    //ETV RANGE...
    @IBOutlet weak var lblETVRangeReceiveACH: UILabel!
    @IBOutlet weak var lblETVRangeReceiveCheck: UILabel!
    
    //ETV COUNT...
    @IBOutlet weak var lblETVCountReceiveACH: UILabel!
    @IBOutlet weak var lblETVCountReceiveCheck: UILabel!
    
    //...INCOMING...//
    @IBOutlet weak var lblTitleIncoming: UILabel!

    //HEADER...
    @IBOutlet weak var lblIncomingTrnsType: UILabel!
    @IBOutlet weak var lblIncomingExpActivity: UILabel!
    @IBOutlet weak var lblIncomingExpCount: UILabel!
    
    //TITLE...
    @IBOutlet weak var lblTitleIncomingACHPush: UILabel!
    @IBOutlet weak var lblTitleIncomingACHPull: UILabel!
    @IBOutlet weak var lblTitleIncomingIACH: UILabel!
    @IBOutlet weak var lblTitleIncomingDWire: UILabel!
    @IBOutlet weak var lblTitleIncomingIWire: UILabel!
    
    //ETV RANGE...
    @IBOutlet weak var lblETVRangeIncomingACHPush: UILabel!
    @IBOutlet weak var lblETVRangeIncomingACHPull: UILabel!
    @IBOutlet weak var lblETVRangeIncomingIACH: UILabel!
    @IBOutlet weak var lblETVRangeIncomingDWire: UILabel!
    @IBOutlet weak var lblETVRangeIncomingIWire: UILabel!
    
    //ETV COUNT...
    @IBOutlet weak var lblETVCountIncomingACHPush: UILabel!
    @IBOutlet weak var lblETVCountIncomingACHPull: UILabel!
    @IBOutlet weak var lblETVCountIncomingIACH: UILabel!
    @IBOutlet weak var lblETVCountIncomingDWire: UILabel!
    @IBOutlet weak var lblETVCountIncomingIWire: UILabel!
    
    override func awakeFromNib() {
        self.setUI()
        
        self.backgroundColor = .background
    }
    
    func setUI() {
        let titleFont = Utility.isDeviceIpad() ? Constants.mediumFontSize18 : Constants.mediumFontSize14
        let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize12

        //...SEND...//
        lblTitleSend.text = Utility.localizedString(forKey: "send")
        lblTitleSend.font = titleFont
        lblTitleSend.textAlignment = .left
        lblTitleSend.textColor = .primaryColor
        
        lblSendTrnsType.text = Utility.localizedString(forKey: "trns_type")
        lblSendTrnsType.font = labelFont
        lblSendTrnsType.textAlignment = .left
        lblSendTrnsType.textColor = .secondaryColorWithOpacity
        
        lblSendExpActivity.text = Utility.localizedString(forKey: "expected_activity")
        lblSendExpActivity.font = labelFont
        lblSendExpActivity.textAlignment = .left
        lblSendExpActivity.textColor = .secondaryColorWithOpacity
        
        lblSendExpCount.text = Utility.localizedString(forKey: "expected_count")
        lblSendExpCount.font = labelFont
        lblSendExpCount.textAlignment = .left
        lblSendExpCount.textColor = .secondaryColorWithOpacity
        
        //ACH
        lblTitleSendACH.text = Utility.localizedString(forKey: "ach")
        lblTitleSendACH.font = labelFont
        lblTitleSendACH.textAlignment = .left
        lblTitleSendACH.textColor = .secondaryColorWithOpacity
        
        lblETVRangeSendACH.font = labelFont
        lblETVRangeSendACH.textAlignment = .left
        lblETVRangeSendACH.textColor = .primaryColor

        lblETVCountSendACH.font = labelFont
        lblETVCountSendACH.textAlignment = .left
        lblETVCountSendACH.textColor = .primaryColor
        
        //IACH
        lblTitleSendIACH.text = "Int. ACH"
        lblTitleSendIACH.font = labelFont
        lblTitleSendIACH.textAlignment = .left
        lblTitleSendIACH.textColor = .secondaryColorWithOpacity
        
        lblETVRangeSendIACH.font = labelFont
        lblETVRangeSendIACH.textAlignment = .left
        lblETVRangeSendIACH.textColor = .primaryColor

        lblETVCountSendIACH.font = labelFont
        lblETVCountSendIACH.textAlignment = .left
        lblETVCountSendIACH.textColor = .primaryColor
        
        //DWIRE
        lblTitleSendDWire.text = Utility.localizedString(forKey: "domesticWire")
        lblTitleSendDWire.font = labelFont
        lblTitleSendDWire.textAlignment = .left
        lblTitleSendDWire.textColor = .secondaryColorWithOpacity
        
        lblETVRangeSendDWire.font = labelFont
        lblETVRangeSendDWire.textAlignment = .left
        lblETVRangeSendDWire.textColor = .primaryColor

        lblETVCountSendDWire.font = labelFont
        lblETVCountSendDWire.textAlignment = .left
        lblETVCountSendDWire.textColor = .primaryColor
        
        //IWIRE
        lblTitleSendIWire.text = "Intl. Wire"
        lblTitleSendIWire.font = labelFont
        lblTitleSendIWire.textAlignment = .left
        lblTitleSendIWire.textColor = .secondaryColorWithOpacity
        
        lblETVRangeSendIWire.font = labelFont
        lblETVRangeSendIWire.textAlignment = .left
        lblETVRangeSendIWire.textColor = .primaryColor

        lblETVCountSendIWire.font = labelFont
        lblETVCountSendIWire.textAlignment = .left
        lblETVCountSendIWire.textColor = .primaryColor
        
        //CHECK
        lblTitleSendCheck.text = Utility.localizedString(forKey: "physicalCheck")
        lblTitleSendCheck.font = labelFont
        lblTitleSendCheck.textAlignment = .left
        lblTitleSendCheck.textColor = .secondaryColorWithOpacity
        
        lblETVRangeSendCheck.font = labelFont
        lblETVRangeSendCheck.textAlignment = .left
        lblETVRangeSendCheck.textColor = .primaryColor

        lblETVCountSendCheck.font = labelFont
        lblETVCountSendCheck.textAlignment = .left
        lblETVCountSendCheck.textColor = .primaryColor
        
        //...RECEIVE...//
        lblTitleReceive.text = Utility.localizedString(forKey: "receive")
        lblTitleReceive.font = titleFont
        lblTitleReceive.textAlignment = .left
        lblTitleReceive.textColor = .primaryColor
        
        lblReceiveTrnsType.text = Utility.localizedString(forKey: "trns_type")
        lblReceiveTrnsType.font = labelFont
        lblReceiveTrnsType.textAlignment = .left
        lblReceiveTrnsType.textColor = .secondaryColorWithOpacity
        
        lblReceiveExpActivity.text = Utility.localizedString(forKey: "expected_activity")
        lblReceiveExpActivity.font = labelFont
        lblReceiveExpActivity.textAlignment = .left
        lblReceiveExpActivity.textColor = .secondaryColorWithOpacity
        
        lblReceiveExpCount.text = Utility.localizedString(forKey: "expected_count")
        lblReceiveExpCount.font = labelFont
        lblReceiveExpCount.textAlignment = .left
        lblReceiveExpCount.textColor = .secondaryColorWithOpacity
        
        //ACH
        lblTitleReceiveACH.text = Utility.localizedString(forKey: "ach")
        lblTitleReceiveACH.font = labelFont
        lblTitleReceiveACH.textAlignment = .left
        lblTitleReceiveACH.textColor = .secondaryColorWithOpacity
        
        lblETVRangeReceiveACH.font = labelFont
        lblETVRangeReceiveACH.textAlignment = .left
        lblETVRangeReceiveACH.textColor = .primaryColor

        lblETVCountReceiveACH.font = labelFont
        lblETVCountReceiveACH.textAlignment = .left
        lblETVCountReceiveACH.textColor = .primaryColor
        
        //CHECK
        lblTitleReceiveCheck.text = Utility.localizedString(forKey: "physicalCheck")
        lblTitleReceiveCheck.font = labelFont
        lblTitleReceiveCheck.textAlignment = .left
        lblTitleReceiveCheck.textColor = .secondaryColorWithOpacity
        
        lblETVRangeReceiveCheck.font = labelFont
        lblETVRangeReceiveCheck.textAlignment = .left
        lblETVRangeReceiveCheck.textColor = .primaryColor

        lblETVCountReceiveCheck.font = labelFont
        lblETVCountReceiveCheck.textAlignment = .left
        lblETVCountReceiveCheck.textColor = .primaryColor
        
        //...INCOMING...//
        lblTitleIncoming.text = Utility.localizedString(forKey: "incoming")
        lblTitleIncoming.font = titleFont
        lblTitleIncoming.textAlignment = .left
        lblTitleIncoming.textColor = .primaryColor
        
        lblIncomingTrnsType.text = Utility.localizedString(forKey: "trns_type")
        lblIncomingTrnsType.font = labelFont
        lblIncomingTrnsType.textAlignment = .left
        lblIncomingTrnsType.textColor = .secondaryColorWithOpacity
        
        lblIncomingExpActivity.text = Utility.localizedString(forKey: "expected_activity")
        lblIncomingExpActivity.font = labelFont
        lblIncomingExpActivity.textAlignment = .left
        lblIncomingExpActivity.textColor = .secondaryColorWithOpacity
        
        lblIncomingExpCount.text = Utility.localizedString(forKey: "expected_count")
        lblIncomingExpCount.font = labelFont
        lblIncomingExpCount.textAlignment = .left
        lblIncomingExpCount.textColor = .secondaryColorWithOpacity
        
        //ACH PUSH
        lblTitleIncomingACHPush.text = Utility.localizedString(forKey: "achPush")
        lblTitleIncomingACHPush.font = labelFont
        lblTitleIncomingACHPush.textAlignment = .left
        lblTitleIncomingACHPush.textColor = .secondaryColorWithOpacity
        
        lblETVRangeIncomingACHPush.font = labelFont
        lblETVRangeIncomingACHPush.textAlignment = .left
        lblETVRangeIncomingACHPush.textColor = .primaryColor

        lblETVCountIncomingACHPush.font = labelFont
        lblETVCountIncomingACHPush.textAlignment = .left
        lblETVCountIncomingACHPush.textColor = .primaryColor
        
        //ACH PULL
        lblTitleIncomingACHPull.text = Utility.localizedString(forKey: "achPull")
        lblTitleIncomingACHPull.font = labelFont
        lblTitleIncomingACHPull.textAlignment = .left
        lblTitleIncomingACHPull.textColor = .secondaryColorWithOpacity
        
        lblETVRangeIncomingACHPull.font = labelFont
        lblETVRangeIncomingACHPull.textAlignment = .left
        lblETVRangeIncomingACHPull.textColor = .primaryColor

        lblETVCountIncomingACHPull.font = labelFont
        lblETVCountIncomingACHPull.textAlignment = .left
        lblETVCountIncomingACHPull.textColor = .primaryColor
        
        //IACH
        lblTitleIncomingIACH.text = "Int. ACH"
        lblTitleIncomingIACH.font = labelFont
        lblTitleIncomingIACH.textAlignment = .left
        lblTitleIncomingIACH.textColor = .secondaryColorWithOpacity
        
        lblETVRangeIncomingIACH.font = labelFont
        lblETVRangeIncomingIACH.textAlignment = .left
        lblETVRangeIncomingIACH.textColor = .primaryColor

        lblETVCountIncomingIACH.font = labelFont
        lblETVCountIncomingIACH.textAlignment = .left
        lblETVCountIncomingIACH.textColor = .primaryColor
        
        //DWIRE
        lblTitleIncomingDWire.text = Utility.localizedString(forKey: "domesticWire")
        lblTitleIncomingDWire.font = labelFont
        lblTitleIncomingDWire.textAlignment = .left
        lblTitleIncomingDWire.textColor = .secondaryColorWithOpacity
        
        lblETVRangeIncomingDWire.font = labelFont
        lblETVRangeIncomingDWire.textAlignment = .left
        lblETVRangeIncomingDWire.textColor = .primaryColor

        lblETVCountIncomingDWire.font = labelFont
        lblETVCountIncomingDWire.textAlignment = .left
        lblETVCountIncomingDWire.textColor = .primaryColor
        
        //IWIRE
        lblTitleIncomingIWire.text = "Intl. Wire"
        lblTitleIncomingIWire.font = labelFont
        lblTitleIncomingIWire.textAlignment = .left
        lblTitleIncomingIWire.textColor = .secondaryColorWithOpacity
        
        lblETVRangeIncomingIWire.font = labelFont
        lblETVRangeIncomingIWire.textAlignment = .left
        lblETVRangeIncomingIWire.textColor = .primaryColor

        lblETVCountIncomingIWire.font = labelFont
        lblETVCountIncomingIWire.textAlignment = .left
        lblETVCountIncomingIWire.textColor = .primaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(businessProjectionData: ProjectionAnnualModel) {
        //...SEND...//
        //ACH
        var sAchRangeValue = ""
        var sAchCountValue = ""
        for valueData in AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.send?.ach?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                sAchRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.send?.ach?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                sAchCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeSendACH.text = sAchRangeValue
        lblETVCountSendACH.text = sAchCountValue
        
        //IACH
        var sIAchRangeValue = ""
        var sIAchCountValue = ""
        for valueData in AppGlobalData.shared().listETVIACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.send?.internationalAch?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                sIAchRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVIACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.send?.internationalAch?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                sIAchCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeSendIACH.text = sIAchRangeValue
        lblETVCountSendIACH.text = sIAchCountValue
        
        //WIRE
        var sWireRangeValue = ""
        var sWireCountValue = ""
        for valueData in AppGlobalData.shared().listETVDWireValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.send?.domesticWire?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                sWireRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVDWireValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.send?.domesticWire?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                sWireCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeSendDWire.text = sWireRangeValue
        lblETVCountSendDWire.text = sWireCountValue
        
        //IWIRE
        var siwireRangeValue = ""
        var siwireCountValue = ""
        for valueData in AppGlobalData.shared().listETVIWireValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.send?.internationalWire?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                siwireRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVIWireValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.send?.internationalWire?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                siwireCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeSendIWire.text = siwireRangeValue
        lblETVCountSendIWire.text = siwireCountValue
        
        //CHECK
        var scheckRangeValue = ""
        var scheckCountValue = ""
        for valueData in AppGlobalData.shared().listETVCheckValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.send?.physicalCheck?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                scheckRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVCheckValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.send?.physicalCheck?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                scheckCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeSendCheck.text = scheckRangeValue
        lblETVCountSendCheck.text = scheckCountValue
        
        //...RECEIVE...//
        //ACH
        var rAchRangeValue = ""
        var rAchCountValue = ""
        for valueData in AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.receive?.ach?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                rAchRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.receive?.ach?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                rAchCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeReceiveACH.text = rAchRangeValue
        lblETVCountReceiveACH.text = rAchCountValue
        
        //CHECK
        var rcheckRangeValue = ""
        var rcheckCountValue = ""
        for valueData in AppGlobalData.shared().listETVCheckValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.receive?.physicalCheck?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                rcheckRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVCheckValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.receive?.physicalCheck?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                rcheckCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeReceiveCheck.text = rcheckRangeValue
        lblETVCountReceiveCheck.text = rcheckCountValue
        
        //...INCOMING...//
        //ACH PUSH
        var achPushRangeValue = ""
        var achPushCountValue = ""
        for valueData in AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.incoming?.achPush?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                achPushRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.incoming?.achPush?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                achPushCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeIncomingACHPush.text = achPushRangeValue
        lblETVCountIncomingACHPush.text = achPushCountValue
        
        //ACH PULL
        var achPullRangeValue = ""
        var achPullCountValue = ""
        for valueData in AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.incoming?.achPull?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                achPullRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.incoming?.achPull?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                achPullCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeIncomingACHPull.text = achPullRangeValue
        lblETVCountIncomingACHPull.text = achPullCountValue
        
        //IACH
        var iiachRangeValue = ""
        var iiachPullCountValue = ""
        for valueData in AppGlobalData.shared().listETVIACHValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.incoming?.internationalAch?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                iiachRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVIACHValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.incoming?.internationalAch?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                iiachPullCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeIncomingIACH.text = iiachRangeValue
        lblETVCountIncomingIACH.text = iiachPullCountValue
        
        //WIRE
        var iwireRangeValue = ""
        var iwireCountValue = ""
        for valueData in AppGlobalData.shared().listETVDWireValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.incoming?.domesticWire?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                iwireRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVDWireValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.incoming?.domesticWire?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                iwireCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeIncomingDWire.text = iwireRangeValue
        lblETVCountIncomingDWire.text = iwireCountValue
        
        //IWIRE
        var iiwireRangeValue = ""
        var iiwireCountValue = ""
        for valueData in AppGlobalData.shared().listETVIWireValues["etvValues"] ?? [[:]] {
            let pAmount = businessProjectionData.incoming?.internationalWire?.amount ?? ""
            let maxValue = valueData["maxValue"]
            if  maxValue == pAmount {
                iiwireRangeValue = valueData["valueRange"] ?? ""
            }
        }
        
        for countData in AppGlobalData.shared().listETVIWireValues["etvCounts"] ?? [[:]] {
            let pCount = businessProjectionData.incoming?.internationalWire?.count ?? ""
            let maxCount = countData["maxCount"]
            if  maxCount == pCount {
                iiwireCountValue = countData["countRange"] ?? ""
            }
        }
        lblETVRangeIncomingIWire.text = iiwireRangeValue
        lblETVCountIncomingIWire.text = iiwireCountValue
    }
}
