import '../firebase/token_service.dart';
import '../models/network/result.dart';
import '../models/token/token_model.dart';

class TokenRepository {
  final TokenService _tokenService;

  TokenRepository(this._tokenService);

  Future<Result<TokenModel, Exception>> getUserTokens(String userId) async {
    try {
      final tokenModel = await _tokenService.getUserTokens(userId);

      if (tokenModel != null) {
        return Success(tokenModel);
      } else {
        final newTokenModel = TokenModel(
          userId: userId,
          tokenCount: 5,
          lastUpdated: DateTime.now(),
        );

        final created = await _tokenService.createUserTokens(newTokenModel);
        if (created) {
          return Success(newTokenModel);
        } else {
          return Failure(Exception('Token kaydı oluşturulamadı'));
        }
      }
    } catch (e) {
      return Failure(Exception('Token bilgileri alınamadı: $e'));
    }
  }

  Future<Result<bool, Exception>> updateTokenCount(String userId, int newCount) async {
    try {
      final updated = await _tokenService.updateTokenCount(userId, newCount);
      if (updated) {
        return const Success(true);
      } else {
        return Failure(Exception('Token güncellenemedi'));
      }
    } catch (e) {
      return Failure(Exception('Token sayısı güncellenemedi: $e'));
    }
  }

  Future<Result<bool, Exception>> useToken(String userId) async {
    try {
      final tokenResult = await getUserTokens(userId);

      if (tokenResult is Success<TokenModel, Exception>) {
        final tokenModel = tokenResult.value!;
        if (tokenModel.tokenCount > 0) {
          final updated = await _tokenService.updateTokenCount(
            userId,
            tokenModel.tokenCount - 1,
          );

          if (updated) {
            return const Success(true);
          } else {
            return Failure(Exception('Token güncellenemedi'));
          }
        } else {
          return const Success(false);
        }
      } else {
        return Failure(Exception('Token bilgileri alınamadı'));
      }
    } catch (e) {
      return Failure(Exception('Token kullanılamadı: $e'));
    }
  }

  Future<Result<bool, Exception>> addTokens(String userId, int amount) async {
    try {
      final currentTokens = await _tokenService.getUserTokens(userId);
      if (currentTokens == null) {
        final newTokenModel = TokenModel(
          userId: userId,
          tokenCount: amount,
          lastUpdated: DateTime.now(),
        );
        final created = await _tokenService.createUserTokens(newTokenModel);
        return Success(created);
      }

      final newCount = currentTokens.tokenCount + amount;
      final updated = await _tokenService.updateTokenCount(userId, newCount);
      return Success(updated);
    } catch (e) {
      print('Token ekleme hatası: $e');
      return Failure(Exception('Token eklenirken bir hata oluştu: $e'));
    }
  }
}
