import 'package:either_dart/either.dart';
import 'package:biedronka_extractor/data/dart_export.dart';

abstract class Repository {
  Future<Either<String, double>> postTarget(double target);

  Future<Either<String, double>> getTarget();

  Future<Either<String, EntryResponse>> postEntry(EntryPayload entry);

  Future<Either<String, EntryResponse>> getEntries();

  Future<Either<String, EntryResponse>> deleteEntry(String entryId);
}
