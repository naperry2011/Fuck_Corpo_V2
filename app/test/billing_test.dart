import 'dart:async';

import 'package:fcorpo/features/pro/billing.dart';
import 'package:fcorpo/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeIap implements InAppPurchase {
  FakeIap({this.available = true, this.hasProduct = true});

  final bool available;
  final bool hasProduct;
  final purchases = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <PurchaseDetails>[];
  int restores = 0;
  int buys = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => purchases.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: [
          if (hasProduct)
            ProductDetails(
              id: proProductId,
              title: 'Management',
              description: 'Pro',
              price: r'$2.99',
              rawPrice: 2.99,
              currencyCode: 'USD',
            ),
        ],
        notFoundIDs: hasProduct ? [] : [proProductId],
      );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buys++;
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async =>
      restores++;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PurchaseDetails _purchase(PurchaseStatus status, {bool needsAck = true}) =>
    PurchaseDetails(
      productID: proProductId,
      verificationData: PurchaseVerificationData(
        localVerificationData: '',
        serverVerificationData: '',
        source: 'test',
      ),
      transactionDate: '0',
      status: status,
    )..pendingCompletePurchase = needsAck;

Future<(ProviderContainer, FakeIap)> _setup(FakeIap iap) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      inAppPurchaseProvider.overrideWithValue(iap),
    ],
  );
  addTearDown(c.dispose);
  c.read(billingProvider);
  await pumpEventQueue();
  return (c, iap);
}

void main() {
  test('loads the product, then silently restores', () async {
    final (c, iap) = await _setup(FakeIap());
    final state = c.read(billingProvider);
    expect(state.status, BillingStatus.ready);
    expect(state.product?.price, r'$2.99');
    expect(iap.restores, 1);
  });

  test('a completed purchase unlocks Pro and is acknowledged', () async {
    final (c, iap) = await _setup(FakeIap());
    await c.read(billingProvider.notifier).buy();
    expect(iap.buys, 1);
    expect(c.read(billingProvider).status, BillingStatus.pending);
    expect(c.read(proProvider), isFalse);

    final p = _purchase(PurchaseStatus.purchased);
    await c.read(billingProvider.notifier).handlePurchases([p]);
    expect(c.read(proProvider), isTrue);
    expect(c.read(billingProvider).status, BillingStatus.ready);
    expect(iap.completed, [p]);
  });

  test('restored purchase unlocks Pro', () async {
    final (c, _) = await _setup(FakeIap());
    await c.read(billingProvider.notifier).handlePurchases([
      _purchase(PurchaseStatus.restored, needsAck: false),
    ]);
    expect(c.read(proProvider), isTrue);
  });

  test('pending, cancel, and error never unlock Pro', () async {
    final (c, iap) = await _setup(FakeIap());
    final billing = c.read(billingProvider.notifier);

    await billing.handlePurchases([
      _purchase(PurchaseStatus.pending, needsAck: false),
    ]);
    expect(c.read(billingProvider).status, BillingStatus.pending);

    await billing.handlePurchases([_purchase(PurchaseStatus.canceled)]);
    expect(c.read(billingProvider).status, BillingStatus.ready);

    await billing.handlePurchases([_purchase(PurchaseStatus.error)]);
    expect(c.read(billingProvider).status, BillingStatus.error);

    expect(c.read(proProvider), isFalse);
    expect(iap.completed, hasLength(2));
  });

  test('store or product missing reports unavailable', () async {
    final (c1, _) = await _setup(FakeIap(available: false));
    expect(c1.read(billingProvider).status, BillingStatus.unavailable);

    final (c2, iap) = await _setup(FakeIap(hasProduct: false));
    expect(c2.read(billingProvider).status, BillingStatus.unavailable);
    expect(iap.restores, 0);
  });
}
