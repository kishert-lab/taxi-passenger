import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/data/repositories/order_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEventAction, OrderState> {
  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState()) {
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<OrderCurrentRequested>(_onOrderCurrentRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<OrderHistoryRequested>(_onOrderHistoryRequested);
    on<OrderActiveUpdated>(_onOrderActiveUpdated);
  }

  final OrderRepository _orderRepository;

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );
    try {
      final order = await _orderRepository.createOrder(
        pickup: event.pickup,
        destination: event.destination,
        tariffId: event.tariffId,
      );
      emit(state.copyWith(isLoading: false, activeOrder: order, clearError: true));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<void> _onOrderCurrentRequested(
    OrderCurrentRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final order = await _orderRepository.loadCurrentOrder();
      emit(
        state.copyWith(
          activeOrder: order,
          resetActiveOrder: order == null,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: _messageFromError(error)));
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

    try {
      final cancelledOrder = await _orderRepository.cancelOrder(
        order.id,
        reason: event.reason,
      );
      emit(
        state.copyWith(
          activeOrder: cancelledOrder,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: _messageFromError(error)));
    }
  }

  Future<void> _onOrderHistoryRequested(
    OrderHistoryRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingHistory: true,
        clearError: true,
      ),
    );
    try {
      final orders = await _orderRepository.loadOrders();
      emit(
        state.copyWith(
          isLoadingHistory: false,
          history: orders,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingHistory: false,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<void> _onOrderActiveUpdated(
    OrderActiveUpdated event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        activeOrder: event.order,
        resetActiveOrder: event.order == null,
        clearError: true,
      ),
    );
  }

  String _messageFromError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Ошибка соединения';
  }
}
