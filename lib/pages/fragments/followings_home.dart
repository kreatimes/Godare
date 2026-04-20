import 'package:flutter/material.dart';
import 'package:godare/models/post.dart';
import 'package:godare/services/post_service.dart';
import 'package:godare/widgets/basics/post_card.dart';

/// Feed de usuarios seguidos — misma estructura que GlobalHome
/// pero filtrando solo posts de gente a la que sigue el usuario.
class FollowingsHome extends StatefulWidget {
  const FollowingsHome({super.key});

  @override
  State<FollowingsHome> createState() => _FollowingsHomeState();
}

class _FollowingsHomeState extends State<FollowingsHome> {
  final ScrollController _scrollController = ScrollController();

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _cursorId;
  String? _cursorCreatedAt;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    try {
      final feed = await PostService.getFollowingFeed();
      if (!mounted) return;
      setState(() {
        _posts = feed.posts;
        _hasMore = feed.hasMore;
        _cursorId = feed.nextCursorId;
        _cursorCreatedAt = feed.nextCursorCreatedAt;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final feed = await PostService.getFollowingFeed(
        cursorId: _cursorId,
        cursorCreatedAt: _cursorCreatedAt,
      );
      if (!mounted) return;
      setState(() {
        _posts.addAll(feed.posts);
        _hasMore = feed.hasMore;
        _cursorId = feed.nextCursorId;
        _cursorCreatedAt = feed.nextCursorCreatedAt;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMore();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _posts = [];
      _hasMore = true;
      _cursorId = null;
      _cursorCreatedAt = null;
      _isLoading = true;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('Sigue a alguien para ver sus posts aquí'),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PostCard(post: _posts[index]);
        },
      ),
    );
  }
}