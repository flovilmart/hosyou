Pod::Spec.new do |s|
  s.name     = 'Hosyou'
  s.version  = '0.0.1-alpha.0'
  s.license  = { :type => 'MIT' }
  s.summary  = 'Lighweight and unopinionated promises'
  s.homepage = 'http://github.com/flovilmart/hosyou.git'
  s.authors  = { 'Florent Vilmart' => 'florent@flovilmart.com' }
  s.source   = { :git => 'https://github.com/flovilmart/hosyou.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.platform = :ios, '8.0'

  s.source_files = 'Hosyou/*.Swift'
end
