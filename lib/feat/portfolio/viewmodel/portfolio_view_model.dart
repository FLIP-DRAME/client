import '../../main/model/drone_pilot_model.dart';

class PortfolioViewModel {
  const PortfolioViewModel(this.pilot);

  final DronePilot pilot;

  bool get hasImages => pilot.portfolioImages.isNotEmpty;
}
