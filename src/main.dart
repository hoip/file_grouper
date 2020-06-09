import 'dart:io';
import 'package:watcher/watcher.dart';
import 'file_grouper.dart';

Future<String> getUserName() async {
  var userName = '';

  //executing shell command and parse output
  await Process.run('id',['-un']).then((value) => userName = value.stdout);

  return userName.trim();
}


void main() async {
  // getting path to downloads folder
  final String path = '/Users/${await getUserName()}/Downloads';

  // init FileGrouper
  final FileGrouper fileGrouper = FileGrouper(path);

  await fileGrouper.init();

  DirectoryWatcher(path).events.listen((event) {
      // check if type is adding
      if(event.type != ChangeType.ADD) return;

      fileGrouper.onAddEvent(event.path);
  }).onError((e) => print(e));
}
