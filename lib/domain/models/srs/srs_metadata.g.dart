// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SrsMetadataAdapter extends TypeAdapter<SrsMetadata> {
  @override
  final typeId = 0;

  @override
  SrsMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SrsMetadata(
      questionIdentity: fields[0] as String,
      fileIdentifier: fields[1] as String,
      interval: fields[2] == null ? 0 : (fields[2] as num).toInt(),
      repetition: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      easeFactor: fields[4] == null ? 2.5 : (fields[4] as num).toDouble(),
      nextReviewDate: fields[5] as DateTime?,
      timesCorrect: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      timesIncorrect: fields[7] == null ? 0 : (fields[7] as num).toInt(),
      questionText: fields[8] == null ? '' : fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SrsMetadata obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.questionIdentity)
      ..writeByte(1)
      ..write(obj.fileIdentifier)
      ..writeByte(2)
      ..write(obj.interval)
      ..writeByte(3)
      ..write(obj.repetition)
      ..writeByte(4)
      ..write(obj.easeFactor)
      ..writeByte(5)
      ..write(obj.nextReviewDate)
      ..writeByte(6)
      ..write(obj.timesCorrect)
      ..writeByte(7)
      ..write(obj.timesIncorrect)
      ..writeByte(8)
      ..write(obj.questionText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SrsMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
