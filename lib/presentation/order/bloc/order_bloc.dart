import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/data/repositories/order_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEventAction, OrderState> {
  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState()) {
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<OrderHistoryRequested>(_onOrderHistoryRequested);
    on<OrderActiveUpdated>(_onOrderActiveUpdated);
  }

  final OrderRepository _orderRepository;

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final order = await _orderRepository.createOrder(
        pickup: event.pickup,
        destination: event.destination,
        tariffId: event.tariffId,
      );
      emit(state.copyWith(isLoading: false, activeOrder: order));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Ошибка соединения'));
    }
  }

  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<OrderState> emit,
  ) async {
    final order = state.activeOrder;
    if (order == null) {
      return;
    }

    await _orderRepository.cancelOrder(order.id);
    emit(
      state.copyWith(
        activeOrder: order.copyWith(status: OrderStatus.cancelled),
        errorMessage: 'Заказ отменен',
      ),
    );
  }

  Future<void> _onOrderHistoryRequested(
    OrderHistoryRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true, errorMessage: null));
    try {
      final orders = await _orderRepository.loadOrders();
      emit(state.copyWith(isLoadingHistory: false, history: orders));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingHistory: false,
          errorMessage: 'Ошибка соединения',
        ),
      );
    }
  }

  Future<void> _onOrderActiveUpdated(
    OrderActiveUpdated event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(activeOrder: event.order, errorMessage: null));
  }
}
