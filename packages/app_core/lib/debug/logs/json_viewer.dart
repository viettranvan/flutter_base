import 'package:flutter/material.dart';

class JsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  const JsonViewer(this.jsonObj, {super.key});
  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    return getContentWidget(widget.jsonObj);
  }

  static getContentWidget(dynamic content) {
    if (content == null) {
      return const Text('null', style: TextStyle(color: Colors.grey));
    } else if (content is Map) {
      return JsonObjectViewer(Map<String, dynamic>.from(content),
          notRoot: false);
    } else if (content is List) {
      return JsonArrayViewer(content, notRoot: false);
    } else {
      return Text(content.toString(),
          style: const TextStyle(color: Colors.white));
    }
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;

  const JsonObjectViewer(this.jsonObj, {super.key, this.notRoot = false});

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  late Map<String, bool> openFlag;

  @override
  void initState() {
    super.initState();
    openFlag = {};
    // Initialize 'headers' key as collapsed, others as expanded
    for (MapEntry entry in widget.jsonObj.entries) {
      openFlag[entry.key] = entry.key != 'headers' && isExtensible(entry.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _getList();
    final child =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: list);

    if (widget.notRoot) {
      return Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: child,
      );
    }
    return child;
  }

  _getList() {
    List<Widget> list = [];
    for (MapEntry entry in widget.jsonObj.entries) {
      bool ex = isExtensible(entry.value);
      bool ink = isInkWell(entry.value);

      list.add(_buildJsonRow(entry, ex, ink));
      list.add(const SizedBox(height: 4));

      if (openFlag[entry.key] ?? false) {
        list.add(
          RepaintBoundary(
            child: getContentWidget(entry.value),
          ),
        );
      }
    }
    return list;
  }

  Widget _buildJsonRow(MapEntry entry, bool ex, bool ink) {
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ex
              ? ((openFlag[entry.key] ?? false)
                  ? Icon(Icons.arrow_drop_down,
                      size: 14, color: Colors.grey[700])
                  : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
          (ex && ink)
              ? InkWell(
                  onTap: () {
                    setState(() {
                      openFlag[entry.key] = !(openFlag[entry.key] ?? false);
                    });
                  },
                  child: Text(entry.key,
                      style: const TextStyle(color: Colors.cyan)),
                )
              : Text(entry.key,
                  style: TextStyle(
                      color: entry.value == null ? Colors.grey : Colors.cyan)),
          Text(
            ':',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 3),
          Expanded(child: getValueWidget(entry))
        ],
      ),
    );
  }

  static getContentWidget(dynamic content) {
    if (content == null) {
      return const Text('null', style: TextStyle(color: Colors.grey));
    } else if (content is Map) {
      return JsonObjectViewer(Map<String, dynamic>.from(content),
          notRoot: true);
    } else if (content is List) {
      return JsonArrayViewer(content, notRoot: true);
    } else {
      return Text(content.toString(),
          style: const TextStyle(color: Colors.white));
    }
  }

  static isInkWell(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    } else if (content is List) {
      if (content.isEmpty) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  getValueWidget(MapEntry entry) {
    if (entry.value == null) {
      return Text(
        'undefined',
        style: TextStyle(color: Colors.grey),
      );
    } else if (entry.value is int) {
      return Text(
        entry.value.toString(),
        style: TextStyle(color: Colors.teal),
      );
    } else if (entry.value is String) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Text(
          '"${entry.value}"',
          style: const TextStyle(color: Colors.lightGreen),
        ),
      );
    } else if (entry.value is bool) {
      return Text(
        entry.value.toString(),
        style: TextStyle(color: Colors.purple),
      );
    } else if (entry.value is double) {
      return Text(
        entry.value.toString(),
        style: TextStyle(color: Colors.teal),
      );
    } else if (entry.value is List) {
      if (entry.value.isEmpty) {
        return Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey[400]),
        );
      } else {
        return InkWell(
            onTap: () {
              setState(() {
                openFlag[entry.key] = !(openFlag[entry.key] ?? false);
              });
            },
            child: Text(
              'Array<${getTypeName(entry.value[0])}>[${entry.value.length}]',
              style: TextStyle(color: Colors.grey[400]),
            ));
      }
    }
    return InkWell(
        onTap: () {
          setState(() {
            openFlag[entry.key] = !(openFlag[entry.key] ?? false);
          });
        },
        child: Text(
          'Object',
          style: TextStyle(color: Colors.grey[400]),
        ));
  }

  static isExtensible(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    }
    return true;
  }

  static getTypeName(dynamic content) {
    if (content is int) {
      return 'int';
    } else if (content is String) {
      return 'String';
    } else if (content is bool) {
      return 'bool';
    } else if (content is double) {
      return 'double';
    } else if (content is List) {
      return 'List';
    }
    return 'Object';
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool notRoot;

  const JsonArrayViewer(this.jsonArray, {super.key, this.notRoot = false});

  @override
  State<JsonArrayViewer> createState() => _JsonArrayViewerState();
}

