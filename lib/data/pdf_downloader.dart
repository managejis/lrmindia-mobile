import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfResult {
  /// Copy kept inside the app (used to open the file, and again later without internet).
  final String path;
  /// True when a copy was also placed in the phone's Download/ABBA Sunday School folder.
  final bool inDownloads;
  PdfResult(this.path, this.inDownloads);
}

class PdfNotAvailable implements Exception {
  final int status;
  PdfNotAvailable(this.status);
}

/// Downloads a PDF straight to the phone (no browser) and saves it in Downloads.
class PdfDownloader {
  static const folderName = 'ABBA Sunday School';
  static bool _storeReady = false;

  static Future<PdfResult> download(String url, String fileName, {void Function(double progress)? onProgress}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'workbooks'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));

    // Already downloaded earlier: reuse it (works offline).
    if (!(await file.exists() && await file.length() > 0)) {
      final client = http.Client();
      final tmp = File('${file.path}.part');
      try {
        final resp = await client.send(http.Request('GET', Uri.parse(url)));
        if (resp.statusCode != 200) throw PdfNotAvailable(resp.statusCode);
        final total = resp.contentLength ?? 0;
        var got = 0;
        final sink = tmp.openWrite();
        try {
          await for (final chunk in resp.stream) {
            sink.add(chunk);
            got += chunk.length;
            if (total > 0) onProgress?.call(got / total);
          }
        } finally {
          await sink.close();
        }
        await tmp.rename(file.path);
      } catch (_) {
        if (await tmp.exists()) await tmp.delete();
        rethrow;
      } finally {
        client.close();
      }
    }
    onProgress?.call(1);

    var inDownloads = false;
    try {
      if (Platform.isAndroid) {
        if (!_storeReady) {
          await MediaStore.ensureInitialized();
          MediaStore.appFolder = folderName;
          _storeReady = true;
        }
        // MediaStore may move the file it is given, so hand it a staging copy.
        final stage = File(p.join((await getTemporaryDirectory()).path, fileName));
        await file.copy(stage.path);
        final info = await MediaStore().saveFile(
          tempFilePath: stage.path,
          dirType: DirType.download,
          dirName: DirName.download,
        );
        inDownloads = info != null;
        if (await stage.exists()) await stage.delete();
      }
    } catch (_) {
      inDownloads = false;   // still opens from the app copy
    }
    return PdfResult(file.path, inDownloads);
  }
}
