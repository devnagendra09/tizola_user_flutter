import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/service_order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Result<ServiceOrderEntity>> fetchServiceOrderView({
    required String refId,
  }) async {
    try {
      final data = await _remote.fetchServiceOrderView(refId: refId);
      return Result.success(data);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
