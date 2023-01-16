typedef Callback = Function();

class EventBlock {
  void call() {}
}

class SingleEventBlock extends EventBlock {
  Callback cb;
  SingleEventBlock({required this.cb});
  @override
  void call() => cb();
}

class EventBase {
  EventBlock connect(Callback cb) {
    throw "impl";
  }

  void disconnect(EventBlock? block) {
    throw "impl";
  }
}

class EventList extends EventBase {
  final List<EventBlock> _list = [];

  @override
  EventBlock connect(Callback cb) {
    var block = SingleEventBlock(cb: cb);
    _list.add(block);

    return block;
  }

  @override
  void disconnect(EventBlock? block) {
    if (block == null) {
      return;
    }
    _list.remove(block);
  }

  emit() {
    for (var element in _list) {
      element.call();
    }
  }
}

class MuttiEventBlock extends EventBlock {
  final List<EventBlock> _list = [];

  @override
  void call() {
    for (var element in _list) {
      element.call();
    }
  }

  void add(EventBlock block) {
    _list.add(block);
  }
}

class MultiEvent extends EventBase {
  final List<EventList> _list;

  MultiEvent({required List<EventList> list}) : _list = list;

  @override
  EventBlock connect(Callback cb) {
    MuttiEventBlock block = MuttiEventBlock();
    for (var element in _list) {
      block.add(element.connect(cb));
    }
    return block;
  }

  @override
  void disconnect(EventBlock? block) {
    if (block == null) {
      return;
    }

    MuttiEventBlock mb = block as MuttiEventBlock;

    for (var i = 0; i < _list.length; i++) {
      _list[i].disconnect(mb._list[i]);
    }
  }
}
