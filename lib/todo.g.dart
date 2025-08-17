// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      name: fields[0] as String,
      desc: fields[1] as String?,
      deadline: fields[2] as DateTime,
      done: fields[3] as bool,
      createdTime: fields[4] as DateTime,
    )..doneTime = fields[5] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.desc)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.done)
      ..writeByte(4)
      ..write(obj.createdTime)
      ..writeByte(5)
      ..write(obj.doneTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
