import 'package:flutter/material.dart';

class MangaReaderScreen extends StatefulWidget {
  final List<String> images;

  MangaReaderScreen({required this.images});

  @override
  _MangaReaderScreenState createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  int _currentPage = 0;
  bool _isHorizontalFlipMode = false;

  void _switchReadingMode() {
    setState(() {
      _isHorizontalFlipMode = !_isHorizontalFlipMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Page ${_currentPage + 1} of ${widget.images.length}",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'switch_mode') {
                _switchReadingMode();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'switch_mode',
                  child: Text(
                    _isHorizontalFlipMode ? 'Switch to Vertical Scroll' : 'Switch to Horizontal Flip',
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isHorizontalFlipMode ? _buildHorizontalFlipMode() : _buildVerticalScrollMode(),
      bottomNavigationBar: _buildPageSlider(),
    );
  }

  Widget _buildVerticalScrollMode() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          child: Image.network(widget.images[index], fit: BoxFit.contain),
        );
      },
    );
  }

  Widget _buildHorizontalFlipMode() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          child: Image.network(widget.images[index], fit: BoxFit.contain),
        );
      },
    );
  }

  Widget _buildPageSlider() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: _currentPage.toDouble(),
              min: 0,
              max: (widget.images.length - 1).toDouble(),
              divisions: widget.images.length - 1,
              label: "Page ${_currentPage + 1}",
              onChanged: (value) {
                setState(() {
                  _currentPage = value.round();
                });
              },
            ),
          ),
          Text(
            "${_currentPage + 1}/${widget.images.length}",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
