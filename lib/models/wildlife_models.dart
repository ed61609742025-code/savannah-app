class Creator {
  final String id;
  final String name;
  final String handle;
  final String role;
  final String bio;
  final String avatarUrl;
  final String coverUrl;
  final String location;
  final String conservancy;
  final int followers;
  final int backers;
  final String totalViews;
  final double tipsRaised;
  final bool isVerified;
  final double tierPrice;
  final List<String> tierPerks;

  const Creator({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    required this.bio,
    required this.avatarUrl,
    required this.coverUrl,
    required this.location,
    required this.conservancy,
    required this.followers,
    required this.backers,
    required this.totalViews,
    required this.tipsRaised,
    this.isVerified = true,
    this.tierPrice = 7.99,
    this.tierPerks = const [
      'Direct voice radio access during live drives',
      'Free unlock for all monthly PPV events & 4K replays',
      'Weekly GPS migration coordinates & private field diary',
    ],
  });
}

class ParkLocation {
  final String id;
  final String name;
  final String country;
  final String flag;
  final String description;
  final double lat;
  final double lng;
  final int liveCamsCount;
  final List<String> species;
  final String weather;
  final String imageUrl;

  const ParkLocation({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
    required this.description,
    required this.lat,
    required this.lng,
    required this.liveCamsCount,
    required this.species,
    required this.weather,
    required this.imageUrl,
  });
}

class WildlifeVideo {
  final String id;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String thumbnailUrl;
  final String duration;
  final int views;
  int likes;
  final bool isLive;
  final bool isExclusive;
  final double? exclusivePrice;
  final String creatorId;
  final String parkId;
  final List<String> species;
  final String? cameraRig;
  final String? sensorMode; // "WIDE", "IR THERMAL", "TELE", "PTZ ROBOTIC"

  WildlifeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.likes,
    required this.isLive,
    this.isExclusive = false,
    this.exclusivePrice,
    required this.creatorId,
    required this.parkId,
    required this.species,
    this.cameraRig,
    this.sensorMode,
  });

  int get viewersCount => views;
}

class Comment {
  final String id;
  final String author;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  final bool isRanger;
  final double? tipAmount;

  const Comment({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.isRanger = false,
    this.tipAmount,
  });
}

class PayoutRecord {
  final String id;
  final double amountUsd;
  final double amountKes;
  final String phone;
  final String status;
  final DateTime date;
  final String reference;

  const PayoutRecord({
    required this.id,
    required this.amountUsd,
    required this.amountKes,
    required this.phone,
    required this.status,
    required this.date,
    required this.reference,
  });
}

class UserProfile {
  final String id;
  String name;
  String handle;
  final String avatarUrl;
  double walletBalance;
  final List<String> unlockedVideoIds;
  final List<String> followedCreatorIds;
  double conservationFundContribution;

  UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.walletBalance,
    required this.unlockedVideoIds,
    required this.followedCreatorIds,
    required this.conservationFundContribution,
  });
}
