import '../../../../core/utils/result.dart';
import '../entities/service_order_entity.dart';

abstract class OrdersRepository {
  Future<Result<ServiceOrderEntity>> fetchServiceOrderView({
    required String refId,
  });

  Future<Result<String>> cancelOrder({
    required String refId,
    required String reason,
  });
}
