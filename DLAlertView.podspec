Pod::Spec.new do |s|
  s.name         = 'DLAlertView'
  s.version      = '1.0'
  s.license      = 'Modified BSD-3'
  s.platform     = :ios

  s.summary      = 'DLAlertView is an API-compatible UIAlertView replacement that can embed custom content views, is fully themable and let\'s you use a delegate and/or blocks.'
  s.homepage     = 'https://github.com/regexident/DLAlertView'
  s.author       = { 'Vincent Esche' => '@regexident' }
  s.source       = { :git => 'https://github.com/regexident/DLAlertView' }

  s.source_files = 'DLAlertView/Classes/*.{h,m}'
end
