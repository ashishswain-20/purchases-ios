//
//  RCStoreKitWrapper.m
//  Purchases
//
//  Created by Jacob Eiting on 9/30/17.
//  Copyright © 2017 RevenueCat, Inc. All rights reserved.
//

#import "RCStoreKitWrapper.h"

#import "RCUtils.h"

@interface RCStoreKitWrapper ()
@property (nonatomic) SKPaymentQueue *paymentQueue;
@property (nonatomic) BOOL purchasing;
@end

@implementation RCStoreKitWrapper

@synthesize delegate = _delegate;

- (instancetype)init
{
    return [self initWithPaymentQueue:SKPaymentQueue.defaultQueue];
}

- (instancetype)initWithPaymentQueue:(SKPaymentQueue *)paymentQueue
{
    if (self = [super init]) {
        self.paymentQueue = paymentQueue;
    }
    return self;
}

- (void)dealloc
{
    [self.paymentQueue removeTransactionObserver:self];
}

- (void)setDelegate:(id<RCStoreKitWrapperDelegate>)delegate
{
    _delegate = delegate;

    if (_delegate != nil) {
        [self.paymentQueue addTransactionObserver:self];
    } else {
        [self.paymentQueue removeTransactionObserver:self];
    }
}

- (id<RCStoreKitWrapperDelegate>)delegate
{
    return _delegate;
}

- (void)addPayment:(SKPayment *)payment
{
    [self.paymentQueue addPayment:payment];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
    RCDebugLog(@"Finishing %@ %@ (%@)", transaction.payment.productIdentifier,
                transaction.transactionIdentifier, transaction.originalTransaction.transactionIdentifier);

    [self.paymentQueue finishTransaction:transaction];
}

- (NSData *)receiptData {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    return [NSData dataWithContentsOfURL:receiptURL];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    BOOL isPurchasing = NO;
    
    for (SKPaymentTransaction *transaction in transactions) {
        [self.delegate storeKitWrapper:self updatedTransaction:transaction];

        if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
            isPurchasing = YES;
        }
    }

    self.purchasing = isPurchasing;
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        [self.delegate storeKitWrapper:self removedTransaction:transaction];
    }
}

@end