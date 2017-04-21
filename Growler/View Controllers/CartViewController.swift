//
// Created by Jeff H. on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import EMString

class CartViewController: UITableViewController, Notifiable, UIPickerViewDelegate, UIPickerViewDataSource {

    let SIMPLE_CELL_IDENTIFIER = "Cell"

    let PRODUCT_LIST_CELL = "ProductListCell"

    private var footer: UIView!

    private var buttonItems: [UIBarButtonItem]!

    private var checkoutButton: UIButton!

    private var products: [BUYProduct] = []

    private var closeButton: UIBarButtonItem!

    private var cartStatusBar: CartStatusBar!
    
    private var checkout: BUYCheckout?

    private var shippingRates: [BUYShippingRate] = []

    private var isLoading = false

    private static var registeredStyles = false

    private let headerFont = UIFont(name: "Helvetica", size: 12)

    private var deliveryField: UITextField!

    private var deliveryPicker: UIPickerView!

    private var selectedShippingRate: Int = 0

    private var deliveryToolBar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Colors.grayBackground
        tableView.separatorColor = Colors.grayBackground

        checkoutButton = UIButton()
        checkoutButton.isEnabled = false
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.setTitleColor(UIColor.white, for: .normal)
        checkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        checkoutButton.addTarget(self, action: #selector(self.doCheckout), for: .touchUpInside)
        checkoutButton.sizeToFit()
        let checkoutButtonWrapper = UIBarButtonItem(customView: checkoutButton)

        let closeIcon = UIImage(named: "CloseMenuButton")
        closeButton = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.didTapCloseButton))

        cartStatusBar = CartStatusBar()
        
        buttonItems = [
            cartStatusBar.cartItemCountWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            checkoutButtonWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartStatusBar.cartTotalAmount,
        ]

        registerStyles()

        subscribeTo(Notification.Name.cartChanged, selector: #selector(self.cartChanged))
        subscribeTo(Notification.Name.accountChanged, selector: #selector(self.addressChanged))
        subscribeTo(Notification.Name.creditCardChanged, selector: #selector(self.creditCardChanged))
        subscribeTo(Notification.Name.promoCodeChanged, selector: #selector(self.promoCodeChanged))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SIMPLE_CELL_IDENTIFIER)
        let nib = UINib(nibName: PRODUCT_LIST_CELL, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PRODUCT_LIST_CELL)

        deliveryField = UITextField()
        deliveryField.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(deliveryField)
        deliveryPicker = UIPickerView()
        deliveryPicker.showsSelectionIndicator = true
        deliveryPicker.dataSource = self
        deliveryPicker.delegate = self
        deliveryField.inputView = deliveryPicker

        deliveryToolBar = UIToolbar()
        deliveryToolBar.barStyle = .default
        deliveryToolBar.isTranslucent = true
        deliveryToolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePicker))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        deliveryToolBar.setItems([spacer, doneButton], animated: false)
        deliveryToolBar.isUserInteractionEnabled = true
        deliveryField.inputAccessoryView = deliveryToolBar

        loadEverything()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    private func registerStyles() {
        if !CartViewController.registeredStyles {
            CartViewController.registeredStyles = true

            let grayText = EMStylingClass(markup: "<growler_gray_text>")!
            grayText.color = Colors.grayText
            EMStringStylingConfiguration.sharedInstance().addNewStylingClass(grayText)

            let orangeLinkStyle = EMStylingClass(markup: "<growler_orange_link>")!
            orangeLinkStyle.color = Colors.launchScreenOrangeColor
            EMStringStylingConfiguration.sharedInstance().addNewStylingClass(orangeLinkStyle)
        }
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
       
        if ShopifyController.instance.isEmptyCart() {
            products = []
            mq {
                // todo hide HUD
                self.tableView.reloadData()
                self.checkoutButton.isHidden = true
            }
            return
        }

        mq {
            self.isLoading = true
            self.checkoutButton.isEnabled = false
            self.tableView.reloadData()
        }
        
        loadEverythingInternal()
            .then {
                checkout -> Void in
                print("\(checkout)")
            }
            .catch {
                _ in
                // muting errors here. we will show errors when user will press checkout error in self.handleError(error)
            }
            .always {
                mq {
                    // todo hide HUD
                    self.isLoading = false
                    self.checkoutButton.isHidden = self.products.count == 0
                    self.tableView.reloadData()
                }
            }
    }

    func loadEverythingInternal() -> Promise<BUYCheckout> {
        return ShopifyController.instance.getCartProducts()
            .then {
                products -> Promise<BUYCheckout> in
                self.products = products
                return ShopifyController.instance.getCheckout()
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
                if shippingRates.indices ~= self.selectedShippingRate {
                    checkout.shippingRate = shippingRates[self.selectedShippingRate]
                } else {
                    checkout.shippingRate = nil
                }
                return updateCheckout(checkout)
            }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == CartViewSection.products.rawValue
    }

    override func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section == CartViewSection.products.rawValue else {
            return []
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") {
            action, indexPath in
            ShopifyController.instance.removeProduct(self.products[indexPath.row])
            self.loadEverything()
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
        loadEverythingInternal()
            .then {
                checkout -> Void in
                self.checkoutStep2(checkout: checkout)
            }
            .catch {
                error in self.handleError(error)
            }
    }

    func checkoutStep2(checkout: BUYCheckout?) {
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
                        ShopifyController.instance.createNewCart()
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
                break
            case .instructionsToCourier:
                break
            case .yourOrderHeader:
                break
            case .products:
                return isLoading ? 1 : products.count
            case .summaryItems:
                if isLoading {
                    return 0
                }
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
                cell.valueLabel?.textAlignment = .left
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
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
                cell.textLabel?.font = headerFont
                cell.backgroundColor = Colors.grayBackground
                return cell
            case .products:
                if isLoading {
                    return ActivityIndicatorTableCell.loadFromNib()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: PRODUCT_LIST_CELL, for: indexPath) as! ProductListCell
                    let product = products[indexPath.row]
                    cell.setupWithProduct(product)
                    return cell
                }
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
                cell.textLabel?.font = headerFont
                cell.backgroundColor = Colors.grayBackground
                return cell
            case .deliveryDetails:
                let cell = CheckoutTableCell.loadFromNib()
                cell.titleLabel?.text = "Delivery"
                let delivery: String
                if shippingRates.indices ~= selectedShippingRate {
                    let rate = shippingRates[selectedShippingRate]
                    delivery = rate.title + " " + Utils.formatUSD(value: rate.price)
                } else {
                    delivery = "Select shipping"
                }
                cell.valueLabel?.text = delivery
                cell.valueLabel?.textColor = Colors.grayText
                return cell
            case .paymentDetailsHeader:
                let cell = UITableViewCell()
                cell.textLabel?.text = "PAYMENT DETAILS"
                cell.textLabel?.textColor = Colors.grayText
                cell.textLabel?.font = headerFont
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
                cell.textLabel?.textColor = nil // otherwise it will override color of attributed string
                cell.textLabel?.attributedText =
                    (
                        "<growler_gray_text>By continuing, you agree to our</growler_gray_text>\n" +
                        "<growler_orange_link>Terms and Conditions</growler_orange_link>"
                    )
                    .attributedString
                cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textAlignment = .center
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
                deliveryField.becomeFirstResponder()
            case .paymentDetailsHeader:
                break
            case .creditCard:
                CreditCardFormController().popupWithNavigationController(parentController: self)
            case .promoCode:
                PromoCodeFormController().popupWithNavigationController(parentController: self)
            case .termsAndConditions:
                AppDelegate.shared.termsViewController.popupWithNavigationController(parentController: self)
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

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shippingRates.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rate = shippingRates[row]
        return rate.title + " " + Utils.formatUSD(value: rate.price)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedShippingRate = row
    }

    func donePicker() {
        deliveryField.resignFirstResponder()
        loadEverything()
    }

}
