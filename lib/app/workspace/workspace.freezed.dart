// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceModel implements DiagnosticableTreeMixin {

 String get baseUrl; WorkspaceConnectionStatus get connectionStatus; WorkspaceStreamStatus get streamStatus; List<PiSessionModel> get sessions; String? get selectedSessionId; List<PiMessageModel> get messages; bool get sessionsLoading; bool get conversationLoading; bool get creatingSession; bool get sending; bool get streaming; String? get error; String? get statusMessage;
/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceModelCopyWith<WorkspaceModel> get copyWith => _$WorkspaceModelCopyWithImpl<WorkspaceModel>(this as WorkspaceModel, _$identity);

  /// Serializes this WorkspaceModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkspaceModel'))
    ..add(DiagnosticsProperty('baseUrl', baseUrl))..add(DiagnosticsProperty('connectionStatus', connectionStatus))..add(DiagnosticsProperty('streamStatus', streamStatus))..add(DiagnosticsProperty('sessions', sessions))..add(DiagnosticsProperty('selectedSessionId', selectedSessionId))..add(DiagnosticsProperty('messages', messages))..add(DiagnosticsProperty('sessionsLoading', sessionsLoading))..add(DiagnosticsProperty('conversationLoading', conversationLoading))..add(DiagnosticsProperty('creatingSession', creatingSession))..add(DiagnosticsProperty('sending', sending))..add(DiagnosticsProperty('streaming', streaming))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('statusMessage', statusMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceModel&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.streamStatus, streamStatus) || other.streamStatus == streamStatus)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.streaming, streaming) || other.streaming == streaming)&&(identical(other.error, error) || other.error == error)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseUrl,connectionStatus,streamStatus,const DeepCollectionEquality().hash(sessions),selectedSessionId,const DeepCollectionEquality().hash(messages),sessionsLoading,conversationLoading,creatingSession,sending,streaming,error,statusMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkspaceModel(baseUrl: $baseUrl, connectionStatus: $connectionStatus, streamStatus: $streamStatus, sessions: $sessions, selectedSessionId: $selectedSessionId, messages: $messages, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sending: $sending, streaming: $streaming, error: $error, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class $WorkspaceModelCopyWith<$Res>  {
  factory $WorkspaceModelCopyWith(WorkspaceModel value, $Res Function(WorkspaceModel) _then) = _$WorkspaceModelCopyWithImpl;
@useResult
$Res call({
 String baseUrl, WorkspaceConnectionStatus connectionStatus, WorkspaceStreamStatus streamStatus, List<PiSessionModel> sessions, String? selectedSessionId, List<PiMessageModel> messages, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sending, bool streaming, String? error, String? statusMessage
});




}
/// @nodoc
class _$WorkspaceModelCopyWithImpl<$Res>
    implements $WorkspaceModelCopyWith<$Res> {
  _$WorkspaceModelCopyWithImpl(this._self, this._then);

  final WorkspaceModel _self;
  final $Res Function(WorkspaceModel) _then;

/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseUrl = null,Object? connectionStatus = null,Object? streamStatus = null,Object? sessions = null,Object? selectedSessionId = freezed,Object? messages = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sending = null,Object? streaming = null,Object? error = freezed,Object? statusMessage = freezed,}) {
  return _then(_self.copyWith(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceConnectionStatus,streamStatus: null == streamStatus ? _self.streamStatus : streamStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceStreamStatus,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionModel>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as String?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessageModel>,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceModel].
extension WorkspaceModelPatterns on WorkspaceModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String baseUrl,  WorkspaceConnectionStatus connectionStatus,  WorkspaceStreamStatus streamStatus,  List<PiSessionModel> sessions,  String? selectedSessionId,  List<PiMessageModel> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool streaming,  String? error,  String? statusMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.baseUrl,_that.connectionStatus,_that.streamStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.streaming,_that.error,_that.statusMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String baseUrl,  WorkspaceConnectionStatus connectionStatus,  WorkspaceStreamStatus streamStatus,  List<PiSessionModel> sessions,  String? selectedSessionId,  List<PiMessageModel> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool streaming,  String? error,  String? statusMessage)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel():
return $default(_that.baseUrl,_that.connectionStatus,_that.streamStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.streaming,_that.error,_that.statusMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String baseUrl,  WorkspaceConnectionStatus connectionStatus,  WorkspaceStreamStatus streamStatus,  List<PiSessionModel> sessions,  String? selectedSessionId,  List<PiMessageModel> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool streaming,  String? error,  String? statusMessage)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.baseUrl,_that.connectionStatus,_that.streamStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.streaming,_that.error,_that.statusMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _WorkspaceModel with DiagnosticableTreeMixin implements WorkspaceModel {
  const _WorkspaceModel({this.baseUrl = 'http://127.0.0.1:30141', this.connectionStatus = WorkspaceConnectionStatus.disconnected, this.streamStatus = WorkspaceStreamStatus.idle, final  List<PiSessionModel> sessions = const <PiSessionModel>[], this.selectedSessionId, final  List<PiMessageModel> messages = const <PiMessageModel>[], this.sessionsLoading = false, this.conversationLoading = false, this.creatingSession = false, this.sending = false, this.streaming = false, this.error, this.statusMessage}): _sessions = sessions,_messages = messages;


@override@JsonKey() final  String baseUrl;
@override@JsonKey() final  WorkspaceConnectionStatus connectionStatus;
@override@JsonKey() final  WorkspaceStreamStatus streamStatus;
 final  List<PiSessionModel> _sessions;
@override@JsonKey() List<PiSessionModel> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override final  String? selectedSessionId;
 final  List<PiMessageModel> _messages;
@override@JsonKey() List<PiMessageModel> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool sessionsLoading;
@override@JsonKey() final  bool conversationLoading;
@override@JsonKey() final  bool creatingSession;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool streaming;
@override final  String? error;
@override final  String? statusMessage;

/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceModelCopyWith<_WorkspaceModel> get copyWith => __$WorkspaceModelCopyWithImpl<_WorkspaceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkspaceModel'))
    ..add(DiagnosticsProperty('baseUrl', baseUrl))..add(DiagnosticsProperty('connectionStatus', connectionStatus))..add(DiagnosticsProperty('streamStatus', streamStatus))..add(DiagnosticsProperty('sessions', sessions))..add(DiagnosticsProperty('selectedSessionId', selectedSessionId))..add(DiagnosticsProperty('messages', messages))..add(DiagnosticsProperty('sessionsLoading', sessionsLoading))..add(DiagnosticsProperty('conversationLoading', conversationLoading))..add(DiagnosticsProperty('creatingSession', creatingSession))..add(DiagnosticsProperty('sending', sending))..add(DiagnosticsProperty('streaming', streaming))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('statusMessage', statusMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceModel&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.streamStatus, streamStatus) || other.streamStatus == streamStatus)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.streaming, streaming) || other.streaming == streaming)&&(identical(other.error, error) || other.error == error)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseUrl,connectionStatus,streamStatus,const DeepCollectionEquality().hash(_sessions),selectedSessionId,const DeepCollectionEquality().hash(_messages),sessionsLoading,conversationLoading,creatingSession,sending,streaming,error,statusMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkspaceModel(baseUrl: $baseUrl, connectionStatus: $connectionStatus, streamStatus: $streamStatus, sessions: $sessions, selectedSessionId: $selectedSessionId, messages: $messages, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sending: $sending, streaming: $streaming, error: $error, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceModelCopyWith<$Res> implements $WorkspaceModelCopyWith<$Res> {
  factory _$WorkspaceModelCopyWith(_WorkspaceModel value, $Res Function(_WorkspaceModel) _then) = __$WorkspaceModelCopyWithImpl;
@override @useResult
$Res call({
 String baseUrl, WorkspaceConnectionStatus connectionStatus, WorkspaceStreamStatus streamStatus, List<PiSessionModel> sessions, String? selectedSessionId, List<PiMessageModel> messages, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sending, bool streaming, String? error, String? statusMessage
});




}
/// @nodoc
class __$WorkspaceModelCopyWithImpl<$Res>
    implements _$WorkspaceModelCopyWith<$Res> {
  __$WorkspaceModelCopyWithImpl(this._self, this._then);

  final _WorkspaceModel _self;
  final $Res Function(_WorkspaceModel) _then;

/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseUrl = null,Object? connectionStatus = null,Object? streamStatus = null,Object? sessions = null,Object? selectedSessionId = freezed,Object? messages = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sending = null,Object? streaming = null,Object? error = freezed,Object? statusMessage = freezed,}) {
  return _then(_WorkspaceModel(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceConnectionStatus,streamStatus: null == streamStatus ? _self.streamStatus : streamStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceStreamStatus,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionModel>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as String?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessageModel>,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,streaming: null == streaming ? _self.streaming : streaming // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
