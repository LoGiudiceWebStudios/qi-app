class HomeEvent {
  final String id;
  final String title;
  final String imageUrl;
  final String date;

  HomeEvent({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
  });

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
  final bool isActive;
  final String activationLabel;

  HomeOffer({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.isActive = true,
    this.activationLabel = '',
  });

  factory HomeOffer.fromJson(Map<String, dynamic> json) {
    return HomeOffer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] as bool? ?? true,
      activationLabel: json['activationLabel'] ?? '',
    );
  }
}

class HomePost {
  final String id;
  final String title;
  final String message;
  final String createdAt;

  HomePost({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory HomePost.fromJson(Map<String, dynamic> json) {
    return HomePost(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
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
  final List<HomePost>? _posts;

  List<HomePost> get posts => _posts ?? const [];

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
    List<HomePost>? posts,
  }) : _posts = posts;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var rawEvents = json['events'] as List<dynamic>? ?? [];
    var eventsList = rawEvents.map((e) => HomeEvent.fromJson(e)).toList();

    var rawOffers = json['offers'] as List<dynamic>? ?? [];
    var offersList = rawOffers.map((e) => HomeOffer.fromJson(e)).toList();

    var rawPosts = json['posts'] as List<dynamic>? ?? [];
    var postsList = rawPosts.map((e) => HomePost.fromJson(e)).toList();

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
      posts: postsList,
    );
  }
}
