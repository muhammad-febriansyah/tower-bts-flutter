import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteMapPage extends StatefulWidget {
  final String siteName;
  final String address;
  final double latitude;
  final double longitude;

  const SiteMapPage({
    super.key,
    required this.siteName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<SiteMapPage> createState() => _SiteMapPageState();
}

class _SiteMapPageState extends State<SiteMapPage> {
  final MapController _mapController = MapController();

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  Future<void> _openWaze() async {
    final url = Uri.parse(
      'https://waze.com/ul?ll=${widget.latitude},${widget.longitude}&navigate=yes',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Waze')),
      );
    }
  }

  void _showNavigationOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pilih Aplikasi Navigasi',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Iconsax.map_1, color: const Color(0xFF2E7D32), size: 28.sp),
                  title: Text(
                    'Google Maps',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    'Buka dengan Google Maps',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openGoogleMaps();
                  },
                ),
                ListTile(
                  leading: Icon(Iconsax.routing, color: Colors.blue, size: 28.sp),
                  title: Text(
                    'Waze',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    'Buka dengan Waze',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openWaze();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Site'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.gps),
            onPressed: () {
              _mapController.move(
                LatLng(widget.latitude, widget.longitude),
                15,
              );
            },
            tooltip: 'Pusatkan Peta',
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tower_bts',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 80.w,
                    height: 80.h,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            widget.siteName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Iconsax.location,
                          color: const Color(0xFF2E7D32),
                          size: 40.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Site Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.setting_4,
                        color: const Color(0xFF2E7D32),
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.siteName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        color: Colors.grey.shade600,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          widget.address,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.gps,
                        color: Colors.grey.shade600,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: _showNavigationOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Iconsax.routing_2, size: 20.sp),
                    label: Text(
                      'Navigasi ke Lokasi',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map Type Toggle
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Iconsax.add, size: 24.sp),
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    tooltip: 'Zoom In',
                  ),
                  Divider(height: 1.h),
                  IconButton(
                    icon: Icon(Iconsax.minus, size: 24.sp),
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    tooltip: 'Zoom Out',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
