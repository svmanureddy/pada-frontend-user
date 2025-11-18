import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).height / dividedBy;
}

double screenWidth(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).width / dividedBy;
}

enum PermissionGroup {
  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - Always
  locationAlways,

  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - WhenInUse
  locationWhenInUse
}

Future<Placemark> getAddressFromLatLong(
    {required double lat, required double lng}) async {
  GeocodingPlatform? geo = GeocodingPlatform.instance;
  // final coordinates = Coordinates(lat, lng);
  List<Placemark> addresses = await geo!.placemarkFromCoordinates(lat, lng);
  Placemark address = addresses.first;
  return address;
}

String getDate(String dateString) {
  final date = DateTime.parse(dateString).toUtc().toLocal();
  final format = DateFormat('yyyy-MM-dd HH:mm:ss');
  debugPrint(format.format(date));
  return format.format(date).toString();
}

String getTimeFromDate(String dateString) {
  final date = DateTime.parse(dateString).toUtc().toLocal();
  final format = DateFormat('H:mm:a');
  // debugPrint(format.format(date));
  return format.format(date).toString();
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<void> launchURL(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch ${uri.path}';
  }
}
