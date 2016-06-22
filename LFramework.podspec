#
# Be sure to run `pod lib lint LFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name             = "LFramework"
	s.version          = "0.1.0"
	s.summary          = "Pod version of LSwift."

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

	# s.source_files = 'Pod/Classes/**/*'
	s.resource_bundles = {
		'LFramework' => ['Pod/Assets/*.png']
	}

	# s.public_header_files = 'Pod/Classes/**/*.h'
	# s.frameworks = 'UIKit', 'MapKit'
	# s.dependency 'AFNetworking', '~> 2.3'

	s.subspec 'LFoundation' do |sp|
		# sp.module_name = 'LFoundation'
		sp.frameworks = 'UIKit', 'Security'
		sp.source_files = 'Pod/Classes/LFoundation'
	end
	s.subspec 'LClient' do |sp|
		# sp.module_name = 'LClient'
		sp.source_files = 'Pod/Classes/LClient'
		sp.dependency 'LFramework/LFoundation'
	end

	s.default_subspec = 'LFoundation'
end