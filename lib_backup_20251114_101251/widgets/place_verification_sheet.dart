import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/place_verification_provider.dart';
import 'flow_components.dart';

Future<void> showPlaceVerificationSheet({
  required BuildContext context,
  required String placeId,
  required String placeName,
  required double placeLat,
  required double placeLon,
  required String projectId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _PlaceVerificationSheet(
        placeId: placeId,
        placeName: placeName,
        placeLat: placeLat,
        placeLon: placeLon,
        projectId: projectId,
      );
    },
  );
}

class _PlaceVerificationSheet extends ConsumerStatefulWidget {
  const _PlaceVerificationSheet({
    required this.placeId,
    required this.placeName,
    required this.placeLat,
    required this.placeLon,
    required this.projectId,
  });

  final String placeId;
  final String placeName;
  final double placeLat;
  final double placeLon;
  final String projectId;

  @override
  ConsumerState<_PlaceVerificationSheet> createState() =>
      _PlaceVerificationSheetState();
}

class _PlaceVerificationSheetState
    extends ConsumerState<_PlaceVerificationSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_startVerificationIfNeeded);
  }

  void _startVerificationIfNeeded() {
    final controller = ref
        .read(placeVerificationControllerProvider(widget.placeId).notifier);
    final state = ref.read(placeVerificationControllerProvider(widget.placeId));
    if (!state.isLoading && state.status != PlaceVerificationStatus.success) {
      controller.verify(
        projectId: widget.projectId,
        placeLat: widget.placeLat,
        placeLon: widget.placeLon,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      placeVerificationControllerProvider(widget.placeId),
    );
    final theme = Theme.of(context);
    final isSuccess = state.status == PlaceVerificationStatus.success;
    final isError = state.status == PlaceVerificationStatus.error;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장소 인증',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.placeName,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FlowCard(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusRow(state: state),
                const SizedBox(height: 16),
                if (state.accuracyM != null)
                  Text(
                    '측정된 정확도: 약 ${state.accuracyM!.toStringAsFixed(1)} m',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (state.distanceM != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '성지 기준 거리: ${state.distanceM!.toStringAsFixed(1)} m',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                if (state.message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.message!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!state.isLoading) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(placeVerificationControllerProvider(widget.placeId)
                              .notifier)
                          .verify(
                            projectId: widget.projectId,
                            placeLat: widget.placeLat,
                            placeLon: widget.placeLon,
                          );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('다시 시도'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  icon: Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : isError
                            ? Icons.highlight_off_rounded
                            : Icons.close_rounded,
                  ),
                  label: Text(isSuccess
                      ? '완료'
                      : isError
                          ? '닫기'
                          : '취소'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.state});

  final PlaceVerificationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    String label;

    switch (state.status) {
      case PlaceVerificationStatus.idle:
        icon = Icons.play_circle_outline;
        color = theme.colorScheme.primary;
        label = '인증을 시작할 준비가 되었습니다.';
        break;
      case PlaceVerificationStatus.requestingPermission:
        icon = Icons.lock_open_rounded;
        color = theme.colorScheme.primary;
        label = '위치 권한을 확인하는 중입니다...';
        break;
      case PlaceVerificationStatus.acquiringLocation:
        icon = Icons.my_location_rounded;
        color = theme.colorScheme.secondary;
        label = '정확한 위치를 측정하고 있습니다.';
        break;
      case PlaceVerificationStatus.buildingPayload:
        icon = Icons.vpn_key_rounded;
        color = theme.colorScheme.secondary;
        label = '보안 토큰을 생성하는 중입니다.';
        break;
      case PlaceVerificationStatus.verifying:
        icon = Icons.verified_user_rounded;
        color = theme.colorScheme.primary;
        label = '서버에서 인증을 검증하고 있습니다.';
        break;
      case PlaceVerificationStatus.success:
        icon = Icons.verified_rounded;
        color = theme.colorScheme.primary;
        label = '장소 인증이 완료되었습니다!';
        break;
      case PlaceVerificationStatus.error:
        icon = Icons.error_outline_rounded;
        color = theme.colorScheme.error;
        label = '인증에 실패했습니다.';
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (state.isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(icon, color: color),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium,
              ),
              if (state.verifiedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '인증 시각: ${state.verifiedAt}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