class _JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  @override
  void initState() {
    super.initState();
    // Initialize all as expanded
    openFlag = List.filled(widget.jsonArray.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final list = _getList();
    final child =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: list);

    if (widget.notRoot) {
      return Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: child,
      );
    }
    return child;
  }

  _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = JsonObjectViewerState.isExtensible(content);
      bool ink = JsonObjectViewerState.isInkWell(content);

      list.add(_buildArrayRow(i, content, ex, ink));
      list.add(const SizedBox(height: 4));

      if (openFlag[i]) {
        list.add(
          RepaintBoundary(
            child: getContentWidget(content),
          ),
        );
      }
      i++;
    }
    return list;
  }

  Widget _buildArrayRow(int i, dynamic content, bool ex, bool ink) {
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ex
              ? ((openFlag[i])
                  ? Icon(Icons.arrow_drop_down,
                      size: 14, color: Colors.grey[700])
                  : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
          (ex && ink)
              ? InkWell(
                  onTap: () {
                    setState(() {
                      openFlag[i] = !openFlag[i];
                    });
                  },
                  child:
                      Text('[$i]', style: const TextStyle(color: Colors.cyan)),
                )
              : Text('[$i]',
                  style: TextStyle(
                      color: content == null ? Colors.grey : Colors.cyan)),
          Text(
            ':',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 3),
          Expanded(child: getArrayItemWidget(content, i))
        ],
      ),
    );
  }

  static getContentWidget(dynamic content) {
    if (content == null) {
      return const Text('null', style: TextStyle(color: Colors.grey));
    } else if (content is Map) {
      return JsonObjectViewer(Map<String, dynamic>.from(content),
          notRoot: true);
    } else if (content is List) {
      return JsonArrayViewer(content, notRoot: true);
    } else {
      return Text(content.toString(),
          style: const TextStyle(color: Colors.white));
    }
  }

  getArrayItemWidget(dynamic content, int index) {
    if (content == null) {
      return const Text('null', style: TextStyle(color: Colors.grey));
    } else if (content is int) {
      return Text(
        content.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (content is String) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Text(
          '"$content"',
          style: const TextStyle(color: Colors.lightGreen),
        ),
      );
    } else if (content is bool) {
      return Text(
        content.toString(),
        style: const TextStyle(color: Colors.purple),
      );
    } else if (content is double) {
      return Text(
        content.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey[400]),
        );
      } else {
        return InkWell(
            onTap: () {
              setState(() {
                openFlag[index] = !openFlag[index];
              });
            },
            child: Text(
              'Array<${JsonObjectViewerState.getTypeName(content[0])}>[${content.length}]',
              style: TextStyle(color: Colors.grey[400]),
            ));
      }
    }
    return InkWell(
        onTap: () {
          setState(() {
            openFlag[index] = !openFlag[index];
          });
        },
        child: Text(
          'Object',
          style: TextStyle(color: Colors.grey[400]),
        ));
  }
}
