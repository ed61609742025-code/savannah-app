import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/wildlife_models.dart';

class AppState extends ChangeNotifier {
  final List<WildlifeVideo> _videos = List.from(MockData.videos);
  final List<Creator> _creators = List.from(MockData.creators);
  final List<ParkLocation> _parks = List.from(MockData.parks);
  final List<Comment> _comments = List.from(MockData.comments);
  final UserProfile _currentUser = MockData.defaultUser;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  WildlifeVideo? _activeVideo;
  WildlifeVideo? _paywallVideo;
  Creator? _selectedCreator;

  // 2x2 Multi-Cam Matrix State (4 slot IDs)
  final List<String> _matrixSlots = ['vid_2', 'vid_3', 'vid_4', 'vid_5'];
  int _audioSoloSlot = 0; // Slot 0 has active sound

  // Getters
  List<WildlifeVideo> get videos => _videos;
  List<Creator> get creators => _creators;
  List<ParkLocation> get parks => _parks;
  List<Comment> get comments => _comments;
  UserProfile get currentUser => _currentUser;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  WildlifeVideo? get activeVideo => _activeVideo;
  WildlifeVideo? get paywallVideo => _paywallVideo;
  Creator? get selectedCreator => _selectedCreator;

  List<String> get matrixSlots => _matrixSlots;
  int get audioSoloSlot => _audioSoloSlot;

  List<WildlifeVideo> get filteredVideos {
    return _videos.where((v) {
      final matchesCategory = _selectedCategory == 'All' ||
          v.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (_selectedCategory == 'Live 24/7' && v.isLive) ||
          (_selectedCategory == 'Exclusives' && v.isExclusive);
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.species.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<WildlifeVideo> get liveStreams => _videos.where((v) => v.isLive).toList();
  List<WildlifeVideo> get exclusiveVideos => _videos.where((v) => v.isExclusive).toList();

  WildlifeVideo? getVideoById(String id) {
    try {
      return _videos.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Creator? getCreatorById(String id) {
    try {
      return _creators.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  ParkLocation? getParkById(String id) {
    try {
      return _parks.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isVideoUnlocked(String videoId) {
    final video = getVideoById(videoId);
    if (video == null || !video.isExclusive) return true;
    return _currentUser.unlockedVideoIds.contains(videoId);
  }

  bool isFollowingCreator(String creatorId) {
    return _currentUser.followedCreatorIds.contains(creatorId);
  }

  // Actions
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveVideo(WildlifeVideo? video) {
    _activeVideo = video;
    notifyListeners();
  }

  void setPaywallVideo(WildlifeVideo? video) {
    _paywallVideo = video;
    notifyListeners();
  }

  void setSelectedCreator(Creator? creator) {
    _selectedCreator = creator;
    notifyListeners();
  }

  void setAudioSoloSlot(int slotIndex) {
    _audioSoloSlot = slotIndex;
    notifyListeners();
  }

  void swapMatrixSlot(int slotIndex, String videoId) {
    if (slotIndex >= 0 && slotIndex < _matrixSlots.length) {
      _matrixSlots[slotIndex] = videoId;
      notifyListeners();
    }
  }

  void likeVideo(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _videos[index].likes++;
      notifyListeners();
    }
  }

  void toggleFollowCreator(String creatorId) {
    if (_currentUser.followedCreatorIds.contains(creatorId)) {
      _currentUser.followedCreatorIds.remove(creatorId);
    } else {
      _currentUser.followedCreatorIds.add(creatorId);
    }
    notifyListeners();
  }

  bool unlockVideo(String videoId, {required String paymentMethod}) {
    final video = getVideoById(videoId);
    if (video == null) return false;

    final price = video.exclusivePrice ?? 4.99;

    if (paymentMethod == 'wallet') {
      final tokenCost = price * 10; // $4.99 -> 50 SAV
      if (_currentUser.walletBalance < tokenCost) {
        return false;
      }
      _currentUser.walletBalance -= tokenCost;
    }

    if (!_currentUser.unlockedVideoIds.contains(videoId)) {
      _currentUser.unlockedVideoIds.add(videoId);
      _currentUser.conservationFundContribution += (price * 0.70); // 70% to ranger fund
    }

    _paywallVideo = null;
    notifyListeners();
    return true;
  }

  bool tipCreator(String creatorId, double amountUsd) {
    final creatorIndex = _creators.indexWhere((c) => c.id == creatorId);
    if (creatorIndex != -1) {
      // 100% of tips go to creator
      _currentUser.conservationFundContribution += amountUsd;
      _currentUser.walletBalance = (_currentUser.walletBalance - (amountUsd * 10)).clamp(0, 999999);
      notifyListeners();
      return true;
    }
    return false;
  }

  void addComment(String videoId, String text, {double? tipAmount}) {
    if (text.trim().isEmpty) return;

    final newComment = Comment(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      author: _currentUser.name,
      avatarUrl: _currentUser.avatarUrl,
      text: text.trim(),
      timestamp: DateTime.now(),
      tipAmount: tipAmount,
    );

    _comments.insert(0, newComment);
    if (tipAmount != null && tipAmount > 0) {
      final video = getVideoById(videoId);
      if (video != null) {
        tipCreator(video.creatorId, tipAmount);
      }
    }
    notifyListeners();
  }

  bool requestMpesaPayout(double amountUsd, String phone) {
    // In production connects to Safaricom Daraja STK Push API
    notifyListeners();
    return true;
  }
}
