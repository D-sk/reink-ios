# Podfile
# Select the appropriate platform below
# Specify the minimum supported iOS version (or later) required by Kiwi

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Secret' do 
    #HTTP Request
    pod 'Alamofire', '~>4.0' 
    pod 'AlamofireImage'
    
    #Keychain
    pod 'LUKeychainAccess', '~>1.2' # Keychain Service wrapper

    #DataStore
    pod 'RealmSwift'


    post_install do |installer|
     installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
     end
    end
end


target 'SecretTests' do
end

