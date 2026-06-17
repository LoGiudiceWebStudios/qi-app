class HomeEvent {
  final String id;
  final String title;
  final String imageUrl;
  final String date;

  HomeEvent({required this.id, required this.title, required this.imageUrl, required this.date});

  factory HomeEvent.fromJson(Map<String, dynamic> json) {
    return HomeEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class HomeOffer {
  final String id;
  final String title;
  final String imageUrl;

  HomeOffer({required this.id, required this.title, required this.imageUrl});

  factory HomeOffer.fromJson(Map<String, dynamic> json) {
    return HomeOffer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class HomeData {
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final bool isKitchenOpen;
  final String kitchenOpeningTime;
  final String kitchenClosingTime;
  final String locationName;
  final String nextEvent;
  final List<HomeEvent> events;
  final List<HomeOffer> offers;

  HomeData({
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.isKitchenOpen,
    required this.kitchenOpeningTime,
    required this.kitchenClosingTime,
    required this.locationName,
    required this.nextEvent,
    required this.events,
    required this.offers,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var rawEvents = json['events'] as List<dynamic>? ?? [];
    var eventsList = rawEvents.map((e) => HomeEvent.fromJson(e)).toList();

    var rawOffers = json['offers'] as List<dynamic>? ?? [];
    var offersList = rawOffers.map((e) => HomeOffer.fromJson(e)).toList();

    return HomeData(
      isOpen: json['isOpen'] ?? false,
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      isKitchenOpen: json['isKitchenOpen'] ?? false,
      kitchenOpeningTime: json['kitchenOpeningTime'] ?? '',
      kitchenClosingTime: json['kitchenClosingTime'] ?? '',
      locationName: json['locationName'] ?? '',
      nextEvent: json['nextEvent'] ?? '',
      events: eventsList,
      offers: offersList,
    );
  }
}
