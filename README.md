Growler Express iOS App
=======================

Initial Setup
-------------
1. Download Shopify SDK
1. Open the Mobile Buy SDK.xcodeproj 
1. Select the Static Universal Framework scheme
1. Drag the Buy.framework that was just created into the Linked Frameworks and Libraries section for the target you want to add the framework to. Check Copy items if needed so the framework is copied to your project
1. In the Build Settings tab, add -all_load to Other Linker Flags

### Classes
#### View Controllers

###### `CollectionListViewController`
* Initializes the `BUYClient`
* Fetches collections and displays them in a list
* Optionally allows for fetch of the first product page

###### `ProductListViewController`
* Fetches the products and displays them in a list
* Can present a product using the `ProductViewController` and demo the theme settings on the controller, or
* Creates a checkout with the selected product and pushes to the `ShippingRatesTableViewController`

###### `ShippingRatesTableViewController`
* Fetches the shipping rates for the checkout using `GetShippingRatesOperation`
* Updates the checkout with the selected shipping rate and pushes to the `PreCheckoutViewController`

###### `PreCheckoutViewController`
* Displays a summary of the checkout
* Allows for discounts and gift cards to be added to the checkout

###### `CheckoutViewController`
* Displays a summary of the checkout
* Checkout using a credit card
* Web checkout using Safari
* Checkout using Apple Pay

#### `NSOperation`s

###### `GetShopOperation`
* `NSOperation` based class to fetch the shop object

###### `GetShippingRatesOperation`
* `NSOperation` based class to poll for shipping rates

###### `GetCompletionStatusOperation`
* `NSOperation` based class to poll for the checkout completion status

### Apple Pay

Apple Pay is implemented in the CheckoutViewController.  It utilizes the `BUYApplePayHelpers` class which acts as the delegate for the `PKPaymentAuthorizationViewController`.  Setting the `MerchantId` is required to use Apple Pay.  For more information about supporting Apple Pay in your app, please consult [https://docs.shopify.com/mobile-buy-sdk/ios/enable-apple-pay](https://docs.shopify.com/mobile-buy-sdk/ios/enable-apple-pay).
