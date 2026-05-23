import '../network/quote_api.dart';
import '../model/quote_model.dart';

class QuoteViewModel {
  const QuoteViewModel(this._api);

  final QuoteApi _api;

  Future<QuoteEstimate> createEstimate(QuoteRequest request) {
    return _api.createEstimate(request);
  }

  Future<PaymentInstruction> createPaymentInstruction(QuoteEstimate estimate) {
    return _api.createPaymentInstruction(estimate);
  }

  Future<ContactAccess> createContactAccess(QuoteEstimate estimate) {
    return _api.createContactAccess(estimate);
  }
}
