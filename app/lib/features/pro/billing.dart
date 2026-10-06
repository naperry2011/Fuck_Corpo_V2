import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../state/providers.dart';

/// One-time, non-consumable product. Must match the product ID created in
/// Play Console > Monetize > In-app products.
const proProductId = 'pro_unlock';

enum BillingStatus { loading, ready, unavailable, pending, error }

class BillingState {
  const BillingState(this.status, {this.product, this.message});

  final BillingStatus status;
  final ProductDetails? product;
  final String? message;

  BillingState copyWith(BillingStatus status, {String? message}) =>
      BillingState(status, product: product, message: message);
}

final inAppPurchaseProvider =
    Provider<InAppPurchase>((ref) => InAppPurchase.instance);

/// Talks to Google Play Billing. Purchases are trusted client-side (no
/// receipt server); a paid unlock flips the local Pro flag in [proProvider].
class BillingNotifier extends Notifier<BillingState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;

  InAppPurchase get _iap => ref.read(inAppPurchaseProvider);

  @override
  BillingState build() {
    // Listen before anything else so purchases finished in a previous
    // session (or approved while pending) still get delivered.
    _sub = ref.watch(inAppPurchaseProvider).purchaseStream.listen(
          handlePurchases,
          onError: (Object e) => state =
              state.copyWith(BillingStatus.error, message: 'Billing error: $e'),
        );
    ref.onDispose(() => _sub?.cancel());
    Future.microtask(_connect);
    return const BillingState(BillingStatus.loading);
  }

  Future<void> _connect() async {
    try {
      if (!await _iap.isAvailable()) {
        state = const BillingState(BillingStatus.unavailable,
            message: "Google Play billing isn't available on this device.");
        return;
      }
      final response = await _iap.queryProductDetails({proProductId});
      final product = response.productDetails
          .where((p) => p.id == proProductId)
          .firstOrNull;
      if (product == null) {
        state = const BillingState(BillingStatus.unavailable,
            message: "The promotion isn't on sale yet. Check back soon.");
        return;
      }
      state = BillingState(BillingStatus.ready, product: product);
      // Quietly re-grant Pro after a reinstall or on a new phone.
      await _iap.restorePurchases();
    } catch (e) {
      state = BillingState(BillingStatus.unavailable,
          message: "Couldn't reach Google Play: $e");
    }
  }

  Future<void> buy() async {
    final product = state.product;
    if (product == null) return;
    state = state.copyWith(BillingStatus.pending);
    try {
      final started = await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: product));
      if (!started) state = state.copyWith(BillingStatus.ready);
    } catch (e) {
      state = state.copyWith(BillingStatus.error,
          message: "Couldn't start the purchase: $e");
    }
  }

  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      state = state.copyWith(BillingStatus.error,
          message: "Couldn't restore: $e");
    }
  }

  Future<void> handlePurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != proProductId) continue;
      switch (p.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(BillingStatus.pending,
              message: 'Payment pending. Pro unlocks when Google confirms it.');
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await ref.read(proProvider.notifier).unlock();
          state = state.copyWith(BillingStatus.ready);
        case PurchaseStatus.error:
          state = state.copyWith(BillingStatus.error,
              message: p.error?.message ?? 'Purchase failed.');
        case PurchaseStatus.canceled:
          state = state.copyWith(BillingStatus.ready);
      }
      // Acknowledges the purchase on Play; unacknowledged purchases are
      // refunded automatically after a few days.
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }
}

final billingProvider =
    NotifierProvider<BillingNotifier, BillingState>(BillingNotifier.new);
