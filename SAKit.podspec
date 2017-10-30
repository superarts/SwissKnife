#
# Be sure to run `pod lib lint SAKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name             = "SAKit"
	s.version          = "0.1.0"
	s.summary          = "Based on LSwift."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
	s.description      = <<-DESC
This is the Pod version of LSwift.
Still in progress.
	DESC

	s.homepage         = "https://github.com/superarts/LFramework"
	# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
	s.license          = 'MIT'
	s.author           = { "Leo" => "leo@superarts.org" }
	s.source           = { :git => "https://github.com/superarts/LFramework.git", :tag => s.version.to_s }
	s.social_media_url = 'https://twitter.com/superarts_org'

	s.platform     = :ios, '8.0'
	s.requires_arc = true
	s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

	# s.source_files = 'Pod/Classes/**/*'
	s.resource_bundles = {
		'SAKit' => ['Pod/Assets/*.png']
	}

	# s.public_header_files = 'Pod/Classes/**/*.h'
	# s.frameworks = 'UIKit', 'MapKit'
	# s.dependency 'AFNetworking', '~> 2.3'

	s.subspec 'SAFoundation' do |sp|
		# sp.module_name = 'SAFoundation'
		sp.frameworks = 'UIKit', 'Security'
		sp.source_files = 'Pod/Classes/SAFoundation'
	end
	s.subspec 'SAClient' do |sp|
		# sp.module_name = 'SAClient'
		sp.source_files = 'Pod/Classes/SAClient'
		sp.dependency 'SAKit/SAFoundation'
	end

	s.default_subspec = 'SAFoundation'
end