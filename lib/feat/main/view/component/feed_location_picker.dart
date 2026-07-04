import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Result of picking the shoot location for a feed post: where the photo was
/// taken, not the uploader's device location.
class FeedLocationPickerResult {
  const FeedLocationPickerResult({required this.position, this.label});

  final LatLng position;
  final String? label;
}

Future<FeedLocationPickerResult?> showFeedLocationPicker(
  BuildContext context, {
  LatLng? initial,
}) {
  return showDialog<FeedLocationPickerResult>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _FeedLocationPickerDialog(initial: initial),
  );
}

class _FeedLocationPickerDialog extends StatefulWidget {
  const _FeedLocationPickerDialog({this.initial});

  final LatLng? initial;

  @override
  State<_FeedLocationPickerDialog> createState() =>
      _FeedLocationPickerDialogState();
}

class _FeedLocationPickerDialogState
    extends State<_FeedLocationPickerDialog> {
  static const LatLng _koreaCenter = LatLng(36.35, 127.85);
  static const Color _navy = Color(0xFF16305E);
  static const Color _muted = Color(0xFF6B7684);
  static const Color _line = Color(0xFFE1E6EC);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _picked;
  String? _pickedLabel;
  bool _resolvingLabel = false;
  int _pickToken = 0;
  bool _searching = false;
  List<_GeocodeResult> _results = const <_GeocodeResult>[];
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
      _results = const <_GeocodeResult>[];
    });
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'json',
        'limit': '6',
        'countrycodes': 'kr',
        'accept-language': 'ko',
        'q': query,
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'ModuDroneApp/1.0 (contact: support@modedrone.kr)',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('검색 요청이 실패했습니다.');
      }
      final decoded = jsonDecode(response.body) as List<dynamic>;
      final results =
          decoded
              .map((e) => _GeocodeResult.fromJson(e as Map<String, dynamic>))
              .toList();
      if (!mounted) return;
      setState(() {
        _results = results;
        _searchError = results.isEmpty ? '검색 결과가 없습니다.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchError = '검색 중 문제가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectResult(_GeocodeResult result) {
    _pickToken++;
    setState(() {
      _picked = result.position;
      _pickedLabel = result.label;
      _resolvingLabel = false;
      _results = const <_GeocodeResult>[];
      _searchController.text = result.label;
    });
    _mapController.move(result.position, 13);
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    final token = ++_pickToken;
    setState(() {
      _picked = point;
      _pickedLabel = null;
      _resolvingLabel = true;
    });
    _reverseGeocode(point).then((label) {
      if (!mounted || token != _pickToken) return;
      setState(() {
        _pickedLabel = label;
        _resolvingLabel = false;
      });
    });
  }

  Future<String?> _reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'accept-language': 'ko',
        'zoom': '16',
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'ModuDroneApp/1.0 (contact: support@modedrone.kr)',
            },
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final name = decoded['display_name']?.toString();
      return (name == null || name.isEmpty) ? null : name;
    } catch (_) {
      return null;
    }
  }

  String _coordinateLabel(LatLng point) =>
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: size.height * 0.86),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      '촬영 위치 선택',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                '지도를 탭해 위치를 지정하거나, 장소명을 검색해서 선택하세요.',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '예: 해운대 해수욕장, 성산일출봉',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFD),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _line),
                        ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _searching ? null : _search,
                    style: FilledButton.styleFrom(backgroundColor: _navy),
                    child:
                        _searching
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('검색'),
                  ),
                ],
              ),
              if (_searchError != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  _searchError!,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ],
              if (_results.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.place_outlined, size: 18),
                        title: Text(
                          result.label,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 340,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: <Widget>[
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _picked ?? _koreaCenter,
                          initialZoom: _picked != null ? 13 : 6.5,
                          minZoom: 5,
                          maxZoom: 18,
                          onTap: _handleTap,
                        ),
                        children: <Widget>[
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.modu.drame',
                          ),
                          if (_picked != null)
                            MarkerLayer(
                              markers: <Marker>[
                                Marker(
                                  point: _picked!,
                                  width: 46,
                                  height: 46,
                                  alignment: Alignment.center,
                                  child: const _PickedLocationMarker(),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            child: Text(
                              '© OpenStreetMap contributors',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _picked == null
                    ? '아직 위치가 선택되지 않았습니다.'
                    : _resolvingLabel
                    ? '선택됨: ${_coordinateLabel(_picked!)} (주소 확인 중…)'
                    : '선택됨: ${_pickedLabel ?? _coordinateLabel(_picked!)}',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _picked == null
                            ? null
                            : () => Navigator.of(context).pop(
                              FeedLocationPickerResult(
                                position: _picked!,
                                label: _pickedLabel ?? _coordinateLabel(_picked!),
                              ),
                            ),
                    style: FilledButton.styleFrom(backgroundColor: _navy),
                    child: const Text('이 위치로 선택'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickedLocationMarker extends StatelessWidget {
  const _PickedLocationMarker();

  static const Color _selected = Color(0xFF05B169);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _selected,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x330A0B0D), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 26),
    );
  }
}

class _GeocodeResult {
  const _GeocodeResult({required this.position, required this.label});

  factory _GeocodeResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0;
    return _GeocodeResult(
      position: LatLng(lat, lon),
      label: (json['display_name'] ?? '').toString(),
    );
  }

  final LatLng position;
  final String label;
}
