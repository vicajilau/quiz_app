enum ExportFormats {
  pdf,
  image;

  String getFormat() {
    switch (this) {
      case pdf:
        return ".pdf";
      case image:
        return ".png";
    }
  }
}
