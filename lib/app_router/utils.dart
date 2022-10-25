class PathUtils {
  static String joinPaths(String path1, String path2) {
    if (path1.isEmpty) {
      return path2;
    }

    return '${path1 == '/' ? '' : path1}/$path2';
  }
}
