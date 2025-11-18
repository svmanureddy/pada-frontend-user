// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:deliverapp/core/models/connector_model.dart';
// import 'package:deliverapp/core/services/api_service.dart';
// import 'package:deliverapp/core/services/notification_service.dart';
// import 'package:deliverapp/widgets/button.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../core/colors.dart';
// import '../../core/providers/app_provider.dart';
// import '../../core/utils.dart';
//
// class AddressPage extends StatefulWidget {
//   final String locType;
//   const AddressPage({super.key, required this.locType});
//
//   @override
//   State<AddressPage> createState() => _AddressPageState();
// }
//
// class _AddressPageState extends State<AddressPage> {
//   var uuid = const Uuid();
//   bool isMap = false;
//   String _sessionToken = '1234567890';
//   String? hintText = '';
//   TextEditingController fromLocController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController fullAddressController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   CameraPosition? cameraPosition;
//   Uint8List? greenMarker;
//   String location = "Location Name:";
//   String placeID = "";
//   bool isChecked = false;
//   FocusNode focusNode = FocusNode();
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(13.1344635197085, 77.6717135197085),
//     zoom: 12.4746,
//   );
//   Set<Marker> marker = Set();
//   bool isFilled = false;
//   List<dynamic> addressList = [];
//
//   // Marker (fixed marker)
//   late Set<Marker> _markers = {};
//
//   markerImage() async {
//     greenMarker = await getBytesFromAsset('assets/images/map_marker.png', 100);
//
//     _markers = {
//       Marker(
//           markerId: const MarkerId('marker1'),
//           position: const LatLng(45.521563, -122.677433),
//           icon: BitmapDescriptor.fromBytes(greenMarker!)),
//     };
//     setState(() {});
//   }
//
//   // Function to handle map drag
//   Future<void> _onMapDrag(LatLng newPosition) async {
//     // Perform any other actions based on the new position
//     debugPrint(
//         'New marker position: ${newPosition.latitude}, ${newPosition.longitude}');
//     _markers.clear();
//     _markers = {
//       Marker(
//           markerId: const MarkerId('marker1'),
//           position: LatLng(newPosition.latitude, newPosition.longitude),
//           icon: BitmapDescriptor.fromBytes(greenMarker!))
//     };
//
//     var resp = await ApiService()
//         .getPlaceId(newPosition.latitude, newPosition.longitude);
//     var placeId = resp['results'][0]['place_id'];
//     await ApiService()
//         .getPlaceDetailsById(placeId: placeId)
//         .then((value1) async {
//       debugPrint("location::::::::: ${value1['result']['formatted_address']}");
//       placeID = placeId;
//       hintText = value1['result']['formatted_address'];
//       fullAddressController.text = value1['result']['formatted_address'];
//       fromLocController.clear();
//       focusNode.unfocus();
//     });
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     markerImage();
//     getSavedAddresses();
//     super.initState();
//     hintText =
//         widget.locType == "pickup" ? "Pick-up location" : "Drop-off locaction";
//     // _controller.addListener(() {
//     _onChanged();
//     // });
//   }
//
//   _onChanged() {
//     if (_sessionToken == null) {
//       setState(() {
//         _sessionToken = uuid.v4();
//       });
//     }
//     // getSuggestion(_controller.text);
//   }
//
//   getSavedAddresses() async {
//     var address = await ApiService().getSavedAddress();
//     debugPrint("savedAdress:: $getSavedAddresses");
//     if (address['success']) {
//       if (address['data'].isNotEmpty) {
//         addressList = address['data'];
//       }
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final appProvider = Provider.of<AppProvider>(context, listen: false);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: lightWhiteColor,
//       body: isMap
//           ? GestureDetector(
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//               },
//               child: SafeArea(
//                   child: Padding(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Stack(
//                   children: [
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Container(
//                               height: MediaQuery.of(context).size.height * 0.51,
//                               width: MediaQuery.of(context).size.width,
//                               child: GoogleMap(
//                                 // zoomControlsEnabled: true,
//                                 markers: _markers,
//                                 onCameraMove: (CameraPosition position) async {
//                                   // Update marker position as the map is moved
//                                   _onMapDrag(position.target);
//                                   // fromLocController.text = "";
//                                 },
//                                 mapType: MapType.normal,
//                                 initialCameraPosition: _kGooglePlex,
//                                 myLocationButtonEnabled: false,
//                                 onMapCreated: (GoogleMapController controller) {
//                                   _controller.complete(controller);
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: Form(
//                                   key: _formKey,
//                                   child: Column(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             top: 10.0, bottom: 15, left: 25),
//                                         child: Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: Text(
//                                             "Address details",
//                                             style: GoogleFonts.inter(
//                                                 color: pureBlack,
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.w500),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         // height: MediaQuery.of(context).size.height *
//                                         //     0.052,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.85,
//                                         child: TextFormField(
//                                           controller: nameController,
//                                           maxLines: 1,
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (str) {
//                                             if (str!.isEmpty) {
//                                               return '';
//                                             }
//                                             return null;
//                                           },
//                                           style: GoogleFonts.inter(
//                                               color: pureBlack,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400),
//                                           decoration: InputDecoration(
//                                             errorStyle:
//                                                 const TextStyle(fontSize: 0.01),
//                                             errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               borderSide: const BorderSide(
//                                                 color: Colors.red,
//                                                 width: 1,
//                                                 style: BorderStyle.solid,
//                                               ),
//                                             ),
//                                             filled: true,
//                                             fillColor: pureWhite,
//                                             labelStyle: GoogleFonts.inter(
//                                                 color: pureBlack,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w400),
//                                             labelText: "Contact Name",
//                                             border: const OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                 color: lightWhiteColor,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 15,
//                                       ),
//                                       SizedBox(
//                                         // height: MediaQuery.of(context).size.height *
//                                         //     0.052,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.85,
//                                         child: TextFormField(
//                                           controller: phoneController,
//                                           keyboardType: TextInputType.phone,
//                                           maxLength: 10,
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (str) {
//                                             if (str!.isEmpty) {
//                                               return '';
//                                             }
//                                             return null;
//                                           },
//                                           style: GoogleFonts.inter(
//                                               color: pureBlack,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400),
//                                           decoration: InputDecoration(
//                                             counterText: "",
//                                             errorStyle:
//                                                 const TextStyle(fontSize: 0.01),
//                                             errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               borderSide: const BorderSide(
//                                                 color: Colors.red,
//                                                 width: 1,
//                                                 style: BorderStyle.solid,
//                                               ),
//                                             ),
//                                             filled: true,
//                                             fillColor: pureWhite,
//                                             labelStyle: GoogleFonts.inter(
//                                                 color: pureBlack,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w400),
//                                             labelText: "Phone Number",
//                                             border: const OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                 color: lightWhiteColor,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 15,
//                                       ),
//                                       SizedBox(
//                                         // height: MediaQuery.of(context).size.height *
//                                         //     0.052,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.85,
//                                         child: TextFormField(
//                                           maxLines: 1,
//                                           controller: fullAddressController,
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           validator: (str) {
//                                             if (str!.isEmpty) {
//                                               return '';
//                                             }
//                                             return null;
//                                           },
//                                           style: GoogleFonts.inter(
//                                               color: pureBlack,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400),
//                                           decoration: InputDecoration(
//                                             errorStyle:
//                                                 const TextStyle(fontSize: 0.01),
//                                             errorBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               borderSide: const BorderSide(
//                                                 color: Colors.red,
//                                                 width: 1,
//                                                 style: BorderStyle.solid,
//                                               ),
//                                             ),
//                                             filled: true,
//                                             fillColor: pureWhite,
//                                             labelStyle: GoogleFonts.inter(
//                                                 color: pureBlack,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w400),
//                                             labelText: "Enter Complete Address",
//                                             border: const OutlineInputBorder(
//                                               borderSide: BorderSide(
//                                                 color: lightWhiteColor,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 15.0, top: 5, bottom: 0),
//                                         child: Row(
//                                           children: [
//                                             Checkbox(
//                                                 value: isChecked,
//                                                 onChanged: (val) {
//                                                   isChecked = val!;
//                                                   setState(() {});
//                                                 }),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 5.0),
//                                               child: Text(
//                                                 "Save this address",
//                                                 style: GoogleFonts.inter(
//                                                     color: pureBlack,
//                                                     fontSize: 14,
//                                                     fontWeight:
//                                                         FontWeight.w400),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // const Spacer(),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.95,
//                               height: MediaQuery.of(context).size.height * 0.05,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20.0),
//                                 child: CustomButton(
//                                     buttonLabel: "Confirm",
//                                     backGroundColor: buttonColor,
//                                     onTap: () async {
//                                       if (_formKey.currentState!.validate()) {
//                                         if (widget.locType == 'pickup') {
//                                           await appProvider
//                                               .setPickupAddress(AddressModel(
//                                             addressString:
//                                                 fullAddressController.text,
//                                             latlng: LatLng(
//                                                 _markers
//                                                     .first.position.latitude,
//                                                 _markers
//                                                     .first.position.longitude),
//                                             placeId: placeID,
//                                             name: nameController.text,
//                                             phone: phoneController.text,
//                                           ));
//                                         } else {
//                                           await appProvider
//                                               .setDropAddress(AddressModel(
//                                             addressString:
//                                                 fullAddressController.text,
//                                             latlng: LatLng(
//                                                 _markers
//                                                     .first.position.latitude,
//                                                 _markers
//                                                     .first.position.longitude),
//                                             placeId: placeID,
//                                             name: nameController.text,
//                                             phone: phoneController.text,
//                                           ));
//                                         }
//                                         var address = {
//                                           "address": fullAddressController.text,
//                                           "location": [
//                                             _markers.first.position.latitude,
//                                             _markers.first.position.longitude
//                                           ],
//                                           "name": nameController.text,
//                                           "phone": phoneController.text,
//                                           "placeId": placeID,
//                                         };
//
//                                         if (isChecked) {
//                                           var res = await ApiService()
//                                               .saveAddress(address: address);
//                                           debugPrint("res:: $res");
//                                         }
//                                         if (context.mounted) {
//                                           Navigator.pop(context, true);
//                                         }
//                                       }
//                                     },
//                                     buttonWidth:
//                                         MediaQuery.of(context).size.width *
//                                             0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                         top: 0,
//                         left: 30,
//                         child: SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.4,
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 30.0),
//                                 child: SizedBox(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.85,
//                                   child: TypeAheadField<dynamic>(
//                                     focusNode: focusNode,
//                                     hideOnEmpty: true,
//                                     hideOnError: true,
//                                     hideOnSelect: true,
//                                     hideOnLoading: true,
//                                     controller: fromLocController,
//                                     builder: (context, controller, focusNode) =>
//                                         TextField(
//                                       controller: controller,
//                                       focusNode: focusNode,
//                                       autofocus: false,
//                                       style: GoogleFonts.inter(
//                                           color: addressTextColor,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w400),
//                                       decoration: InputDecoration(
//                                         fillColor: pureWhite,
//                                         filled: true,
//                                         prefixIcon: SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.20,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceEvenly,
//                                             children: [
//                                               InkWell(
//                                                 child: SvgPicture.asset(
//                                                     'assets/images/arrow_back.svg',
//                                                     fit: BoxFit.contain),
//                                                 onTap: () {
//                                                   Navigator.pop(context);
//                                                 },
//                                               ),
//                                               SvgPicture.asset(
//                                                   'assets/images/source_ring.svg',
//                                                   fit: BoxFit.contain),
//                                             ],
//                                           ),
//                                         ),
//                                         hintStyle: GoogleFonts.inter(
//                                             color: addressTextColor,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400),
//                                         border: const OutlineInputBorder(),
//                                         hintText: hintText,
//                                       ),
//                                     ),
//                                     decorationBuilder: (context, child) =>
//                                         Material(
//                                       type: MaterialType.card,
//                                       elevation: 4,
//                                       // borderRadius: borderRadius,
//                                       child: child,
//                                     ),
//                                     itemBuilder: (context, product) => ListTile(
//                                       title: Text(product['description']),
//                                       // subtitle: product.description != null
//                                       //     ? Text(
//                                       //         '${product.description!} - \$${product.price}',
//                                       //         maxLines: 1,
//                                       //         overflow: TextOverflow.ellipsis,
//                                       //       )
//                                       //     : Text('\$${product.price}'),
//                                     ),
//                                     onSelected: (value) async {
//                                       debugPrint(
//                                           ".........place:::${value['place_id']}");
//                                       await ApiService()
//                                           .getPlaceDetailsById(
//                                               placeId: value['place_id'])
//                                           .then((value1) async {
//                                         debugPrint(
//                                             "placeid::::::::: ${value1['result']['geometry']['location']}");
//                                         var pickedLoc = value1['result']
//                                             ['geometry']['location'];
//                                         // _controller.complete(controller);
//                                         GoogleMapController controller =
//                                             await _controller.future;
//                                         controller.animateCamera(
//                                             CameraUpdate.newLatLngZoom(
//                                                 LatLng(
//                                                   pickedLoc['lat'],
//                                                   pickedLoc['lng'],
//                                                 ),
//                                                 18));
//                                         marker.clear();
//                                         final Uint8List greenMarker =
//                                             await getBytesFromAsset(
//                                                 'assets/images/map_marker.png',
//                                                 100);
//                                         marker.add(Marker(
//                                           markerId: const MarkerId("source"),
//                                           draggable: true,
//                                           position: LatLng(
//                                             pickedLoc['lat'],
//                                             pickedLoc['lng'],
//                                           ),
//                                           // onDrag: (newPos) {
//                                           //   debugPrint(
//                                           //       "new position::::::: $newPos");
//                                           //   pickedLoc = newPos;
//                                           //   marker.clear();
//                                           //   marker.add(Marker(
//                                           //       markerId: MarkerId("source"),
//                                           //       position: LatLng(
//                                           //         pickedLoc['lat'],
//                                           //         pickedLoc['lng'],
//                                           //       )));
//                                           //   setState(() {});
//                                           // },
//                                           onDragEnd: (newPos) {
//                                             debugPrint(
//                                                 "new position::::::: $newPos");
//                                             pickedLoc = newPos;
//                                             // marker.clear();
//                                             // marker.add(Marker(
//                                             //     markerId: MarkerId("source"),
//                                             //     draggable: true,
//                                             //     position: LatLng(
//                                             //       pickedLoc['lat'],
//                                             //       pickedLoc['lng'],
//                                             //     )));
//                                             setState(() {});
//                                           },
//                                           icon: BitmapDescriptor.fromBytes(
//                                               greenMarker),
//                                         ));
//                                       });
//                                       setState(() {});
//                                     },
//                                     suggestionsCallback: (String search) async {
//                                       var response = await ApiService()
//                                           .searchPlace(
//                                               input: search,
//                                               sessionToken: _sessionToken);
//                                       return response['predictions'];
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )),
//                   ],
//                 ),
//               )),
//             )
//           : GestureDetector(
//               onTap: () {
//                 Focus.of(context).unfocus();
//               },
//               child: SafeArea(
//                   child: Stack(
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height,
//                     child: Column(
//                       children: [
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.45,
//                           width: MediaQuery.of(context).size.width,
//                           decoration: const BoxDecoration(
//                             color: primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                       child: Center(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.8,
//                       width: MediaQuery.of(context).size.width * 0.95,
//                       child: Card(
//                         color: Colors.white,
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 30.0),
//                                 child: SizedBox(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.85,
//                                   child: TypeAheadField<dynamic>(
//                                     controller: fromLocController,
//                                     builder: (context, controller, focusNode) =>
//                                         TextField(
//                                       controller: controller,
//                                       focusNode: focusNode,
//                                       onTap: () {
//                                         isMap = true;
//                                         setState(() {});
//                                       },
//                                       autofocus: false,
//                                       style: GoogleFonts.inter(
//                                           color: addressTextColor,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w400),
//                                       decoration: InputDecoration(
//                                         fillColor: pureWhite,
//                                         filled: true,
//                                         prefixIcon: SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.20,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceEvenly,
//                                             children: [
//                                               InkWell(
//                                                 child: SvgPicture.asset(
//                                                     'assets/images/arrow_back.svg',
//                                                     fit: BoxFit.contain),
//                                                 onTap: () {
//                                                   Navigator.pop(context);
//                                                 },
//                                               ),
//                                               SvgPicture.asset(
//                                                   'assets/images/source_ring.svg',
//                                                   fit: BoxFit.contain),
//                                             ],
//                                           ),
//                                         ),
//                                         hintStyle: GoogleFonts.inter(
//                                             color: addressTextColor,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400),
//                                         border: const OutlineInputBorder(),
//                                         hintText: hintText,
//                                       ),
//                                     ),
//                                     decorationBuilder: (context, child) =>
//                                         Material(
//                                       type: MaterialType.card,
//                                       elevation: 4,
//                                       // borderRadius: borderRadius,
//                                       child: child,
//                                     ),
//                                     itemBuilder: (context, product) => ListTile(
//                                       title: Text(product['description']),
//                                       // subtitle: product.description != null
//                                       //     ? Text(
//                                       //         '${product.description!} - \$${product.price}',
//                                       //         maxLines: 1,
//                                       //         overflow: TextOverflow.ellipsis,
//                                       //       )
//                                       //     : Text('\$${product.price}'),
//                                     ),
//                                     onSelected: (value) {},
//                                     suggestionsCallback: (String search) async {
//                                       var response = await ApiService()
//                                           .searchPlace(
//                                               input: search,
//                                               sessionToken: _sessionToken);
//                                       return response['predictions'];
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 20.0),
//                                 child: ExpansionTile(
//                                   initiallyExpanded: true,
//                                   shape: RoundedRectangleBorder(),
//                                   title: Text(
//                                     "Saved Addresses",
//                                     style: GoogleFonts.inter(
//                                         color: addressTextColor,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                   children: [
//                                     for (int i = 0;
//                                         i < addressList.length;
//                                         i++) ...{
//                                       ListTile(
//                                         onTap: () async {
//                                           if (widget.locType == 'pickup') {
//                                             await appProvider
//                                                 .setPickupAddress(AddressModel(
//                                               addressString: addressList[i]
//                                                   ['address'],
//                                               latlng: LatLng(
//                                                   addressList[i]['location'][0],
//                                                   addressList[i]['location']
//                                                       [1]),
//                                               placeId: addressList[i]['_id'],
//                                               name: addressList[i]['userName'],
//                                               phone: addressList[i]
//                                                   ['phoneNumber'],
//                                             ));
//                                           } else {
//                                             await appProvider
//                                                 .setDropAddress(AddressModel(
//                                               addressString: addressList[i]
//                                                   ['address'],
//                                               latlng: LatLng(
//                                                   addressList[i]['location'][0],
//                                                   addressList[i]['location']
//                                                       [1]),
//                                               placeId: addressList[i]['_id'],
//                                               name: addressList[i]['userName'],
//                                               phone: addressList[i]
//                                                   ['phoneNumber'],
//                                             ));
//                                           }
//
//                                           if (context.mounted) {
//                                             Navigator.pop(context, true);
//                                           }
//                                         },
//                                         leading: const Padding(
//                                           padding: EdgeInsets.only(right: 8.0),
//                                           child: Icon(
//                                             Icons.bookmark,
//                                             color: addressTextColor,
//                                             size: 20,
//                                           ),
//                                         ),
//                                         // title: Text(
//                                         //   addressList[i]['nickName'],
//                                         //   style: GoogleFonts.inter(
//                                         //       color: addressTextColor,
//                                         //       fontSize: 16,
//                                         //       fontWeight: FontWeight.w500),
//                                         // ),
//                                         title: Text(
//                                           addressList[i]['address'],
//                                           style: GoogleFonts.inter(
//                                               color: addressTextColor,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                         trailing: PopupMenuButton<int>(
//                                           itemBuilder: (context) => [
//                                             // PopupMenuItem 1
//                                             PopupMenuItem(
//                                                 value: 1,
//                                                 padding: EdgeInsets.zero,
//                                                 height: 20,
//                                                 onTap: () async {
//                                                   await ApiService()
//                                                       .deleteAddress(
//                                                           addressList[i]['_id'])
//                                                       .then((value) async {
//                                                     if (value['success']) {
//                                                       addressList.clear();
//                                                       var address =
//                                                           await ApiService()
//                                                               .getSavedAddress();
//                                                       debugPrint(
//                                                           "savedAdress:: $getSavedAddresses");
//                                                       if (address['success']) {
//                                                         if (address['data']
//                                                             .isNotEmpty) {
//                                                           addressList =
//                                                               address['data'];
//                                                         }
//                                                       }
//                                                       setState(() {});
//                                                     } else {
//                                                       notificationService
//                                                           .showToast(context,
//                                                               value["message"],
//                                                               type:
//                                                                   NotificationType
//                                                                       .error);
//                                                     }
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   width: MediaQuery.of(context)
//                                                           .size
//                                                           .width *
//                                                       0.2,
//                                                   padding:
//                                                       const EdgeInsets.all(5),
//                                                   decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                           color: Colors.grey)),
//                                                   child: Text(
//                                                     "Delete",
//                                                     textAlign: TextAlign.center,
//                                                     style: GoogleFonts.inter(
//                                                         color: Colors.green,
//                                                         fontSize: 12,
//                                                         fontWeight:
//                                                             FontWeight.w400),
//                                                   ),
//                                                 )),
//                                             PopupMenuItem(
//                                               value: 2,
//                                               padding: EdgeInsets.zero,
//                                               height: 20,
//                                               onTap: () {},
//                                               child: Container(
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width *
//                                                     0.2,
//                                                 padding:
//                                                     const EdgeInsets.all(5),
//                                                 decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color: Colors.grey)),
//                                                 child: Text(
//                                                   "Edit",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.inter(
//                                                       color: Colors.green,
//                                                       fontSize: 12,
//                                                       fontWeight:
//                                                           FontWeight.w400),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                           surfaceTintColor: Colors.transparent,
//                                           shadowColor: Colors.transparent,
//                                           padding: EdgeInsets.zero,
//                                           constraints: BoxConstraints(
//                                             maxWidth: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.2,
//                                           ),
//                                           position: PopupMenuPosition.under,
//                                           icon: const Icon(
//                                             Icons.more_vert,
//                                             color: addressTextColor,
//                                             size: 24,
//                                           ),
//                                           splashRadius: 15,
//                                           // offset: const Offset(0, 0),
//                                           elevation: 0,
//                                           // on selected we show the dialog box
//                                           onSelected: (value) {
//                                             // if value 1 show dialog
//                                             // if (value == 1) {
//                                             //   _showDialog(context);
//                                             //   // if value 2 show dialog
//                                             // } else if (value == 2) {
//                                             //   _showDialog(context);
//                                             // }
//                                           },
//                                         ),
//                                       )
//                                     }
//                                   ],
//                                 ),
//                               ),
//                               /* InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                       context,
//                                       (MaterialPageRoute(
//                                           builder: (context) =>
//                                               const SavedAddressPage())));
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 30.0),
//                                   child: Container(
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.85,
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey),
//                                         borderRadius: BorderRadius.circular(5)),
//                                     child: Row(
//                                       children: [
//                                         const Padding(
//                                           padding: EdgeInsets.only(right: 8.0),
//                                           child: Icon(
//                                             Icons.bookmark,
//                                             color: addressTextColor,
//                                             size: 20,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Saved Addresses",
//                                           style: GoogleFonts.inter(
//                                               color: addressTextColor,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                         const Spacer(),
//                                         const Icon(
//                                           Icons.arrow_forward_ios_sharp,
//                                           color: addressTextColor,
//                                           size: 20,
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               )*/
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ))
//                 ],
//               )),
//             ),
//     );
//   }
// }
