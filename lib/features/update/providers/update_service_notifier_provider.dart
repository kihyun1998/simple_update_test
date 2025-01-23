import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_update_test/features/update/services/update_service.dart';

part 'update_service_notifier_provider.g.dart';

@riverpod
class UpdateServiceNotifier extends _$UpdateServiceNotifier {
  @override
  Future<UpdateService> build() async {
    final service = UpdateService();
    await Future.delayed(const Duration(milliseconds: 100)); // 초기화를 위한 지연
    return service;
  }
}
