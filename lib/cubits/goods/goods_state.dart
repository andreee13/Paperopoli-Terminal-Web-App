part of 'goods_cubit.dart';

@immutable
abstract class GoodsState {
  const GoodsState();
}

class GoodsInitial extends GoodsState {
  const GoodsInitial();

  @override
  String toString() => 'Initial';
}

class GoodsLoading extends GoodsState {
  const GoodsLoading();

  @override
  String toString() => 'Loading';
}

class GoodsLoaded extends GoodsState {
  final List<GoodModel> goods;

  const GoodsLoaded({
    required this.goods,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoodsLoaded && other.goods == goods;
  }

  @override
  int get hashCode => goods.hashCode;

  @override
  String toString() => 'Loaded';
}

class GoodsError extends GoodsState {
  final Exception exception;

  const GoodsError(
    this.exception,
  );
}
