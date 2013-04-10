Pod::Spec.new do |s|
  s.name         = "DPlibrary_Bee"
  s.version      = "1.0"
  s.summary      = "多朋的第三方架构_Bee 已经针对项目做了修改 基于Bee0.2.2"

  s.homepage     = "https://github.com/blueberryWT/DPlibrary_Bee"
  s.license      = 'MIT'

  s.author       = { "yutongfei","doujingxuan"}

  s.source       = { :git => 'git@github.com:blueberryWT/DPlibrary_Bee.git'}

  s.source_files = 'DPlibrary_Bee/**/*.{h,m,mm}'


  s.resources = 'DPlibrary_Bee/BeeRes/*.{png,jpg}'
  s.platform     = :ios

  s.requires_arc = false
  s.framework = ['CoreGraphics','Foundation','QuartzCore','Security','UIKit']
  s.prefix_header_file = 'DPlibrary_Bee/DPlibrary_Bee-Prefix.pch'

  s.dependency 'JSONKit'
  s.dependency 'ASIHTTPRequest'
  s.dependency 'Reachability'
  s.dependency 'FMDB'

  #...
end
