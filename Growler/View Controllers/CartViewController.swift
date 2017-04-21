//
// Created by Jeff H. on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class CartViewController: UITableViewController, Notifiable {

    let SIMPLE_CELL_IDENTIFIER = "Cell"

    let PRODUCT_LIST_CELL = "ProductListCell"

    private var footer: UIView!

    private var buttonItems: [UIBarButtonItem]!

    private var checkoutButton: UIBarButtonItem!

    private var products: [BUYProduct] = []

    private var closeButton: UIBarButtonItem!

    private var cartStatusBar: CartStatusBar!
    
    private var checkout: BUYCheckout?

    private var shippingRates: [BUYShippingRate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Colors.grayBackground
        tableView.separatorColor = Colors.grayBackground

        checkoutButton = UIBarButtonItem(title: "Checkout", style: .plain, target: self, action: #selector(self.doCheckout))
        checkoutButton.isEnabled = false

        let closeIcon = UIImage(named: "CloseMenuButton")
        closeButton = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.didTapCloseButton))

        cartStatusBar = CartStatusBar()
        
        buttonItems = [
            cartStatusBar.cartItemCountWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            checkoutButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartStatusBar.cartTotalAmount,
        ]

        subscribeTo(Notification.Name.cartChanged, selector: #selector(self.cartChanged))
        subscribeTo(Notification.Name.accountChanged, selector: #selector(self.addressChanged))
        subscribeTo(Notification.Name.creditCardChanged, selector: #selector(self.creditCardChanged))
        subscribeTo(Notification.Name.promoCodeChanged, selector: #selector(self.promoCodeChanged))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SIMPLE_CELL_IDENTIFIER)
        let nib = UINib(nibName: PRODUCT_LIST_CELL, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PRODUCT_LIST_CELL)

        loadEverything()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDarkToolbars()
        navigationItem.title = "Cart"
        navigationItem.leftBarButtonItem = closeButton
        setToolbarItems(buttonItems, animated: false)
    }

    func loadEverything() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        // todo show HUD
        checkoutButton.isEnabled = false

        if ShopifyController.instance.isEmptyCart() {
            products = []
            mq {
                // todo hide HUD
                self.checkoutButton.isEnabled = true
                self.tableView.reloadData()
            }
            return
        }

        ShopifyController.instance.getCart()
            .then {
                products -> Promise<BUYCheckout> in
                self.products = products
                return ShopifyController.instance.createCheckout(products: products)
            }
            .then {
                checkout in
                self.checkout = checkout
                return getShippingRates(forCheckout: checkout)
            }
            .then {
                (shippingRates: [BUYShippingRate]) -> Promise<BUYCheckout> in
                self.shippingRates = shippingRates
                let checkout = self.checkout! // if we got here then checkout is not null
                checkout.shippingRate = shippingRates.first
                return updateCheckout(checkout)
            }
            .then {
                checkout -> Void in
                print("\(checkout)")
            }
            .catch {
                error in self.handleError(error)
            }
            .always {
                mq {
                    // todo hide HUD
                    self.checkoutButton.isEnabled = true
                    self.tableView.reloadData()
                }
            }
    }

    override func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") {
            action, indexPath in
            ShopifyController.instance.cartProductIds.remove(at: indexPath.row)
        }
        return [deleteAction]
    }

    private func handleError(_ error: Error) {
        mq {
            self.checkout = nil
            self.shippingRates = []
            let error = error as NSError
            let message = Utils.formatErrorInfo(error.userInfo, message: "Error")
            Utils.alert(message: message, parent: self)
        }
    }

    func didTapCloseButton() {
        navigationController?.dismiss(animated: true)
    }

    func doCheckout() {
        guard let checkout = checkout else {
            return
        }
        addCreditCard {
            success, token in
            if success {
                ShopifyController.instance.client.completeCheckout(withToken: checkout.token, paymentToken: token) {
                    checkout, error in
                    if error == nil && checkout != nil {
                        self.checkout = checkout
                        ShopifyController.instance.cartProductIds.removeAll()
                        self.navigationController?.dismiss(animated: true, completion: {})
                        Utils.alert(message: "Your order has been completed successfully")
                    } else {
                        if let error = error {
                            self.handleError(error)
                        }
                    }
                }
            }
        }
    }

    // todo convert it into promise
    func addCreditCard(callback: @escaping (_ success: Bool, _ token: BUYPaymentToken) -> Void) {
        let creditCard = ShopifyController.instance.getCreditCard()
        guard let checkout = checkout else {
            return
        }
        ShopifyController.instance.client.store(creditCard, checkout: checkout) {
            token, error in
            if let error = error {
                if error == nil && token != nil {
                    print("Successfully added credit card to checkout")
                } else {
                    self.handleError(error)
                }
            }
            callback(error == nil && (token != nil), token!)
        }
    }

    func cartChanged() {
        loadEverything()
    }

    override func numberOfSections(`in` tableView: UITableView) -> Int {
        return 11 // count of CartViewSection entries. todo update if it will be changed
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection s: Int) -> Int {
        let section = CartViewSection(rawValue: s)!
        switch section {
            case .address:
                CreditCardFormController().popupWithNavigationController()
            case .instructionsToCourier:
                break
            case .yourOrderHeader:
                break
            case .products:
                return products.count
            case .summaryItems:
                if let summary = getSummary() {
                    return summary.count
                } else {
                    return 1
                }
            case .deliveryDetailsHeader:
                break
            case .deliveryDetails:
                break
            case .paymentDetailsHeader:
                break
            case .creditCard:
                break
            case .promoCode:
                break
            case .termsAndConditions:
                break
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = CartViewSection(rawValue: indexPath.section)!
        switch section {
            case .address:
                let cell = CheckoutTableCell.loadFromNib()
                cell.imageView?.image = UIImage(named: "LocationMarkGray")
                cell.titleLeftConstraint.constant = 30
                cell.titleLabel?.text = getAddress()
                cell.valueLabel?.text = getCityStateZip()
                cell.valueLabel?.textColor = Colors.grayText
                return cell
            case .instructionsToCourier:
                let cell = UITableViewCell()
                cell.imageView?.image = UIImage(named: "CourierInstructionIcon")
                cell.textLabel?.text = "Add Instructions for Courier"
                cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 15)
                cell.textLabel?.textColor = Colors.grayText
                return cell
            case .yourOrderHeader:
                let cell = UITableViewCell()
                cell.textLabel?.text = "YOUR ORDER"
                cell.textLabel?.textColor = Colors.grayText
                cell.backgroundColor = Colors.grayBackground
                return cell
            case .products:
                let cell = tableView.dequeueReusableCell(withIdentifier: PRODUCT_LIST_CELL, for: indexPath) as! ProductListCell
                let product = products[indexPath.row]
                cell.setupWithProduct(product)
                return cell
            case .summaryItems:
                let cell = CheckoutTableCell.loadFromNib()
                if let summary = getSummary() {
                    let item = summary[indexPath.row]
                    cell.titleLabel.text = item.label
                    cell.valueLabel.text = Utils.formatUSD(value: item.amount)
                    let isLastSummaryItem = indexPath.row == summary.count - 1
                    let font = isLastSummaryItem
                        ? UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
                        : UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                    cell.titleLabel?.font = font
                    cell.valueLabel?.font = font

                    let textColor = isLastSummaryItem ? UIColor.black : Colors.grayText
                    cell.titleLabel?.textColor = textColor
                    cell.valueLabel?.textColor = textColor
                } else {
                    cell.titleLabel?.text = ""
                }
                return cell
            case .deliveryDetailsHeader:
                let cell = UITableViewCell()
                cell.textLabel?.text = "DELIVERY DETAILS"
                cell.textLabel?.textColor = Colors.grayText
                cell.backgroundColor = Colors.grayBackground
                return cell
            case .deliveryDetails:
                let cell = CheckoutTableCell.loadFromNib()
                cell.titleLabel?.text = "Delivery"
                cell.valueLabel?.text = "Select time slot"
                cell.valueLabel?.textColor = Colors.grayText
                return cell
            case .paymentDetailsHeader:
                let cell = UITableViewCell()
                cell.textLabel?.text = "PAYMENT DETAILS"
                cell.textLabel?.textColor = Colors.grayText
                cell.backgroundColor = Colors.grayBackground
                return cell
            case .creditCard:
                let cell = CheckoutTableCell.loadFromNib()
                cell.titleLabel.text = "Payment"
                let ccNumber = ShopifyController.instance.getCreditCard().number ?? ""
                cell.valueLabel.text = ccNumber.isEmpty ? "Add Card" : Utils.maskCreditCardNumber(ccNumber)
                cell.valueLabel?.textColor = Colors.grayText
                return cell
            case .promoCode:
                let cell = CheckoutTableCell.loadFromNib()
                cell.titleLabel?.text = "Promo Code"
                cell.valueLabel?.text = ShopifyController.instance.getPromoCode()
                cell.valueLabel?.textColor = Colors.grayText
                return cell
            case .termsAndConditions:
                let cell = UITableViewCell()
                cell.textLabel?.text = "By continuing, you agree to our\nTerms and Conditions"
                cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = Colors.grayText
                cell.backgroundColor = Colors.grayBackground
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CoreGraphics.CGFloat {
        let section = CartViewSection(rawValue: indexPath.section)!
        switch section {
            case .address:
                break
            case .instructionsToCourier:
                break
            case .yourOrderHeader:
                break
            case .products:
                return ProductListCell.HEIGHT
            case .summaryItems:
                return 22
            case .deliveryDetailsHeader:
                break
            case .deliveryDetails:
                break
            case .paymentDetailsHeader:
                break
            case .creditCard:
                break
            case .promoCode:
                break
            case .termsAndConditions:
                break
        }
        return 44
    }

    private func getSummary() -> [PKPaymentSummaryItem]? {
        // todo use buy_summaryItemsWithShopName instead of buy_summaryItems
        return checkout?.buy_summaryItems()
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = CartViewSection(rawValue: indexPath.section)!
        switch section {
            case .address:
                AddressFormController().popupWithNavigationController(parentController: self)
            case .instructionsToCourier:
                break
            case .yourOrderHeader:
                break
            case .products:
                break
            case .summaryItems:
                break
            case .deliveryDetailsHeader:
                break
            case .deliveryDetails:
                break
            case .paymentDetailsHeader:
                break
            case .creditCard:
                CreditCardFormController().popupWithNavigationController(parentController: self)
            case .promoCode:
                PromoCodeFormController().popupWithNavigationController(parentController: self)
            case .termsAndConditions:
                break
        }

        return nil
    }

    func getAddress() -> String {
        return ShopifyController.instance.getAddress()?.address1 ?? ""
    }

    func getCityStateZip() -> String {
        guard let address = ShopifyController.instance.getAddress() else {
            return ""
        }
        let city = address.city ?? ""
        let code = address.provinceCode ?? ""
        let zip1 = address.zip ?? ""
        return "\(city) \(code) \(zip1)"
    }

    func addressChanged() {
        loadEverything()
    }

    func creditCardChanged() {
        // !!!!! IMPORTANT: don't call loadEverything here. !!!!!
        // card value on screen will be updated without access to APIs
        // and reloading checkout from API isn't required because it doesn't depend on card
        mq { self.tableView.reloadData() }
    }

    func promoCodeChanged() {
        loadEverything()
    }

}
