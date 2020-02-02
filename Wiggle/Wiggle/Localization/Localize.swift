//
//  Localize.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

struct Localize {
    
    struct LoginSignup {
        static var AcceptTerms: String { return NSLocalizedString("login_accept_terms", comment: "LoginSignup") }
        static var FacebookButton: String { return NSLocalizedString("facebook_button", comment: "LoginSignup") }
        static var PhoneButton: String { return NSLocalizedString("phone_button", comment: "LoginSignup") }
        static var SMSLoginTitle: String { return NSLocalizedString("sms_login_title", comment: "LoginSignup") }
    }
    
    struct Common {
        static var ContinueButton: String { return NSLocalizedString("continue_button", comment: "Common") }
        static var OKButton: String { return NSLocalizedString("ok_button", comment: "Common") }
        static var Clear: String { return NSLocalizedString("Temizle", comment: "Common") }
        static var CancelButton: String { return NSLocalizedString("cancel_button", comment: "Common") }
        static var SkipButton: String { return NSLocalizedString("skip_button", comment: "Common") }
        static var Error: String { return NSLocalizedString("error", comment: "Common") }
        static var PhoneCodes: String { return NSLocalizedString("phone_codes", comment: "Common") }
        static var GeneralError: String { return NSLocalizedString("general_error", comment: "Common") }
        static var Required: String { return NSLocalizedString("Zorunlu alan", comment: "Common") }
        static var CompleteButton: String { return NSLocalizedString("complete_button", comment: "Common") }
    }
    
    struct DatePicker {
        static var PickDate: String { return NSLocalizedString("date_picker_title", comment: "DatePicker") }
    }
    
    struct BirthdayPicker {
        static var TopLabel: String { return NSLocalizedString("birthday_top_label", comment: "BirthdayPicker") }
    }
    
    struct EnableLocation {
        static var EnableLocation: String { return NSLocalizedString("enable_location", comment: "GetLocation") }
        static var Description: String { return NSLocalizedString("enable_location_description", comment: "GetLocation") }
        static var EnableButton: String { return NSLocalizedString("enable_location_button", comment: "GetLocation")}
    }
    
    struct EnableNotifications {
        static var EnableNotification: String { return NSLocalizedString("enable_notification", comment: "EnableNotifications") }
        static var Description: String { return NSLocalizedString("enable_notification_description", comment: "EnableNotifications") }
        static var EnableButton: String { return NSLocalizedString("enable_notification_button", comment: "EnableNotifications")}
    }
    
    struct Camera {
        static var TakePhoto: String { return NSLocalizedString("take_photo", comment: "Camera") }
        static var CameraRoll: String { return NSLocalizedString("camera_roll", comment: "Camera") }
        static var PhotoLibrary: String { return NSLocalizedString("photo_library", comment: "Camera") }
    }
    
    struct Settings {
        static var Logout: String { return NSLocalizedString("logout", comment: "Settings") }
    }
    
    struct GetName {
         static var Title: String { return NSLocalizedString("my_name_is", comment: "GetName") }
    }
    
    struct Gender {
        static var Title: String { return NSLocalizedString("i_am_a", comment: "Gender") }
        static var Male: String { return NSLocalizedString("male", comment: "Gender") }
        static var Female: String { return NSLocalizedString("female", comment: "Gender") }
    }
    
    struct Bio {
        static var Title: String { return NSLocalizedString("bio", comment: "Bio") }
    }
    
    struct PickImage {
        static var Title: String { return NSLocalizedString("choose_photo", comment: "PickImage") }
        static var TapAgain: String { return NSLocalizedString("tap_again", comment: "PickImage") }
    }
    
    struct Placeholder {
        static var FirstNamePlaceholder: String { return NSLocalizedString("firstName_placeholder", comment: "Placeholder") }
        static var LastNamePlaceholder: String { return NSLocalizedString("lastName_placeholder", comment: "Placeholder") }
    }
}
