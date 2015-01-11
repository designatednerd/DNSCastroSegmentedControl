Pod::Spec.new do |s|
  s.name         = "DNSCastroSegmentedControl"
  s.version      = “1.1.1”
  s.summary      = "A segmented control based on the one in the Castro Podcast app's settings page."
  s.homepage     = "https://github.com/designatednerd/DNSCastroSegmentedControl"
  s.screenshots  = "https://raw.githubusercontent.com/designatednerd/DNSCastroSegmentedControl/master/sample_project.gif"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = "Ellen Shapiro"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/designatednerd/DNSCastroSegmentedControl.git", :tag => "v#{s.version}" }
  s.source_files = 'DNSCastroSegmentedControl/Library'
  s.requires_arc = true
end
