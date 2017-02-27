#
# Be sure to run `pod lib lint CollectionAndTableViewCompatible.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CollectionAndTableViewCompatible'
  s.version          = '0.1.0'
  s.summary          = 'A set of Swift protocols and Xcode snippets that will make it easy to do clean UICollectionView and UITableView code.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    The project consists of three protocols:
    - `TableViewCompatible`
    - `Configurable`
    - `TableViewSection`

    Create a view model that conforms to the `TableViewCompatible` protocol. The view model could either be a separate class or an extension to your existing model obejct. Your choice.

    The create a `UITableViewCell` subclass that conforms to the `Configurable` protocol. Make the function `configureWithModel` take an instance of your view model as parameter.

    Finally create a class or struct that conforms to the `TableViewSection` protocol and let your `UITableViewDataSource` data model be an array of `TableViewSection`.

    For a more detailed explaination see this [blog post](https://blog.jayway.com/2016/11/15/clean-table-view-code-using-swift-protocols/)
                       DESC

  s.homepage         = 'https://github.com/jayway/CollectionAndTableViewCompatible'
  s.license          = { :type => 'Apache Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Jimmie Jensen' => 'jimmie.jensen@jayway.com' }
  s.source           = { :git => 'https://github.com/jayway/CollectionAndTableViewCompatible.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/**'
  s.frameworks = 'UIKit'
   
end
