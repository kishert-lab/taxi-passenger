part of 'order_bloc.dart';

class OrderState extends Equatable {
  const OrderState({
    this.activeOrder,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  final Order? activeOrder;
  final List<Order> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  OrderState copyWith({
    Order? activeOrder,
    bool resetActiveOrder = false,
    List<Order>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderState(
      activeOrder: resetActiveOrder ? null : (activeOrder ?? this.activeOrder),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: clearError ? null : errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    activeOrder,
    history,
    isLoading,
    isLoadingHistory,
    errorMessage,
  ];
}
