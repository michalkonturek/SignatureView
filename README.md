# SignatureView

[![Twitter](https://img.shields.io/badge/contact-@MichalKonturek-blue.svg?style=flat)](http://twitter.com/michalkonturek)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/michalkonturek/SignatureView/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/SignatureView.svg?style=flat)](https://github.com/michalkonturek/SignatureView)

UI component for capturing signature.


## License

Source code of this project is available under the standard MIT license. Please see [the license file][LICENSE].

[LICENSE]:https://github.com/michalkonturek/GraphKit/blob/master/LICENSE


## Usage

To see a quick demo, simply type `pod try SignatureView`.

Initialize `SignatureView` from nib or programmatically: 

```objc
CGRect frame = CGRectMake(0, 40, 320, 300);
id view = [[SignatureView alloc] initWithFrame:frame];
[self.view addSubview:view];
self.signatureView = view;
```

### Customization

You can customzie following attributes:

**Line Color**

```objc
self.signatureView.foregroundLineColor = [UIColor redColor];
self.signatureView.backgroundLineColor = [UIColor blueColor];
```

**Line Width**

```objc
self.signatureView.foregroundLineWidth = 3.0;
self.signatureView.backgroundLineWidth = 3.0;
```

### Signature

A signature image can be retrieved by UIImage object:

```objc
UIImage *signature = [self.signatureView signatureImage];
```
or by PNG representation:

```objc
NSData *signatureData = [self.signatureView signatureData];
```

### Clearing

`SignatureView` comes with a `UILongPressGestureRecognizer` which is responsible for clearning its view;


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b new-feature`).
3. Commit your changes (`git commit -am 'Added new-feature'`).
4. Push to the branch (`git push origin new-feature`).
5. Create new Pull Request.
