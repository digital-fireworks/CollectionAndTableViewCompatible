# TableViewCompatible
A set of Swift protocols and Xcode snippets that will make it easy to do clean UITableView code.

# How to use
The project consists of three protocols:

- `TableViewCompatible`
- `Configurable`
- `TableViewSection`

Create a view model that conforms to the `TableViewCompatible` protocol. The view model could either be a separate class or an extension to your existing model obejct. Your choice. 

The create a `UITableViewCell` subclass that conforms to the `Configurable` protocol. Make the function `configureWithModel` take an instance of your view model as parameter.

Finally create a class or struct that conforms to the `TableViewSection` protocol and let your `UITableViewDataSource` data model be an array of `TableViewSection`. 

# Xcode snippets
To do all this really fast, import the two .codesnippet files in the Xcode code snippet folder found here:
`~/Library/Developer/Xcode/UserData/CodeSnippets/`.

That's all folks. Thanks for listening.
