import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:battery_plus/battery_plus.dart';
import '../models/comic_model.dart';
import '../models/episode_model.dart';
import 'dart:async';

class EpisodeDetailScreen extends StatefulWidget {
  final Comic comic;
  final Episode episode;

  const EpisodeDetailScreen({
    Key? key,
    required this.comic,
    required this.episode,
  }) : super(key: key);

  @override
  _EpisodeDetailScreenState createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  bool isHorizontalMode = false;
  bool isFullscreenMode = false;
  late PageController _horizontalPageController;
  late ScrollController _verticalScrollController;
  int _currentPage = 0;
  double _scrollProgress = 0.0;

  // Battery implementation
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  bool _isCharging = false;

  // Time display
  String _currentTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _horizontalPageController = PageController();
    _verticalScrollController = ScrollController();
    _updateTime();

    // Initialize battery
    _initBattery();

    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _updateTime());

    // Add listeners for page changes
    _horizontalPageController.addListener(() {
      if (_horizontalPageController.hasClients && isHorizontalMode) {
        final page = _horizontalPageController.page?.round() ?? 0;
        if (page != _currentPage) {
          setState(() {
            _currentPage = page;
          });
        }
      }
    });

    _verticalScrollController.addListener(() {
      if (_verticalScrollController.hasClients && !isHorizontalMode) {
        if (_verticalScrollController.position.maxScrollExtent > 0) {
          setState(() {
            _scrollProgress = _verticalScrollController.offset / _verticalScrollController.position.maxScrollExtent;
            // Approximate current page based on scroll progress
            _currentPage = (_scrollProgress * (widget.episode.images.length - 1)).round();
          });
        }
      }
    });
  }

  Future<void> _initBattery() async {
    // Get initial battery level
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });

    // Listen for battery state changes (charging/discharging)
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _isCharging = state == BatteryState.charging;
      });
      // Also update battery level when state changes
      _updateBatteryLevel();
    });

    // Set up periodic battery level updates
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateBatteryLevel();
    });
  }

  Future<void> _updateBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${_formatTime(now.hour)}:${_formatTime(now.minute)}';
    });
  }

  String _formatTime(int time) {
    return time.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _horizontalPageController.dispose();
    _verticalScrollController.dispose();
    _timer.cancel();
    _batteryStateSubscription.cancel();

    // Ensure we restore system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreenMode() {
    setState(() {
      isFullscreenMode = !isFullscreenMode;
    });

    if (isFullscreenMode) {
      // Hide status bar and navigation in fullscreen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Show status bar and navigation when exiting fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isFullscreenMode
          ? null
          : AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.episode.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Moved fullscreen button to app bar
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _toggleFullscreenMode,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _toggleFullscreenMode,
        child: Stack(
          children: [
            isHorizontalMode
                ? _buildHorizontalView()
                : _buildVerticalView(),
            if (!isFullscreenMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20, // Raised above the bottom edge
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // Page counter
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "${_currentPage + 1}/${widget.episode.images.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Scroll progress bar
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: Colors.lightGreenAccent,
                              inactiveTrackColor: Colors.grey.shade600,
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: isHorizontalMode
                                  ? _currentPage.toDouble()
                                  : _scrollProgress * (widget.episode.images.length - 1),
                              min: 0,
                              max: (widget.episode.images.length - 1).toDouble(),
                              divisions: widget.episode.images.length > 1 ? widget.episode.images.length - 1 : 1,
                              onChanged: (value) {
                                if (isHorizontalMode) {
                                  final page = value.toInt();
                                  setState(() {
                                    _currentPage = page;
                                  });
                                  _horizontalPageController.jumpToPage(page);
                                } else {
                                  // For vertical mode, calculate position based on progress
                                  if (_verticalScrollController.hasClients) {
                                    final targetPosition = (value / (widget.episode.images.length - 1)) *
                                        _verticalScrollController.position.maxScrollExtent;
                                    _verticalScrollController.jumpTo(targetPosition);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // View mode toggle
                      IconButton(
                        icon: Icon(
                          isHorizontalMode ? Icons.view_day : Icons.view_carousel,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isHorizontalMode = !isHorizontalMode;
                          });

                          // Handle mode switch with proper position
                          if (isHorizontalMode) {
                            // Switching to horizontal: set page based on scroll progress
                            Future.delayed(Duration.zero, () {
                              if (_horizontalPageController.hasClients) {
                                _horizontalPageController.jumpToPage(_currentPage);
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            // Fullscreen top overlay (episode title, time, and battery)
            if (isFullscreenMode)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Episode title - with dark gray color
                        Expanded(
                          child: Text(
                            widget.episode.title,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Time display in dark gray
                        Text(
                          _currentTime,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Battery percentage - with dark gray color and charging indicator
                        Row(
                          children: [
                            Icon(
                              _getBatteryIcon(),
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$_batteryLevel%",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            if (_isCharging)
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Icon(
                                  Icons.bolt,
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Exit fullscreen button when in fullscreen mode - moved to bottom right
            if (isFullscreenMode)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _toggleFullscreenMode,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate battery icon based on level and charging state
  IconData _getBatteryIcon() {
    if (_isCharging) {
      return Icons.battery_charging_full;
    }

    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 75) return Icons.battery_6_bar;
    if (_batteryLevel >= 50) return Icons.battery_4_bar;
    if (_batteryLevel >= 25) return Icons.battery_3_bar;
    if (_batteryLevel >= 10) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Widget _buildVerticalView() {
    return ListView.builder(
      controller: _verticalScrollController,
      itemCount: widget.episode.images.length,
      itemBuilder: (context, index) {
        return PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.episode.images[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.lightGreenAccent,
              ),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),
          tightMode: true, // Ensures the view doesn't zoom too far out
          customSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          gaplessPlayback: true,
          enableRotation: false,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }

  Widget _buildHorizontalView() {
    return PageView.builder(
        controller: _horizontalPageController,
        itemCount: widget.episode.images.length,
        physics: const BouncingScrollPhysics(),
    pageSnapping: true,
    // Add page-like transitions
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
    return Hero(
    tag: "page_${widget.episode.id}_$index",
    child: PhotoView(
    imageProvider: CachedNetworkImageProvider(widget.episode.images[index]),
    minScale: PhotoViewComputedScale.contained,
    maxScale: PhotoViewComputedScale.covered * 3,
    initialScale: PhotoViewComputedScale.contained,
    backgroundDecoration: const BoxDecoration(color: Colors.black),
    loadingBuilder: (context, event) => Container(
    color: Colors.grey.shade900,
    child: const Center(
    child: CircularProgressIndicator(
    color: Colors.lightGreenAccent,
    ),
    ),
    ),
    tightMode: true,
      gaplessPlayback: true,
      enableRotation: false,
      filterQuality: FilterQuality.high,
    ),
    );
    },
    );
  }
}