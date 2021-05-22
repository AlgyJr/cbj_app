import 'package:cybear_jinni/application/lights/lights_watcher/lights_watcher_bloc.dart';
import 'package:cybear_jinni/domain/devices/device_entity.dart';
import 'package:cybear_jinni/presentation/core/theme_data.dart';
import 'package:cybear_jinni/presentation/lights/widgets/critical_light_failure_display_widget.dart';
import 'package:cybear_jinni/presentation/lights/widgets/room_lights.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/kt.dart';

class RoomsLightsWidget extends StatelessWidget {
  RoomsLightsWidget(this.showDevicesOnlyFromRoomId, this.roomColorGradiant);

  /// If not null show lights only from this room
  final String showDevicesOnlyFromRoomId;

  final List<Color> roomColorGradiant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LightsWatcherBloc, LightsWatcherState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => Container(),
          loadInProgress: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          loadSuccess: (state) {
            if (state.devices.size != 0) {
              final List<Color> _gradientColor = GradientColors.sky;
              final Map<String, List<DeviceEntity>> tempDevicesByRooms =
                  <String, List<DeviceEntity>>{};

              for (int i = 0; i < state.devices.size; i++) {
                final DeviceEntity tempDevice = state.devices[i];
                if (showDevicesOnlyFromRoomId != null) {
                  if (showDevicesOnlyFromRoomId ==
                      tempDevice.roomId.getOrCrash()) {
                    if (tempDevicesByRooms[tempDevice.roomId.getOrCrash()] ==
                        null) {
                      tempDevicesByRooms[tempDevice.roomId.getOrCrash()] = [
                        tempDevice
                      ];
                    } else {
                      tempDevicesByRooms[tempDevice.roomId.getOrCrash()]
                          .add(tempDevice);
                    }
                  }
                } else {
                  if (tempDevicesByRooms[tempDevice.roomId.getOrCrash()] ==
                      null) {
                    tempDevicesByRooms[tempDevice.roomId.getOrCrash()] = [
                      tempDevice
                    ];
                  } else {
                    tempDevicesByRooms[tempDevice.roomId.getOrCrash()]
                        .add(tempDevice);
                  }
                }
              }

              final List<KtList<DeviceEntity>> devicesByRooms = [];

              tempDevicesByRooms.forEach((k, v) {
                devicesByRooms.add(v.toImmutableList());
              });

              int gradientColorCounter = -1;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    gradientColorCounter++;
                    List<Color> gradiantColor;
                    if (roomColorGradiant != null) {
                      gradiantColor = roomColorGradiant;
                    } else if (gradientColorCounter >
                        gradientColorsList.length - 1) {
                      gradientColorCounter = 0;
                      gradiantColor = gradientColorsList[gradientColorCounter];
                    }
                    final devicesInRoom = devicesByRooms[index];

                    return RoomLights(
                      devicesInRoom,
                      gradiantColor,
                      'Room ${index + 1}',
                      maxLightsToShow: 50,
                    );
                  },
                  itemCount: devicesByRooms.length,
                ),
              );
            } else {
              return Expanded(
                  child: FlatButton(
                onPressed: () {},
                color: Colors.black,
                child: const Text(
                    'No lights have been found.\nPlease add new light'),
              ));
            }
          },
          loadFailure: (state) {
            return CriticalLightFailureDisplay(
              failure: state.devicesFailure,
            );
          },
          lightError: (LightError value) {
            return const Text('Error');
          },
        );
      },
    );
  }
}
