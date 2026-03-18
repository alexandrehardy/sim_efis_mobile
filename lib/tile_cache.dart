import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/settings.dart';

const int maxHash = 100;

class Tile {
  final int x;
  final int y;
  final int n;
  final int zoom;
  final ui.Offset offset;

  const Tile({
    required this.x,
    required this.y,
    required this.n,
    required this.zoom,
    required this.offset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          zoom == other.zoom;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ zoom.hashCode;

  int get cacheHashCode => (x + y + zoom) % maxHash;

  String get cacheDiskName => '${zoom}_${x}_$y';
}

class ConcurrentJobManager<T> {
  final int maxConcurrentJobs;
  final Map<T, bool> activeJobs = {};

  ConcurrentJobManager({required this.maxConcurrentJobs});
  bool addJob(T key, Future Function() compute) {
    if (activeJobs.length >= maxConcurrentJobs) {
      return false;
    }
    if (activeJobs.containsKey(key)) {
      return false;
    }
    activeJobs[key] = true;
    compute().then(
      (value) => activeJobs.remove(key),
      onError: (e) => activeJobs.remove(key),
    );
    return true;
  }
}

class DiskWriteJob {
  final Tile tile;
  final Uint8List byteList;
  final bool clearCache;

  const DiskWriteJob({
    required this.tile,
    required this.byteList,
    this.clearCache = false,
  });
}

class TileCacheEntry extends LinkedListEntry<TileCacheEntry> {
  Tile tile;
  ui.Image image;
  DateTime lastUse;

  TileCacheEntry({
    required this.tile,
    required this.image,
    required this.lastUse,
  });
}

class FileWithStat {
  final FileSystemEntity file;
  final FileStat stat;

  const FileWithStat({
    required this.file,
    required this.stat,
  });
}

class TileDiskCache {
  static bool running = false;
  static int totalDiskTiles = 0;
  static int maxConcurrentJobs = 5;

  static StreamController<DiskWriteJob> writeJobController = StreamController();

  static void checkRunning() {
    if (!running) {
      writerLoop();
      running = true;
    }
  }

  static Future<FileWithStat> getStat(FileSystemEntity file) async {
    FileStat stat = await file.stat();
    return FileWithStat(file: file, stat: stat);
  }

  static Future<bool> evictTile(Directory mapDir, hashCode, bool last) async {
    int i;
    Directory mapBucketDir = Directory('${mapDir.path}/$hashCode');
    List<FileSystemEntity> files = await mapBucketDir.list().toList();
    List<Future<FileWithStat>> deferredStats = [
      for (FileSystemEntity file in files) getStat(file)
    ];
    List<FileWithStat> stats = await Future.wait(deferredStats);

    FileWithStat? oldest;
    for (FileWithStat file in stats) {
      if (oldest == null) {
        oldest = file;
      } else if (file.stat.accessed.isBefore(oldest.stat.accessed)) {
        oldest = file;
      }
    }

    if (oldest != null) {
      await oldest.file.delete();
      return true;
    }

    if (last) {
      return false;
    }

    for (i = 0; i < maxHash; i++) {
      if (i != hashCode) {
        bool evicted = await evictTile(mapDir, i, true);
        if (evicted) {
          return true;
        }
      }
    }
    return false;
  }

  static Future<void> clearCache() async {
    int i;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory('${appDocDir.path}/maps');

    for (i = 0; i < maxHash; i++) {
      Directory mapBucketDir = Directory('${mapDir.path}/$i');
      List<FileSystemEntity> files = await mapBucketDir.list().toList();
      for (FileSystemEntity file in files) {
        try {
          await file.delete();
        } catch (e) {
          // Don't fail here.
        }
      }
    }
  }

  static Future<void> writerLoop() async {
    int i;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory('${appDocDir.path}/maps');

    totalDiskTiles = 0;
    for (i = 0; i < maxHash; i++) {
      Directory mapBucketDir = Directory('${mapDir.path}/$i');
      await mapBucketDir.create(recursive: true);
      totalDiskTiles += await mapBucketDir.list().length;
    }

    await for (DiskWriteJob job in writeJobController.stream) {
      if (job.clearCache) {
        await clearCache();
      } else {
        try {
          Tile tile = job.tile;
          if (totalDiskTiles < Settings.maxMapDiskTiles) {
            totalDiskTiles++;
          } else {
            await evictTile(mapDir, tile.cacheHashCode, false);
          }
          Directory mapBucketDir =
              Directory('${mapDir.path}/${tile.cacheHashCode}');
          String destinationPath =
              '${mapBucketDir.path}/${tile.cacheDiskName}.png';
          File mapSegmentFile = File('${mapBucketDir.path}/_http_tile.png');
          await mapSegmentFile.writeAsBytes(job.byteList);
          // Do an atomic rename to put the file in place
          await mapSegmentFile.rename(destinationPath);
        } catch (e, s) {
          if (kDebugMode) {
            print('Failed to save tile $e $s');
          }
        }
      }
    }
  }

  static Future<int> getDiskTileCount() async {
    int i;
    int totalDiskTiles = 0;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory('${appDocDir.path}/maps');

    for (i = 0; i < maxHash; i++) {
      Directory mapBucketDir = Directory('${mapDir.path}/$i');
      totalDiskTiles += await mapBucketDir.list().length;
    }
    return totalDiskTiles;
  }

  static Future<int> getDiskTileSpace() async {
    int i;
    int totalDiskTileFootprint = 0;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory('${appDocDir.path}/maps');

    for (i = 0; i < maxHash; i++) {
      Directory mapBucketDir = Directory('${mapDir.path}/$i');
      if (await mapBucketDir.exists()) {
        List<FileSystemEntity> files = await mapBucketDir.list().toList();
        for (FileSystemEntity file in files) {
          totalDiskTileFootprint += (await file.stat()).size;
        }
      }
    }
    return totalDiskTileFootprint;
  }
}

class TileMemoryCache {
  // Actual servers:
  //static List<String> servers = [
  //  'a.tile.opentopomap.org',
  //  'b.tile.opentopomap.org',
  //  'c.tile.opentopomap.org',
  //];
  static List<String> servers = ['dt0ck0geoz4zg.cloudfront.net'];
  static int serverIndex = 0;
  // Dictionary to map tile to image
  static Map<Tile, TileCacheEntry> tileCache = {};
  // List of buckets used to figure out least recently used.
  static LinkedList<TileCacheEntry> leastRecentlyUsedList = LinkedList();
  static bool running = false;
  static int maxConcurrentJobs = 10;
  static int maxQueueSize = 20;
  static int queueSize = 0;
  static StreamController<Tile> controller = StreamController();
  static ConcurrentJobManager<Tile> diskConcurrentJobManager =
      ConcurrentJobManager(maxConcurrentJobs: maxConcurrentJobs);
  static ConcurrentJobManager<Tile> httpConcurrentJobManager =
      ConcurrentJobManager(maxConcurrentJobs: maxConcurrentJobs);
  static void checkRunning() {
    if (!running) {
      fetcherLoop();
      running = true;
    }
  }

  static String nextServer() {
    serverIndex++;
    if (serverIndex >= servers.length) {
      serverIndex = 0;
    }
    return servers[serverIndex];
  }

  static void evictTile(LinkedList<TileCacheEntry> list) {
    if (list.isEmpty) return;
    TileCacheEntry entry = list.last;
    entry.image.dispose();
    tileCache.remove(entry.tile);
    list.remove(list.last);
    return;
  }

  static TileCacheEntry createTileCacheEntry(Tile tile, ui.Image image) {
    LinkedList<TileCacheEntry> list = leastRecentlyUsedList;
    if (list.length < Settings.maxMapMemoryTiles) {
      //cachedTiles++;
    } else {
      evictTile(list);
    }
    TileCacheEntry entry = TileCacheEntry(
      tile: tile,
      image: image,
      lastUse: DateTime.now(),
    );

    list.addFirst(entry);
    return entry;
  }

  static Future<void> fetchDiskTile(Tile tile, File mapSegmentFile) async {
    if (await mapSegmentFile.exists()) {
      try {
        Uint8List byteList = await mapSegmentFile.readAsBytes();
        ui.Codec codec = await ui.instantiateImageCodec(byteList);
        ui.FrameInfo frame = await codec.getNextFrame();
        tileCache[tile] = createTileCacheEntry(tile, frame.image);
      } catch (e) {
        // This file cannot be decoded. It is corrupted.
        // Delete it and continue
        await mapSegmentFile.delete();
      }
    }
  }

  static Future<void> fetchHttpTile(Tile tile) async {
    try {
      String server = nextServer();

      HttpClient client = HttpClient();
      // To disable certificate verification, use:
      // client.badCertificateCallback =
      //    (X509Certificate cert, String host, int port) => true;

      // Build the request
      HttpClientRequest request = await client.getUrl(
        Uri(
          scheme: 'https',
          host: server,
          path: '${tile.zoom}/${tile.x}/${tile.y}.png',
        ),
      );
      request.followRedirects = true;
      // Add headers etc.
      // Then close to send it
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        List<List<int>> chunks = await response.toList();
        List<int> bytes = [];
        for (List<int> chunk in chunks) {
          bytes.addAll(chunk);
        }
        Uint8List byteList = Uint8List.fromList(bytes);
        ui.Codec codec = await ui.instantiateImageCodec(byteList);
        ui.FrameInfo frame = await codec.getNextFrame();
        TileDiskCache.checkRunning();
        // TODO: Don't add the job if there are too many
        // jobs running. Move this to a function.
        TileDiskCache.writeJobController.add(
          DiskWriteJob(
            tile: tile,
            byteList: byteList,
          ),
        );
        tileCache[tile] = createTileCacheEntry(tile, frame.image);
      } else {
        await response.drain();
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('Failed to fetch tile $e $s');
      }
    }
  }

  static Future<void> fetcherLoop() async {
    queueSize = 0;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory mapDir = Directory('${appDocDir.path}/maps');
    await mapDir.create(recursive: true);

    await for (Tile tile in controller.stream) {
      queueSize--;
      try {
        if (!tileCache.containsKey(tile)) {
          Directory mapBucketDir =
              Directory('${mapDir.path}/${tile.cacheHashCode}');
          File mapSegmentFile =
              File('${mapBucketDir.path}/${tile.cacheDiskName}.png');

          if (await mapSegmentFile.exists()) {
            diskConcurrentJobManager.addJob(
                tile, () => fetchDiskTile(tile, mapSegmentFile));
          } else {
            httpConcurrentJobManager.addJob(tile, () => fetchHttpTile(tile));
          }
        }
      } catch (e, s) {
        if (kDebugMode) {
          print('Failed to fetch tile $e $s');
        }
      }
    }
  }

  static moveFirst(TileCacheEntry entry) {
    LinkedList<TileCacheEntry> list = leastRecentlyUsedList;
    entry.lastUse = DateTime.now();
    entry.unlink();
    list.addFirst(entry);
  }

  static ui.Image? getTile(int zoom, int x, int y) {
    Tile tile = Tile(
      zoom: zoom,
      x: x,
      y: y,
      n: 0,
      offset: const ui.Offset(0.0, 0.0),
    );
    if (tileCache.containsKey(tile)) {
      TileCacheEntry cacheEntry = tileCache[tile]!;
      moveFirst(cacheEntry);
      return cacheEntry.image;
    } else {
      TileMemoryCache.checkRunning();
      if (queueSize < maxQueueSize) {
        queueSize++;
        controller.add(tile);
      }
      return null;
    }
  }

  static int getMemoryTileCount() {
    int count = leastRecentlyUsedList.length;
    return count;
  }
}
