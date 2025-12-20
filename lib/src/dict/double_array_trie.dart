// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:typed_data';

const String _termChar = "\u0000";
const int _termCode = 0;
const int _rootId = 0;
const int _notFound = -1;
const bool _baseSigned = true;
const bool _checkSigned = true;
const int _baseBytes = 4;
const int _checkBytes = 4;
const int _memoryExpandRatio = 2;

class _BaseCheck {
  late Int32List _base;
  late Int32List _check;
  int _firstUnusedNode;

  _BaseCheck([int initialSize = 1024]) : _firstUnusedNode = _rootId + 1 {
    _base = _newIntArrayBuffer(_baseSigned, _baseBytes, initialSize);
    _check = _newIntArrayBuffer(_checkSigned, _checkBytes, initialSize);

    _base[_rootId] = 1;
    _check[_rootId] = _rootId;

    _initBase(_base, _rootId + 1, _base.length);

    _initCheck(_check, _rootId + 1, _check.length);
  }

  void _initBase(Int32List baseArray, int start, int end) {
    for (int i = start; i < end; i++) {
      baseArray[i] = -i + 1;
    }
    if (_check.isNotEmpty && 0 < _check[_check.length - 1]) {
      int lastUsedId = _check.length - 2;
      while (0 < _check[lastUsedId]) {
        lastUsedId--;
      }
      baseArray[start] = -lastUsedId;
    }
  }

  void _initCheck(Int32List checkArray, int start, int end) {
    for (int i = start; i < end; i++) {
      checkArray[i] = -i - 1;
    }
  }

  void _realloc(int minSize) {
    final newSize = minSize * _memoryExpandRatio;

    final baseNewArray = _newIntArrayBuffer(_baseSigned, _baseBytes, newSize);
    _initBase(baseNewArray, _base.length, newSize);
    baseNewArray.setAll(0, _base);
    _base = baseNewArray;

    final checkNewArray =
        _newIntArrayBuffer(_checkSigned, _checkBytes, newSize);
    _initCheck(checkNewArray, _check.length, newSize);
    checkNewArray.setAll(0, _check);
    _check = checkNewArray;
  }

  Int32List getBaseBuffer() => _base;

  Int32List getCheckBuffer() => _check;

  _BaseCheck loadBaseBuffer(Int32List baseBuffer) {
    _base = baseBuffer;
    return this;
  }

  _BaseCheck loadCheckBuffer(Int32List checkBuffer) {
    _check = checkBuffer;
    return this;
  }

  int size() => _base.length;

  int getBase(int index) {
    if (index >= _base.length) {
      return -index + 1;
    }
    return _base[index];
  }

  int getCheck(int index) {
    if (index >= _check.length) {
      return -index - 1;
    }
    return _check[index];
  }

  void setBase(int index, int baseValue) {
    if (index >= _base.length) {
      _realloc(index + 1);
    }
    _base[index] = baseValue;
  }

  void setCheck(int index, int checkValue) {
    if (index >= _check.length) {
      _realloc(index + 1);
    }
    _check[index] = checkValue;
  }

  void setFirstUnusedNode(int index) {
    _firstUnusedNode = index;
  }

  int getFirstUnusedNode() => _firstUnusedNode;

  void shrink() {
    int lastIndex = size() - 1;
    while (lastIndex >= 0) {
      if (_check[lastIndex] >= 0) {
        break;
      }
      lastIndex--;
    }

    int newLength = lastIndex + 2;
    if (newLength > _base.length) {
      newLength = _base.length;
    }

    _base = Int32List.fromList(_base.sublist(0, newLength));
    _check = Int32List.fromList(_check.sublist(0, newLength));
  }

  Map<String, dynamic> calc() {
    int unusedCount = 0;
    int currentSize = _check.length;
    for (int i = 0; i < currentSize; i++) {
      if (_check[i] < 0) {
        unusedCount++;
      }
    }
    return {
      'all': currentSize,
      'unused': unusedCount,
      'efficiency': (currentSize - unusedCount) / currentSize
    };
  }

  String dump() {
    final dumpBase = _base.join(" ");
    final dumpCheck = _check.join(" ");
    return "base:$dumpBase chck:$dumpCheck";
  }
}

