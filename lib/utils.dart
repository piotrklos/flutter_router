class PathUtils {
  static String joinPaths(String path1, String path2) {
    if (path1.isEmpty) {
      assert(path2.startsWith('/'));
      assert(path2 == '/' || !path2.endsWith('/'));
      return path2;
    }

    assert(path2.isNotEmpty);
    assert(!path2.startsWith('/'));
    assert(!path2.endsWith('/'));
    return '${path1 == '/' ? '' : path1}/$path2';
  }
}
