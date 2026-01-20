import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_colors.dart';

class OpportunityMapScreen extends StatefulWidget {
  const OpportunityMapScreen({super.key});

  @override
  State<OpportunityMapScreen> createState() => _OpportunityMapScreenState();
}

class _OpportunityMapScreenState extends State<OpportunityMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  bool _showInfoCard = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(12.9716, 77.6412), // Focused on Indiranagar
    zoom: 14.5,
  );

  final List<Map<String, dynamic>> _searchableZones = [
    {
      'name': 'Indiranagar',
      'location': const LatLng(12.9716, 77.6412),
      'zoom': 14.5,
    },
    {
      'name': 'Koramangala',
      'location': const LatLng(12.9279, 77.6271),
      'zoom': 14.5,
    },
    {
      'name': 'HSR Layout',
      'location': const LatLng(12.9141, 77.6411),
      'zoom': 14.5,
    },
    {
      'name': 'Whitefield',
      'location': const LatLng(12.9698, 77.7499),
      'zoom': 14.5,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _moveCamera(LatLng location, double zoom) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  Future<void> _reCenterMap() async {
    _moveCamera(_initialPosition.target, _initialPosition.zoom);
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    final zone = _searchableZones.firstWhere(
      (z) => z['name'].toString().toLowerCase().contains(query.toLowerCase()),
      orElse: () => {},
    );

    if (zone.isNotEmpty) {
      _moveCamera(zone['location'] as LatLng, zone['zoom'] as double);
      setState(() => _showInfoCard = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No high demand zone found for "$query"')),
      );
    }
  }

  final Set<Circle> _hotZones = {
    Circle(
      circleId: const CircleId('indiranagar'),
      center: const LatLng(12.9716, 77.6412),
      radius: 1000,
      fillColor: Colors.red.withValues(alpha: 0.2),
      strokeColor: Colors.red,
      strokeWidth: 1,
    ),
    Circle(
      circleId: const CircleId('koramangala'),
      center: const LatLng(12.9279, 77.6271),
      radius: 800,
      fillColor: Colors.orange.withValues(alpha: 0.2),
      strokeColor: Colors.orange,
      strokeWidth: 1,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, paddingScale, titleFontSize),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: _initialPosition,
                      circles: _hotZones,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                    ),
                  ),
                ),
              ],
            ),
            _buildLegend(paddingScale, smallFontSize),
            _buildSearchOverlay(paddingScale, bodyFontSize),
            if (_showInfoCard)
              _buildBottomCard(paddingScale, bodyFontSize, smallFontSize),
            if (!_showInfoCard)
              Positioned(
                bottom:
                    MediaQuery.of(context).padding.bottom + (16 * paddingScale),
                right: 16 * paddingScale,
                child: FloatingActionButton(
                  onPressed: () => setState(() => _showInfoCard = true),
                  backgroundColor: const Color(0xFF0A192F),
                  mini: screenWidth < 360,
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: (24 * paddingScale).clamp(20.0, 28.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double paddingScale,
    double titleFontSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (10 * paddingScale),
        left: 10 * paddingScale,
        right: 10 * paddingScale,
        bottom: 15 * paddingScale,
      ),
      decoration: const BoxDecoration(color: Color(0xFF0A192F)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: (20 * paddingScale).clamp(18.0, 24.0),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              'Opportunity Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _reCenterMap,
            icon: Icon(
              Icons.my_location,
              color: Colors.white,
              size: (24 * paddingScale).clamp(20.0, 28.0),
            ),
            tooltip: 'Re-center',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(double paddingScale, double bodyFontSize) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + (70 * paddingScale),
      left: 16 * paddingScale,
      right: 16 * paddingScale,
      child: Container(
        height: (50 * paddingScale).clamp(45.0, 60.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _handleSearch,
          style: TextStyle(fontSize: bodyFontSize),
          decoration: InputDecoration(
            hintText: 'Search high demand zones (e.g. Whitefield)',
            hintStyle: TextStyle(color: Colors.grey, fontSize: bodyFontSize),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: (20 * paddingScale).clamp(18.0, 24.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey,
                size: (20 * paddingScale).clamp(18.0, 24.0),
              ),
              onPressed: () => _searchController.clear(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(double paddingScale, double smallFontSize) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + (140 * paddingScale),
      right: 16 * paddingScale,
      child: Container(
        padding: EdgeInsets.all(12 * paddingScale),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(
              'Very High Demand',
              const Color(0xFFEF4444),
              paddingScale,
              smallFontSize,
            ),
            SizedBox(height: 10 * paddingScale),
            _buildLegendItem(
              'High Demand',
              const Color(0xFFF59E0B),
              paddingScale,
              smallFontSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    double paddingScale,
    double smallFontSize,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10 * paddingScale,
          height: 10 * paddingScale,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: 10 * paddingScale),
        Text(
          label,
          style: TextStyle(
            fontSize: smallFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A192F),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCard(
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + (16 * paddingScale),
      left: 16 * paddingScale,
      right: 16 * paddingScale,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A192F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24 * paddingScale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * paddingScale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      color: const Color(0xFFF59E0B),
                      size: (20 * paddingScale).clamp(18.0, 24.0),
                    ),
                  ),
                  SizedBox(width: 16 * paddingScale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Indiranagar is Booming',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: bodyFontSize + 4,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '20% higher earnings right now',
                          style: TextStyle(
                            color: const Color(0xFF34D399),
                            fontSize: smallFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showInfoCard = false),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: (20 * paddingScale).clamp(18.0, 24.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * paddingScale),
              Text(
                'Partners in this zone are waiting less than 3 minutes for new job requests.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: bodyFontSize,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24 * paddingScale),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting navigation to Indiranagar...'),
                      backgroundColor: Color(0xFF34D399),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrangeStart,
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    double.infinity,
                    (50 * paddingScale).clamp(45.0, 60.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Navigate to Zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFontSize + 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