class _KeyRecord {
  final Uint8List k;
  final int? v;

  _KeyRecord({required this.k, this.v});
}

class DoubleArrayBuilder {
  final _BaseCheck bc;
  List<_KeyRecord> _keys;

  DoubleArrayBuilder([int? initialSize])
      : bc = _BaseCheck(initialSize ?? 1024),
        _keys = [];

  DoubleArrayBuilder append(String key, int? record) {
    _keys.add(_KeyRecord(k: _stringToUtf8Bytes(key + _termChar), v: record));
    return this;
  }

  DoubleArray build([List<Map<String, dynamic>>? keys, bool sorted = false]) {
    List<_KeyRecord> buffKeys;

    if (keys == null) {
      buffKeys = _keys;
    } else {
      buffKeys = keys.map((k) {
        return _KeyRecord(k: _stringToUtf8Bytes(k['k'] + _termChar), v: k['v']);
      }).toList();
    }

    if (!sorted) {
      buffKeys.sort((k1, k2) {
        final b1 = k1.k;
        final b2 = k2.k;
        final minLength = b1.length < b2.length ? b1.length : b2.length;
        for (int pos = 0; pos < minLength; pos++) {
          if (b1[pos] == b2[pos]) {
            continue;
          }
          return b1[pos].compareTo(b2[pos]);
        }
        return b1.length.compareTo(b2.length);
      });
    }

    _keys = buffKeys;
    _build(_rootId, 0, 0, _keys.length);
    return DoubleArray(bc);
  }

  void _build(int parentIndex, int position, int start, int length) {
    final childrenInfo = _getChildrenInfo(position, start, length);
    final baseValue = _findAllocatableBase(childrenInfo);

    _setBC(parentIndex, childrenInfo, baseValue);

    for (int i = 0; i < childrenInfo.length; i += 3) {
      final childCode = childrenInfo[i];
      if (childCode == _termCode) {
        continue;
      }
      final childStart = childrenInfo[i + 1];
      final childLen = childrenInfo[i + 2];
      final childIndex = baseValue + childCode;
      _build(childIndex, position + 1, childStart, childLen);
    }
  }

  Int32List _getChildrenInfo(int position, int start, int length) {
    int currentChar = _keys[start].k[position];
    final childrenInfoList = <int>[];

    childrenInfoList.add(currentChar);
    childrenInfoList.add(start);

    int nextPos = start;
    int startPos = start;
    for (; nextPos < start + length; nextPos++) {
      final nextChar = _keys[nextPos].k[position];
      if (currentChar != nextChar) {
        childrenInfoList.add(nextPos - startPos);

        childrenInfoList.add(nextChar);
        childrenInfoList.add(nextPos);
        currentChar = nextChar;
        startPos = nextPos;
      }
    }
    childrenInfoList.add(nextPos - startPos);

    return Int32List.fromList(childrenInfoList);
  }

  void _setBC(int parentId, Int32List childrenInfo, int base) {
    bc.setBase(parentId, base);

    for (int i = 0; i < childrenInfo.length; i += 3) {
      final code = childrenInfo[i];
      final childId = base + code;

      final prevUnusedId = -bc.getBase(childId);
      final nextUnusedId = -bc.getCheck(childId);

      if (childId != bc.getFirstUnusedNode()) {
        bc.setCheck(prevUnusedId, -nextUnusedId);
      } else {
        bc.setFirstUnusedNode(nextUnusedId);
      }
      bc.setBase(nextUnusedId, -prevUnusedId);

      final check = parentId;
      bc.setCheck(childId, check);

      if (code == _termCode) {
        final startPos = childrenInfo[i + 1];
        final value = _keys[startPos].v;

        final baseValue = -(value ?? 0) - 1;
        bc.setBase(childId, baseValue);
      }
    }
  }

  int _findAllocatableBase(Int32List childrenInfo) {
    int baseValue;
    int curr = bc.getFirstUnusedNode();

    while (true) {
      baseValue = curr - childrenInfo[0];

      if (baseValue < 0) {
        curr = -bc.getCheck(curr);
        continue;
      }

      bool emptyAreaFound = true;
      for (int i = 0; i < childrenInfo.length; i += 3) {
        final code = childrenInfo[i];
        final candidateId = baseValue + code;

        if (!_isUnusedNode(candidateId)) {
          curr = -bc.getCheck(curr);
          emptyAreaFound = false;
          break;
        }
      }
      if (emptyAreaFound) {
        return baseValue;
      }
    }
  }

