import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_constants.dart';
import '../../models/place_model.dart' as model;
import '../../providers/content_filter_provider.dart';
import '../../providers/place_verification_provider.dart';
import '../../services/place_service.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/place_verification_sheet.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  final PlaceService _service = PlaceService();
  Future<model.Place>? _future;
  late String _currentProjectId;

  @override
  void initState() {
    super.initState();
    final initialProject =
        ref.read(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
    _currentProjectId = initialProject;
    _future = _load(initialProject);
    ref.listen<String?>(selectedProjectProvider, (previous, next) {
      final target = next ?? ApiConstants.defaultProjectId;
      if (target == _currentProjectId) return;
      setState(() {
        _currentProjectId = target;
        _future = _load(target);
      });
      ref
          .read(placeVerificationControllerProvider(widget.placeId).notifier)
          .reset();
    });
  }

  Future<model.Place> _load(String projectId) async {
    return _service.getPlaceDetail(
      projectId: projectId,
      placeId: widget.placeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationState =
        ref.watch(placeVerificationControllerProvider(widget.placeId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<model.Place>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _DetailErrorView(
                  message: '성지 정보를 불러올 수 없습니다.',
                  onRetry: () {
                    setState(() {
                      _future = _load(_currentProjectId);
                    });
                  },
                );
              }
              final place = snapshot.data!;
              return RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () async {
                  setState(() {
                    _future = _load(_currentProjectId);
                  });
                  await _future;
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    _PlaceHeroCard(place: place),
                    const SizedBox(height: 20),
                    FlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FlowSectionHeader(
                            title: '장소 소개',
                            subtitle: '성지의 기본 정보를 확인하세요',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            place.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          _MetaRow(
                            icon: Icons.place_outlined,
                            label: '좌표',
                            value:
                                '위도 ${place.latitude.toStringAsFixed(5)}, 경도 ${place.longitude.toStringAsFixed(5)}',
                          ),
                          if (place.address != null && place.address!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _MetaRow(
                                icon: Icons.map_outlined,
                                label: '주소',
                                value: place.address!,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FlowSectionHeader(
                            title: '장소 인증',
                            subtitle: '현 위치를 이용해 방문을 인증합니다',
                          ),
                          const SizedBox(height: 16),
                          if (verificationState.status ==
                                  PlaceVerificationStatus.success &&
                              verificationState.verifiedAt != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '최근에 인증되었습니다',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          verificationState.message ??
                                              '방문 인증이 완료되었습니다.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: verificationState.isLoading
                                ? null
                                : () {
                                    showPlaceVerificationSheet(
                                      context: context,
                                      placeId: widget.placeId,
                                      placeName: place.name,
                                      placeLat: place.latitude,
                                      placeLon: place.longitude,
                                      projectId: _currentProjectId,
                                    );
                                  },
                            icon: const Icon(Icons.my_location_rounded),
                            label: Text(
                              verificationState.isLoading
                                  ? '위치 측정 중...'
                                  : '현 위치로 인증하기',
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/pilgrimage'),
                            icon: const Icon(Icons.map_rounded),
                            label: const Text('성지 목록으로 이동'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlaceHeroCard extends StatelessWidget {
  const _PlaceHeroCard({required this.place});

  final model.Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FlowCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowPill(
            label: _typeLabel(place.type),
            leading: Icon(
              _typeIcon(place.type),
              size: 16,
              color: theme.colorScheme.primary,
            ),
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 18),
          Text(
            place.name,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '밴드 여정 속의 핵심 성지',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(model.PlaceType type) {
    switch (type) {
      case model.PlaceType.concertVenue:
        return Icons.mic_external_on_rounded;
      case model.PlaceType.cafeCollaboration:
        return Icons.local_cafe_rounded;
      case model.PlaceType.animeLocation:
        return Icons.movie_outlined;
      case model.PlaceType.characterShop:
        return Icons.storefront_rounded;
      case model.PlaceType.other:
        return Icons.location_city_rounded;
    }
  }

  String _typeLabel(model.PlaceType type) {
    switch (type) {
      case model.PlaceType.concertVenue:
        return '라이브 하우스';
      case model.PlaceType.cafeCollaboration:
        return '콜라보 카페';
      case model.PlaceType.animeLocation:
        return '작중 장소';
      case model.PlaceType.characterShop:
        return '샵 & 굿즈';
      case model.PlaceType.other:
        return '기타 장소';
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
