import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comic_model.dart';
import '../models/episode_model.dart';
import '../widgets/comic_header.dart';
import '../widgets/episode_list_tile.dart';
import 'episode_detail_screen.dart';

class ComicDetailScreen extends StatefulWidget {
  final Comic comic;

  const ComicDetailScreen({Key? key, required this.comic}) : super(key: key);

  @override
  _ComicDetailScreenState createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Episode> _episodes = [];
  bool _isLoadingEpisodes = true;
  bool _isCollapsingHeader = false;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();

    // Add scroll listener to track scrolling for collapsing header
    _scrollController.addListener(() {
      setState(() {
        _isCollapsingHeader = _scrollController.hasClients &&
            _scrollController.offset > 100;
      });
    });
  }

  Future<void> _fetchEpisodes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('comics')
          .doc(widget.comic.id)
          .collection('episodes')
          .orderBy('number', descending: false)
          .get();

      final episodes = snapshot.docs
          .map((doc) => Episode.fromFirestore(doc))
          .toList();

      setState(() {
        _episodes = episodes;
        _isLoadingEpisodes = false;
      });
    } catch (e) {
      print("Error fetching episodes: $e");
      setState(() {
        _isLoadingEpisodes = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black,
                elevation: 0,
                automaticallyImplyLeading: false, // Removing default back button
                flexibleSpace: FlexibleSpaceBar(
                  title: _isCollapsingHeader
                      ? Text(
                    widget.comic.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                      : null,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Comic header (image with overlay)
                      ComicHeader(comic: widget.comic),

                      // Custom back button - chevron style as in the image
                      Positioned(
                        top: 40,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Comic title and author at the bottom - matching the image font sizes
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.comic.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.comic.author,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      // Action genre pill - smaller font, matching image
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          widget.comic.genre.isNotEmpty ? widget.comic.genre[0] : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      // Indian Mythology genre pill - smaller font, matching image
                      if (widget.comic.genre.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            widget.comic.genre[1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // NEW tag - with the icon as shown in image
                      if (widget.comic.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50), // Matching the green in the image
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              // Icon(
                              //   Icons.fiber_new,
                              //   color: Colors.white,
                              //   size: 14,
                              // ),
                              SizedBox(width: 2),
                              Text(
                                'NEW 🌟',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    tabs: const [
                      Tab(text: 'Preview'),
                      Tab(text: 'All Episodes'),
                    ],
                    indicatorColor: Colors.white,
                    indicatorWeight: 2, // Thinner indicator as shown in image
                    indicatorSize: TabBarIndicatorSize.label, // Indicator only under text
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 14, // Smaller font size as shown in image
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14, // Smaller font size as shown in image
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildPreviewTab(),
              _buildEpisodesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Image (First episode's image)
          if (_episodes.isNotEmpty &&
              (_episodes.first.previewImage.isNotEmpty ||
                  (_episodes.first.images.isNotEmpty))) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _episodes.first.previewImage.isNotEmpty ?
                _episodes.first.previewImage :
                _episodes.first.images.first,
                placeholder: (context, url) => Container(
                  height: 400,
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ] else if (_isLoadingEpisodes) ...[
            Container(
              height: 400,
              color: Colors.grey.shade900,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    if (_isLoadingEpisodes) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_episodes.isEmpty) {
      return const Center(
        child: Text(
          'No episodes found.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _episodes.length,
      itemBuilder: (context, index) {
        // No ad logic needed for now
        final episode = _episodes[index];
        return EpisodeListTile(
          episode: episode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EpisodeDetailScreen(
                  comic: widget.comic,
                  episode: episode,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}