  bool _isUnusedNode(int index) {
    final check = bc.getCheck(index);

    if (index == _rootId) {
      return false;
    }
    if (check < 0) {
      return true;
    }

    return false;
  }
}

class DoubleArray {
  final _BaseCheck bc;

  DoubleArray(this.bc) {
    bc.shrink();
  }

  bool contain(String key) {
    final buffer = _stringToUtf8Bytes(key + _termChar);

    int parent = _rootId;
    int child = _notFound;

    for (int i = 0; i < buffer.length; i++) {
      final code = buffer[i];

      child = _traverse(parent, code);
      if (child == _notFound) {
        return false;
      }

      if (bc.getBase(child) <= 0) {
        if (i == buffer.length - 1 && code == _termCode) {
          return true;
        } else if (i == buffer.length - 1 && code != _termCode) {
          return false;
        }
      }
      parent = child;
    }

    final lastChildBase = bc.getBase(child);
    return lastChildBase <= 0 && buffer.last == _termCode;
  }

  int lookup(String key) {
    final buffer = _stringToUtf8Bytes(key + _termChar);

    int parent = _rootId;
    int child = _notFound;

    for (int i = 0; i < buffer.length; i++) {
      final code = buffer[i];
      child = _traverse(parent, code);
      if (child == _notFound) {
        return _notFound;
      }
      parent = child;
    }

    final base = bc.getBase(child);
    if (base <= 0) {
      return -base - 1;
    } else {
      return _notFound;
    }
  }

  List<Map<String, dynamic>> commonPrefixSearch(String key) {
    final buffer = _stringToUtf8Bytes(key);

    int parent = _rootId;
    int child = _notFound;

    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < buffer.length; i++) {
      final code = buffer[i];

      child = _traverse(parent, code);

      if (child != _notFound) {
        parent = child;

        final grandChild = _traverse(child, _termCode);

        if (grandChild != _notFound) {
          final base = bc.getBase(grandChild);

          if (base <= 0) {
            result.add({
              'v': -base - 1,
              'k': _utf8BytesToString(_arrayCopy(buffer, 0, i + 1))
            });
          }
        }
        continue;
      } else {
        break;
      }
    }

    return result;
  }

  int _traverse(int parent, int code) {
    final child = bc.getBase(parent) + code;
    if (child >= 0 && bc.getCheck(child) == parent) {
      return child;
    } else {
      return _notFound;
    }
  }

  int size() => bc.size();

  Map<String, dynamic> calc() => bc.calc();

  String dump() => bc.dump();
}

class DoubleArrayTrie {
  DoubleArrayTrie._();

  static DoubleArrayBuilder builder([int? initialSize]) {
    return DoubleArrayBuilder(initialSize);
  }

  static DoubleArray load(Int32List baseBuffer, Int32List checkBuffer) {
    final bc = _BaseCheck();
    bc.loadBaseBuffer(baseBuffer);
    bc.loadCheckBuffer(checkBuffer);
    return DoubleArray(bc);
  }
}

Int32List _newIntArrayBuffer(bool signed, int bytes, int size) {
  switch (bytes) {
    case 1:
      throw UnsupportedError(
          "1-byte integer arrays are not directly used for Base/Check in this context.");
    case 2:
      throw UnsupportedError(
          "2-byte integer arrays are not directly used for Base/Check in this context.");
    case 4:
      return Int32List(size);
    default:
      throw RangeError("Invalid newArray parameter element_bytes: $bytes");
  }
}

Uint8List _arrayCopy(Uint8List src, int srcOffset, int length) {
  return Uint8List.fromList(src.sublist(srcOffset, srcOffset + length));
}

Uint8List _stringToUtf8Bytes(String str) {
  return Utf8Encoder().convert(str);
}

String _utf8BytesToString(Uint8List bytes) {
  return Utf8Decoder().convert(bytes);
}
