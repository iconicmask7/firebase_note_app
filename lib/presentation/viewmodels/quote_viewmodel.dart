import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/network/dio_client.dart';

part 'quote_viewmodel.g.dart';

@riverpod
Future<String> quote(QuoteRef ref) async {
  final dio = ref.watch(dioClientProvider);
  try {
    final response = await dio.get('/random');
    if (response.statusCode == 200) {
      final content = response.data['content'] ?? '';
      final author = response.data['author'] ?? '';
      return '"$content" - $author';
    }
    return "Keep pushing forward.";
  } catch (e) {
    return "Keep pushing forward.";
  }
}
