import 'package:inpensefinal_app/data/Sources/LocalDB/LocalDatabase.dart';
import 'package:inpensefinal_app/data/Respository/AccountBookRepository.dart';
import 'package:inpensefinal_app/ui/Splash/splash_event.dart';
import 'package:inpensefinal_app/ui/Splash/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {

  AccountBookRepository _repository;

  SplashBloc(this._repository): super(null);

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    yield* getCurrentBookId();
  }

  Stream<SplashState> getCurrentBookId() async* {
    account_book book = await _repository.getCurrentBook();
    yield* Stream.value(SplashState(bookId: book != null ? book.id : null));
  }
}