import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/models/good/good_model.dart';
import 'package:paperopoli_terminal/data/repositories/goods_repository.dart';

part 'goods_state.dart';

class GoodsCubit extends Cubit<GoodsState> {
  final GoodsRepository repository;

  GoodsCubit({
    required this.repository,
  }) : super(
          GoodsInitial(),
        );

  Future<void> fetch({
    required User user,
  }) async {
    try {
      emit(
        GoodsLoading(),
      );
      emit(
        GoodsLoaded(
          goods: await repository.fetch(
            user: user,
          ),
        ),
      );
    } on ServerException catch (e, _) {
      emit(
        GoodsError(e),
      );
    }
  }
}
