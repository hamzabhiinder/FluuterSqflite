import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class PaginationScreen extends StatelessWidget {
  const PaginationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your news',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<PaginationCubit, PaginationState>(
        builder: (context, state) {
          if (state.isFirstLoadRunning) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return PostList(
              posts: state.posts,
              controller: state.controller,
              cubit: context.read<PaginationCubit>(),
            );
          }
        },
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<dynamic> posts;
  final ScrollController controller;
  final PaginationCubit cubit;

  const PostList({
    required this.posts,
    required this.controller,
    required this.cubit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            controller.position.extentAfter == 0) {
          // Load more data when the user scrolls to the end of the list
          cubit.loadMore();
        }
        return true;
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              controller: controller,
              itemBuilder: (_, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  leading: Text(posts[index]['id'].toString()),
                  title: Text(posts[index]['title']),
                  subtitle: Text(posts[index]['body']),
                ),
              ),
            ),
          ),
          if (cubit.state.isLoadMoreRunning)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!cubit.state.hasNextPage)
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              color: Colors.amber,
              child: const Center(
                child: Text('You have fetched all of the content'),
              ),
            ),
        ],
      ),
    );
  }
}

class PaginationCubit extends Cubit<PaginationState> {
  PaginationCubit() : super(PaginationState.init()) {
    firstLoad();
    state.controller = ScrollController();
  }

  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  void firstLoad() async {
    emit(state.copyWith(isFirstLoadRunning: true));

    try {
      final res = await http.get(
          Uri.parse("$_baseUrl?_page=${state.page}&_limit=${state.limit}"));

      emit(state.copyWith(posts: json.decode(res.body)));
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    emit(state.copyWith(isFirstLoadRunning: false));
  }

  void loadMore() async {
    if (state.hasNextPage &&
        !state.isFirstLoadRunning &&
        !state.isLoadMoreRunning) {
      emit(state.copyWith(isLoadMoreRunning: true));

      emit(state.copyWith(page: state.page + 1));

      try {
        final res = await http.get(
            Uri.parse("$_baseUrl?_page=${state.page}&_limit=${state.limit}"));

        final List fetchedPosts = json.decode(res.body);

        if (fetchedPosts.isNotEmpty) {
          emit(state.copyWith(posts: [...state.posts, ...fetchedPosts]));
        } else {
          emit(state.copyWith(hasNextPage: false));
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      emit(state.copyWith(isLoadMoreRunning: false));
    }
  }
}

class PaginationState {
  final int page;
  final int limit;
  final bool isFirstLoadRunning;
  final bool hasNextPage;
  final bool isLoadMoreRunning;
  final List<dynamic> posts;
  ScrollController controller;

  PaginationState({
    required this.page,
    required this.limit,
    required this.isFirstLoadRunning,
    required this.hasNextPage,
    required this.isLoadMoreRunning,
    required this.posts,
    required this.controller,
  });

  factory PaginationState.init() => PaginationState(
        page: 0,
        limit: 20,
        isFirstLoadRunning: false,
        hasNextPage: true,
        isLoadMoreRunning: false,
        posts: [],
        controller: ScrollController(),
      );

  PaginationState copyWith({
    int? page,
    int? limit,
    bool? isFirstLoadRunning,
    bool? hasNextPage,
    bool? isLoadMoreRunning,
    List? posts,
    ScrollController? controller,
  }) {
    return PaginationState(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isFirstLoadRunning: isFirstLoadRunning ?? this.isFirstLoadRunning,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadMoreRunning: isLoadMoreRunning ?? this.isLoadMoreRunning,
      posts: posts ?? this.posts,
      controller: controller ?? this.controller,
    );
  }
}
