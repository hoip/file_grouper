import 'dart:io';

class FileGrouper {
  final String workingDirectory;
  String _documents;
  String _images;
  String _archives;
  String _others;

  FileGrouper(this.workingDirectory);

  String getAddedFile(String file) => file.split('/').last;

  Future<void> init() async {
    this._documents = await this.checkIfAlreadyFolderExists('documents');
    this._images = await this.checkIfAlreadyFolderExists('images');
    this._archives = await this.checkIfAlreadyFolderExists('archives');
    this._others = await this.checkIfAlreadyFolderExists('others');
  }
  
  Future<FileType> getType(String file) async {
    final List<String> possibleImageExtensions = ['.jpg', '.png', '.gif'];
    final List<String> possibleDocumentsExtensions = ['.docx', '.pdf', '.doc'];
    final List<String> possibleArchiveExtensions = ['.zip', '.tar', '.tar.gz'];

    final String extension = file.substring(file.lastIndexOf('.'), file.length).toLowerCase();

    if (possibleImageExtensions.contains(extension)) {
      return FileType.IMAGE;
    } else if (possibleDocumentsExtensions.contains(extension)) {
      return FileType.DOCUMENT;
    } else if (possibleArchiveExtensions.contains(extension)) {
      return FileType.ARCHIVE;
    } else
      return FileType.OTHERS;
  }

  Future<String> checkIfAlreadyFolderExists(final String directory) async {
    var dir = Directory('${this.workingDirectory}/$directory/');

    if (await dir.exists()) return dir.path;

    dir.create().then((Directory directory) {
      return dir.path;

    }).catchError(print);

  }

  Future<void> moveFileByType(String file, FileType type) async {
    switch(type) {
      case FileType.ARCHIVE:
        this.moveFile(File(file), '${this._archives}/${this.getAddedFile(file)}');
        break;
      case FileType.DOCUMENT:
        this.moveFile(File(file), '${this._documents}/${this.getAddedFile(file)}');
        break;
      case FileType.IMAGE:
        this.moveFile(File(file), '${this._images}/${this.getAddedFile(file)}');
        break;
      case FileType.OTHERS:
        this.moveFile(File(file), '${this._others}/${this.getAddedFile(file)}');
        break;
    }
  }

   Future<void> onAddEvent(String file) async {
      final FileType type = await getType(file);
      await this.moveFileByType(file, type);
   }

   Future<File> moveFile(File sourceFile, String newPath) async {
        try {
          // prefer using rename as it is probably faster
          return await sourceFile.rename(newPath);
        } on FileSystemException catch (e) {
          // if rename fails, copy the source file and then delete it
          final newFile = await sourceFile.copy(newPath);
          await sourceFile.delete();
          return newFile;
        }
   }
}

// Enum of files type
class FileType {
  static const DOCUMENT = FileType('document');
  static const IMAGE = FileType('image');
  static const ARCHIVE = FileType('archive');
  static const OTHERS = FileType('others');

  final String _name;
  const FileType(this._name);

  @override
  String toString() => _name;
}
