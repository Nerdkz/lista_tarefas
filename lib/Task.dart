class Task{

  String _id;
  String _name;
  String _data;
  String _duration;
  String _local;
  List<String> _guests;

  Task(this._id, this._name, this._data, this._duration, this._local,
      this._guests);

  List<String> get guests => _guests;

  set guests(List<String> value) {
    _guests = value;
  }

  String get local => _local;

  set local(String value) {
    _local = value;
  }

  String get duration => _duration;

  set duration(String value) {
    _duration = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}