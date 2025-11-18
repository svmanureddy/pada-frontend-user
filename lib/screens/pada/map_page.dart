import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/colors.dart';
import '../../core/errors/exceptions.dart';
import '../../core/models/connector_model.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/button.dart';

class AddressPage extends StatefulWidget {
  final String locType;
  final bool showMapDirectly;
  const AddressPage(
      {super.key, required this.locType, this.showMapDirectly = false});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  double? currentLatitude, currentLongitude;
  var uuid = const Uuid();
  final String _sessionToken = '1234567890';
  bool isMap = false;
  bool isLoaded = false;
  String? hintText = '';
  TextEditingController fromLocController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CameraPosition? cameraPosition;
  Uint8List? greenMarker;
  String location = "Location Name:";
  String placeID = "";
  bool isChecked = false;
  FocusNode focusNode = FocusNode();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(13.1344635197085, 77.6717135197085),
    zoom: 14.4746,
  );
  bool isFilled = false;
  List<dynamic> addressList = [];
  Set<Marker> _markers = {};
  Timer? _debounceTimer;
  bool _isLoadingAddress = false;
  bool _isLocationSame = false; // Track if current location matches the other location

  @override
  void initState() {
    super.initState();
    hintText =
        widget.locType == "pickup" ? "Pick-up location" : "Drop-off location";
    // Show map directly if requested
    if (widget.showMapDirectly) {
      isMap = true;
    }
    _getSavedAddresses();
    // Fetch current location immediately if map is shown directly
    if (widget.showMapDirectly) {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Fetch saved addresses from the API
  Future<void> _getSavedAddresses() async {
    var addressResponse = await ApiService().getSavedAddress();
    if (addressResponse != null && addressResponse['success']) {
      setState(() {
        addressList = addressResponse['data'] ?? [];
      });
    } else {
      debugPrint("Failed to fetch saved addresses");
    }
    setState(() {
      isLoaded = true;
    });
    // Fetch current location if not already fetched (for non-map-directly views)
    if (!widget.showMapDirectly) {
      await _fetchCurrentLocation();
    }
  }

  /// Check if the selected location is the same as the other location
  bool _isSameLocation(LatLng selectedLocation, String locType) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    if (locType == 'pickup') {
      // If setting pickup, check against drop-off
      if (appProvider.dropAddress?.latlng != null) {
        final dropLat = appProvider.dropAddress!.latlng!.latitude;
        final dropLng = appProvider.dropAddress!.latlng!.longitude;
        return selectedLocation.latitude == dropLat && 
               selectedLocation.longitude == dropLng;
      }
    } else {
      // If setting drop-off, check against pickup
      if (appProvider.pickupAddress?.latlng != null) {
        final pickupLat = appProvider.pickupAddress!.latlng!.latitude;
        final pickupLng = appProvider.pickupAddress!.latlng!.longitude;
        return selectedLocation.latitude == pickupLat && 
               selectedLocation.longitude == pickupLng;
      }
    }
    return false;
  }

  /// Update the location same state based on current coordinates
  void _updateLocationSameState() {
    if (currentLatitude != null && currentLongitude != null) {
      final selectedLatLng = LatLng(currentLatitude!, currentLongitude!);
      final isSame = _isSameLocation(selectedLatLng, widget.locType);
      if (_isLocationSame != isSame) {
        setState(() {
          _isLocationSame = isSame;
        });
      }
    }
  }

  /// Delete a saved address
  Future<void> _deleteAddress(String addressId, int index) async {
    try {
      var response = await ApiService().deleteAddress(addressId);
      if (response != null && response['success'] == true) {
        // Remove the address from the list
        setState(() {
          addressList.removeAt(index);
        });
        NotificationService().showToast(
          context,
          "Address deleted successfully",
          type: NotificationType.success,
        );
        // Refresh the address list to ensure consistency
        await _getSavedAddresses();
      } else {
        final message = (response != null &&
                response is Map &&
                response['message'] != null)
            ? response['message'].toString()
            : 'Failed to delete address';
        NotificationService().showToast(
          context,
          message,
          type: NotificationType.error,
        );
      }
    } catch (e) {
      String errorMessage = 'Something went wrong';
      if (e is ClientException) {
        errorMessage = e.message ?? 'Something went wrong';
      } else if (e is ServerException) {
        errorMessage = e.message ?? 'Something went wrong';
      } else if (e is HttpException) {
        errorMessage = e.message ?? 'Something went wrong';
      }
      NotificationService().showToast(
        context,
        errorMessage,
        type: NotificationType.error,
      );
    }
  }

  /// Fetch current location and update map
  Future<void> _fetchCurrentLocation() async {
    try {
      // Request location permission if needed
      if (Platform.isAndroid) {
        var statusPermission = await Permission.location.status;
        if (!statusPermission.isGranted || statusPermission.isLimited) {
          await Permission.location.request();
        }
      }

      // Check permission status
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();

      if (permission == geo.LocationPermission.denied) {
        // Request permission
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.deniedForever) {
        debugPrint("Location permission permanently denied");
        return;
      }

      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) {
        // Get current position
        var location = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );

        // Update camera position
        _kGooglePlex = CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15.4746,
        );

        // Set current coordinates
        currentLatitude = location.latitude;
        currentLongitude = location.longitude;

        // Update map camera if controller is ready
        if (_controller.isCompleted) {
          GoogleMapController controller = await _controller.future;
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.latitude, location.longitude),
              15.4746,
            ),
          );
        }

        // Update marker position
        if (mounted) {
          setState(() {
            _markers = {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: LatLng(location.latitude, location.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            };
          });
        }

        // Load address for current location
        await _onMapDrag(LatLng(location.latitude, location.longitude));

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Error fetching current location: $e");
    }
  }

  /// Handle map drag and update address details
  Future<void> _onMapDrag(LatLng newPosition) async {
    try {
      currentLatitude = newPosition.latitude;
      currentLongitude = newPosition.longitude;

      // Fetch place ID using the current latitude and longitude
      if (currentLatitude == null || currentLongitude == null) {
        return;
      }
      var resp =
          await ApiService().getPlaceId(currentLatitude!, currentLongitude!);
      if (resp != null && resp['results'].isNotEmpty) {
        var placeId = resp['results'][0]['place_id'];

        // Fetch place details using the place ID
        var placeDetails =
            await ApiService().getPlaceDetailsById(placeId: placeId);
        if (placeDetails != null && placeDetails['result'] != null) {
          if (mounted) {
            setState(() {
              placeID = placeId;
              fromLocController.clear();
              focusNode.unfocus();
              hintText = placeDetails['result']['formatted_address'] ??
                  'Unknown address';
              fullAddressController.text =
                  placeDetails['result']['formatted_address'] ?? '';
              _isLoadingAddress = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              hintText = "Address not found";
              _isLoadingAddress = false;
            });
          }
          debugPrint("Place details not found for place ID: $placeId");
        }
      } else {
        if (mounted) {
          setState(() {
            hintText = "Address not found";
            _isLoadingAddress = false;
          });
        }
        debugPrint(
            "No place ID found for coordinates: $currentLatitude, $currentLongitude");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hintText = "Error loading address";
          _isLoadingAddress = false;
        });
      }
      debugPrint("Error in _onMapDrag: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: pureWhite,
      floatingActionButton: isMap
          ? FloatingActionButton(
              onPressed: () {
                // Check if location is the same before opening bottom sheet
                if (currentLatitude != null && currentLongitude != null) {
                  final selectedLatLng = LatLng(currentLatitude!, currentLongitude!);
                  if (_isSameLocation(selectedLatLng, widget.locType)) {
                    NotificationService().showToast(
                      context,
                      "Both locations shouldn't be same",
                      type: NotificationType.error,
                    );
                    return;
                  }
                }
                _showAddressDetailsBottomSheet(context);
              },
              backgroundColor: buttonColor,
              elevation: 4,
              child: const Icon(
                Icons.arrow_forward,
                color: pureWhite,
                size: 24,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isMap
              ? Column(
                  children: [
                    // Map Section - Full height, not scrollable
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Stack(
                          children: [
                            GoogleMap(
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: true,
                              scrollGesturesEnabled: true,
                              rotateGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              markers: _markers,
                              onCameraMove: (CameraPosition position) async {
                                // Update marker position as the map is moved
                                final lat = position.target.latitude;
                                final lng = position.target.longitude;
                                currentLatitude = lat;
                                currentLongitude = lng;

                                // Update marker position in real-time
                                setState(() {
                                  _markers = {
                                    Marker(
                                      markerId:
                                          const MarkerId('selected_location'),
                                      position: LatLng(lat, lng),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueRed,
                                      ),
                                    ),
                                  };
                                });

                                // Check if location matches the other location
                                _updateLocationSameState();

                                // Show loading state
                                if (!_isLoadingAddress) {
                                  setState(() {
                                    _isLoadingAddress = true;
                                    hintText = "Loading location...";
                                  });
                                }

                                // Debounce the address update to avoid too many API calls
                                _debounceTimer?.cancel();
                                _debounceTimer = Timer(
                                    const Duration(milliseconds: 500), () {
                                  if (currentLatitude != null &&
                                      currentLongitude != null) {
                                    _onMapDrag(LatLng(
                                        currentLatitude!, currentLongitude!));
                                  }
                                });
                              },
                              onCameraIdle: () {
                                if (currentLatitude != null &&
                                    currentLongitude != null) {
                                  _onMapDrag(LatLng(
                                      currentLatitude!, currentLongitude!));
                                  // Check if location matches after camera stops
                                  _updateLocationSameState();
                                }
                              },
                              mapType: MapType.normal,
                              initialCameraPosition: _kGooglePlex,
                              myLocationButtonEnabled: false,
                              onMapCreated:
                                  (GoogleMapController controller) async {
                                _controller.complete(controller);
                                // Initialize marker at initial position
                                if (currentLatitude == null ||
                                    currentLongitude == null) {
                                  currentLatitude =
                                      _kGooglePlex.target.latitude;
                                  currentLongitude =
                                      _kGooglePlex.target.longitude;
                                }

                                // Ensure we have valid coordinates before proceeding
                                final lat = currentLatitude ??
                                    _kGooglePlex.target.latitude;
                                final lng = currentLongitude ??
                                    _kGooglePlex.target.longitude;

                                setState(() {
                                  _markers = {
                                    Marker(
                                      markerId:
                                          const MarkerId('selected_location'),
                                      position: LatLng(lat, lng),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueRed,
                                      ),
                                    ),
                                  };
                                });

                                // Update current coordinates
                                currentLatitude = lat;
                                currentLongitude = lng;

                                // If current location is not set, try to fetch it
                                if (lat == 13.1344635197085 &&
                                    lng == 77.6717135197085) {
                                  // This is the fallback location, try to fetch current location
                                  await _fetchCurrentLocation();
                                } else {
                                  // Load address for initial position
                                  _onMapDrag(LatLng(lat, lng));
                                }
                              },
                            ),
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Card(
                                      elevation: 4,
                                      shadowColor:
                                          Colors.black.withOpacity(0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: pureWhite,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: TypeAheadField<dynamic>(
                                          focusNode: focusNode,
                                          hideOnEmpty: true,
                                          hideOnError: true,
                                          hideOnSelect: true,
                                          hideOnLoading: true,
                                          controller: fromLocController,
                                          builder: (context, controller,
                                                  focusNode) =>
                                              TextField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            autofocus: false,
                                            style: GoogleFonts.inter(
                                              color: pureBlack,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              fillColor: pureWhite,
                                              filled: true,
                                              prefixIcon: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: pureWhite
                                                              .withOpacity(0.9),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .arrow_back_ios_rounded,
                                                          color: pureBlack,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              hintStyle: GoogleFonts.inter(
                                                color: greyText,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: secondaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              hintText: hintText,
                                            ),
                                          ),
                                          decorationBuilder: (context, child) =>
                                              Material(
                                            type: MaterialType.card,
                                            elevation: 8,
                                            shadowColor:
                                                Colors.black.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: child,
                                            ),
                                          ),
                                          itemBuilder: (context, product) =>
                                              ListTile(
                                            title: Text(
                                              product['description'],
                                              style: GoogleFonts.inter(
                                                color: pureBlack,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            leading: Icon(
                                              Icons.location_on,
                                              color: secondaryColor,
                                              size: 20,
                                            ),
                                          ),
                                          onSelected: (value) async {
                                            debugPrint(
                                                ".........place:::${value['place_id']}");
                                            await ApiService()
                                                .getPlaceDetailsById(
                                                    placeId: value['place_id'])
                                                .then((value1) async {
                                              debugPrint(
                                                  "placeid::::::::: ${value1['result']['geometry']['location']}");
                                              var pickedLoc = value1['result']
                                                  ['geometry']['location'];

                                              // Set placeID and coordinates
                                              setState(() {
                                                placeID = value['place_id'];
                                                currentLatitude =
                                                    pickedLoc['lat'];
                                                currentLongitude =
                                                    pickedLoc['lng'];
                                                fullAddressController
                                                    .text = value1['result']
                                                        ['formatted_address'] ??
                                                    '';
                                              });

                                              GoogleMapController controller =
                                                  await _controller.future;
                                              controller.animateCamera(
                                                  CameraUpdate.newLatLngZoom(
                                                      LatLng(
                                                        pickedLoc['lat'],
                                                        pickedLoc['lng'],
                                                      ),
                                                      18));

                                              // Update address details
                                              await _onMapDrag(LatLng(
                                                  pickedLoc['lat'],
                                                  pickedLoc['lng']));
                                            });
                                            setState(() {});
                                          },
                                          suggestionsCallback:
                                              (String search) async {
                                            var response = await ApiService()
                                                .searchPlace(
                                                    input: search,
                                                    sessionToken:
                                                        _sessionToken);
                                            return response['predictions'];
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 12.0,
                          bottom: 16.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              const Color(0xFF003D9E),
                              secondaryColor,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: pureWhite.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: pureWhite,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    hintText ?? "Location",
                                    style: GoogleFonts.inter(
                                      color: pureWhite,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(
                                    width: 40), // Balance for back button
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content Section
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Input Field
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black.withOpacity(0.15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: pureWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: TypeAheadField<dynamic>(
                                      controller: fromLocController,
                                      builder:
                                          (context, controller, focusNode) =>
                                              TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onTap: () {
                                          setState(() {
                                            isMap = true;
                                          });
                                        },
                                        style: GoogleFonts.inter(
                                          color: pureBlack,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: pureWhite,
                                          filled: true,
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                              ],
                                            ),
                                          ),
                                          hintStyle: GoogleFonts.inter(
                                            color: greyText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: secondaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          hintText: hintText,
                                        ),
                                      ),
                                      decorationBuilder: (context, child) =>
                                          Material(
                                        type: MaterialType.card,
                                        elevation: 8,
                                        shadowColor:
                                            Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: child,
                                        ),
                                      ),
                                      itemBuilder: (context, product) =>
                                          ListTile(
                                        title: Text(
                                          product['description'],
                                          style: GoogleFonts.inter(
                                            color: pureBlack,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.location_on,
                                          color: secondaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      onSelected: (value) async {
                                        debugPrint(
                                            ".........place:::${value['place_id']}");
                                        await ApiService()
                                            .getPlaceDetailsById(
                                                placeId: value['place_id'])
                                            .then((value1) async {
                                          debugPrint(
                                              "placeid::::::::: ${value1['result']['geometry']['location']}");
                                          var pickedLoc = value1['result']
                                              ['geometry']['location'];

                                          // Set placeID and coordinates
                                          setState(() {
                                            placeID = value['place_id'];
                                            currentLatitude = pickedLoc['lat'];
                                            currentLongitude = pickedLoc['lng'];
                                            fullAddressController.text =
                                                value1['result']
                                                        ['formatted_address'] ??
                                                    '';
                                          });

                                          GoogleMapController controller =
                                              await _controller.future;
                                          controller.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                  LatLng(
                                                    pickedLoc['lat'],
                                                    pickedLoc['lng'],
                                                  ),
                                                  18));

                                          // Update address details
                                          await _onMapDrag(LatLng(
                                              pickedLoc['lat'],
                                              pickedLoc['lng']));
                                        });
                                        setState(() {
                                          isMap = true;
                                        });
                                      },
                                      suggestionsCallback:
                                          (String search) async {
                                        var response = await ApiService()
                                            .searchPlace(
                                                input: search,
                                                sessionToken: _sessionToken);
                                        return response['predictions'];
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Saved Addresses List
                              if (addressList.isNotEmpty) ...[
                                Text(
                                  "Saved Addresses",
                                  style: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: addressList.length,
                                  itemBuilder: (context, i) {
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(
                                          milliseconds: 300 + (i * 100)),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, 20 * (1 - value)),
                                          child: Opacity(
                                            opacity: value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 2,
                                        shadowColor:
                                            Colors.black.withOpacity(0.05),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            final selectedLatLng = LatLng(
                                                addressList[i]['location'][0],
                                                addressList[i]['location'][1]);
                                            
                                            // Check if this location is the same as the other location
                                            if (_isSameLocation(selectedLatLng, widget.locType)) {
                                              NotificationService().showToast(
                                                context,
                                                "Both locations shouldn't be same",
                                                type: NotificationType.error,
                                              );
                                              return;
                                            }
                                            
                                            if (widget.locType == 'pickup') {
                                              await appProvider
                                                  .setPickupAddress(
                                                      AddressModel(
                                                addressString: addressList[i]
                                                    ['address'],
                                                latlng: selectedLatLng,
                                                placeId: addressList[i]['_id'],
                                                name: addressList[i]
                                                    ['userName'],
                                                phone: addressList[i]
                                                    ['phoneNumber'],
                                              ));
                                            } else {
                                              await appProvider
                                                  .setDropAddress(AddressModel(
                                                addressString: addressList[i]
                                                    ['address'],
                                                latlng: selectedLatLng,
                                                placeId: addressList[i]['_id'],
                                                name: addressList[i]
                                                    ['userName'],
                                                phone: addressList[i]
                                                    ['phoneNumber'],
                                              ));
                                            }
                                            Navigator.pop(context, true);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: pureWhite,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: secondaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: secondaryColor,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        addressList[i]
                                                                ['userName'] ??
                                                            'Unknown',
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: pureBlack,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        addressList[i]
                                                                ['address'] ??
                                                            '',
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: addressTextColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {}, // Prevent tap from propagating to InkWell
                                                  child: PopupMenuButton<String>(
                                                    icon: Icon(
                                                      Icons.more_vert,
                                                      color: greyText,
                                                      size: 20,
                                                    ),
                                                    onSelected: (value) async {
                                                      if (value == 'delete') {
                                                        await _deleteAddress(
                                                            addressList[i]['_id'],
                                                            i);
                                                      }
                                                    },
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        <PopupMenuEntry<String>>[
                                                      PopupMenuItem<String>(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Text(
                                                              'Delete',
                                                              style: GoogleFonts
                                                                  .inter(
                                                                color: Colors.red,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showAddressDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // Local state for checkbox within bottom sheet
          bool localIsChecked = isChecked;

          return Container(
            decoration: const BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: greyBorderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Section Title
                    Text(
                      "Address details",
                      style: GoogleFonts.inter(
                        color: pureBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contact Name Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 6,
                          ),
                          child: Text(
                            "Contact Name",
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: greyBorderColor,
                              width: 1,
                            ),
                            color: pureWhite,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: nameController,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(fontSize: 0.01),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: addressTextColor,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: pureWhite,
                              hintText: "Enter contact name",
                              hintStyle: GoogleFonts.inter(
                                color: greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: secondaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Phone Number Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 6,
                          ),
                          child: Text(
                            "Phone Number",
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: greyBorderColor,
                              width: 1,
                            ),
                            color: pureWhite,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: phoneController,
                            maxLines: 1,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(fontSize: 0.01),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: addressTextColor,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: pureWhite,
                              hintText: "Enter phone number",
                              hintStyle: GoogleFonts.inter(
                                color: greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: secondaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Enter Complete Address Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 6,
                          ),
                          child: Text(
                            "Enter Complete Address",
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: greyBorderColor,
                              width: 1,
                            ),
                            color: pureWhite,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: fullAddressController,
                            maxLines: 3,
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(fontSize: 0.01),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: addressTextColor,
                                  size: 18,
                                ),
                              ),
                              filled: true,
                              fillColor: pureWhite,
                              hintText: "Enter complete address",
                              hintStyle: GoogleFonts.inter(
                                color: greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: secondaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (str) {
                              if (str!.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Save Address Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: localIsChecked,
                          onChanged: (value) {
                            setModalState(() {
                              localIsChecked = value ?? false;
                            });
                            // Also update parent state
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                          activeColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Save this address",
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Warning message if location is same
                    if (_isLocationSame)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Both locations shouldn't be same",
                                  style: GoogleFonts.inter(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: CustomButton(
                        buttonLabel: 'Confirm',
                        backGroundColor: _isLocationSame ? Colors.grey : buttonColor,
                        onTap: () async {
                          if (_isLocationSame) {
                            NotificationService().showToast(
                              context,
                              "Both locations shouldn't be same",
                              type: NotificationType.error,
                            );
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            // Ensure we have valid coordinates
                            if (currentLatitude == null ||
                                currentLongitude == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select a location on the map'),
                                ),
                              );
                              return;
                            }

                            final appProvider = Provider.of<AppProvider>(
                                context,
                                listen: false);
                            
                            final selectedLatLng = LatLng(currentLatitude!, currentLongitude!);
                            
                            // Check if this location is the same as the other location
                            if (_isSameLocation(selectedLatLng, widget.locType)) {
                              NotificationService().showToast(
                                context,
                                "Both locations shouldn't be same",
                                type: NotificationType.error,
                              );
                              return;
                            }
                            
                            if (widget.locType == 'pickup') {
                              await appProvider.setPickupAddress(AddressModel(
                                addressString: fullAddressController.text,
                                latlng: selectedLatLng,
                                placeId: placeID,
                                name: nameController.text,
                                phone: phoneController.text,
                              ));
                            } else {
                              await appProvider.setDropAddress(AddressModel(
                                addressString: fullAddressController.text,
                                latlng: selectedLatLng,
                                placeId: placeID,
                                name: nameController.text,
                                phone: phoneController.text,
                              ));
                            }
                            var address = {
                              "address": fullAddressController.text,
                              "location": [currentLatitude!, currentLongitude!],
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "placeId": placeID,
                            };

                            if (localIsChecked) {
                              try {
                                var res = await ApiService()
                                    .saveAddress(address: address);
                                debugPrint("res:: $res");
                                if (res != null && res['success'] == true) {
                                  // Address saved successfully - no toast message
                                } else {
                                  if (context.mounted) {
                                    NotificationService().showToast(
                                        context,
                                        (res != null && res['message'] != null)
                                            ? res['message']
                                            : 'Failed to save address',
                                        type: NotificationType.error);
                                  }
                                }
                              } catch (e) {
                                debugPrint("Error saving address: $e");
                                if (context.mounted) {
                                  String errorMessage =
                                      'Failed to save address';
                                  if (e is ClientException) {
                                    errorMessage =
                                        e.message ?? 'Failed to save address';
                                  } else if (e is ServerException) {
                                    errorMessage =
                                        e.message ?? 'Failed to save address';
                                  } else if (e is HttpException) {
                                    errorMessage =
                                        e.message ?? 'Failed to save address';
                                  }
                                  NotificationService().showToast(
                                      context, errorMessage,
                                      type: NotificationType.error);
                                }
                              }
                            }
                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.pop(
                                  context, true); // Return to previous screen
                            }
                          }
                        },
                        buttonWidth: double.infinity,
                        borderRadius: 24,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
