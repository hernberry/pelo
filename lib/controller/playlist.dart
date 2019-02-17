import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../model/services/peloton/types.dart';
import '../model/workout.dart';
import '../model/services/peloton/client.dart';

import './playlist_state.dart';

class VideoCons {
  PelotonRide ride;
  VideoCons next;

  VideoCons(this.ride, this.next);
}

class PlaylistController extends ChangeNotifier {
  final Playlist playlist;
  final PelotonClient client;
  VideoPlayerController _playerController;

  PlaylistState _playlistState;

  PlaylistController(this.playlist, this.client);

  PlaylistState get playlistState => _playlistState;
  VideoPlayerController get playerController => _playerController;

  Duration _videoRemainig;
  Duration get currentVideoRemaining {
    if (_playlistState == PlaylistState.initilaizing ||
    _playlistState == PlaylistState.ended) {
      return null;
    }
    return _videoRemainig;
  }

  VideoCons _buildCons(Iterator<RideInfo> infoIt) {
    if (infoIt.current == null) {
      return null;
    }
    PelotonRide ride = infoIt.current.ride;
    infoIt.moveNext();
    return VideoCons(ride, _buildCons(infoIt));
  }

  Future<void> initialize() async {
    _playlistState = PlaylistState.initilaizing;
    VideoCons cons = _buildCons(playlist.rides.iterator..moveNext());
    _initVideo(cons);
  }

  var _listener;

  Future<void> _initVideo(VideoCons cons) async {
    if (_playerController != null) {
      _playerController.removeListener(_listener);
      _playerController.pause();
    }
    if (cons == null) {
      _playlistState = PlaylistState.ended;
      notifyListeners();
      return;
    }
    PelotonRide r = cons.ride;
    Duration videoCutoff = Duration(
        seconds: cons.next == null ? r.totalDuration : r.pedalingDuration + 25);
    String videoUrl = await client.getRideVideoUrl(r);

    _playerController = VideoPlayerController.network(videoUrl);
    bool listening = true;
    _listener = () {
      _videoRemainig = videoCutoff - _playerController.value.position;
      if (listening && _playerController.value.position >= videoCutoff) {
        listening = false;
        _initVideo(cons.next);
      }
      notifyListeners();
    };
    _playerController
      ..addListener(_listener)
      ..initialize().then((_) {
        if (playlistState == PlaylistState.playing) {
          _playerController.play();
        }
        notifyListeners();
      });
    notifyListeners();
  }

  void play() {
    if (_playlistState == PlaylistState.ended) {
      return;
    }
    if (_playerController != null) {
      _playerController.play();
      _playlistState = PlaylistState.playing;
    }
  }

  void pause() {
    if (_playlistState == PlaylistState.ended) {
      return;
    }
    if (_playerController != null) {
      _playerController.pause();
      _playlistState = PlaylistState.paused;
    }
  }
}
