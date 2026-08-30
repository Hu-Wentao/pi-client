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
mixin _$WorkspaceModel {

@JsonKey(includeToJson: false) PiNodeConnectionSnapshot get connection; PiNodeCompositionAvailability get nodeAvailability; WorkspaceEventStatus get eventStatus; WorkspacePromptAdmissionStatus get promptAdmissionStatus;@JsonKey(includeToJson: false) List<PiSessionSummary> get sessions;@JsonKey(includeToJson: false) PiSessionId? get selectedSessionId;@JsonKey(includeToJson: false) List<PiMessage> get messages; bool get sessionsLoading; bool get conversationLoading; bool get creatingSession; bool get sending; bool get stopping; String? get nodeError; String? get sessionError; String? get conversationError; String? get promptError; String? get statusMessage;
/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceModelCopyWith<WorkspaceModel> get copyWith => _$WorkspaceModelCopyWithImpl<WorkspaceModel>(this as WorkspaceModel, _$identity);

  /// Serializes this WorkspaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceModel&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.nodeAvailability, nodeAvailability) || other.nodeAvailability == nodeAvailability)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.promptAdmissionStatus, promptAdmissionStatus) || other.promptAdmissionStatus == promptAdmissionStatus)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.stopping, stopping) || other.stopping == stopping)&&(identical(other.nodeError, nodeError) || other.nodeError == nodeError)&&(identical(other.sessionError, sessionError) || other.sessionError == sessionError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.promptError, promptError) || other.promptError == promptError)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connection,nodeAvailability,eventStatus,promptAdmissionStatus,const DeepCollectionEquality().hash(sessions),selectedSessionId,const DeepCollectionEquality().hash(messages),sessionsLoading,conversationLoading,creatingSession,sending,stopping,nodeError,sessionError,conversationError,promptError,statusMessage);

@override
String toString() {
  return 'WorkspaceModel(connection: $connection, nodeAvailability: $nodeAvailability, eventStatus: $eventStatus, promptAdmissionStatus: $promptAdmissionStatus, sessions: $sessions, selectedSessionId: $selectedSessionId, messages: $messages, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sending: $sending, stopping: $stopping, nodeError: $nodeError, sessionError: $sessionError, conversationError: $conversationError, promptError: $promptError, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class $WorkspaceModelCopyWith<$Res>  {
  factory $WorkspaceModelCopyWith(WorkspaceModel value, $Res Function(WorkspaceModel) _then) = _$WorkspaceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) PiNodeConnectionSnapshot connection, PiNodeCompositionAvailability nodeAvailability, WorkspaceEventStatus eventStatus, WorkspacePromptAdmissionStatus promptAdmissionStatus,@JsonKey(includeToJson: false) List<PiSessionSummary> sessions,@JsonKey(includeToJson: false) PiSessionId? selectedSessionId,@JsonKey(includeToJson: false) List<PiMessage> messages, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sending, bool stopping, String? nodeError, String? sessionError, String? conversationError, String? promptError, String? statusMessage
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
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? nodeAvailability = null,Object? eventStatus = null,Object? promptAdmissionStatus = null,Object? sessions = null,Object? selectedSessionId = freezed,Object? messages = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sending = null,Object? stopping = null,Object? nodeError = freezed,Object? sessionError = freezed,Object? conversationError = freezed,Object? promptError = freezed,Object? statusMessage = freezed,}) {
  return _then(_self.copyWith(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as PiNodeConnectionSnapshot,nodeAvailability: null == nodeAvailability ? _self.nodeAvailability : nodeAvailability // ignore: cast_nullable_to_non_nullable
as PiNodeCompositionAvailability,eventStatus: null == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceEventStatus,promptAdmissionStatus: null == promptAdmissionStatus ? _self.promptAdmissionStatus : promptAdmissionStatus // ignore: cast_nullable_to_non_nullable
as WorkspacePromptAdmissionStatus,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionSummary>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessage>,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,nodeError: freezed == nodeError ? _self.nodeError : nodeError // ignore: cast_nullable_to_non_nullable
as String?,sessionError: freezed == sessionError ? _self.sessionError : sessionError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,promptError: freezed == promptError ? _self.promptError : promptError // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  List<PiMessage> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool stopping,  String? nodeError,  String? sessionError,  String? conversationError,  String? promptError,  String? statusMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.stopping,_that.nodeError,_that.sessionError,_that.conversationError,_that.promptError,_that.statusMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  List<PiMessage> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool stopping,  String? nodeError,  String? sessionError,  String? conversationError,  String? promptError,  String? statusMessage)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel():
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.stopping,_that.nodeError,_that.sessionError,_that.conversationError,_that.promptError,_that.statusMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  List<PiMessage> messages,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sending,  bool stopping,  String? nodeError,  String? sessionError,  String? conversationError,  String? promptError,  String? statusMessage)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.sessions,_that.selectedSessionId,_that.messages,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sending,_that.stopping,_that.nodeError,_that.sessionError,_that.conversationError,_that.promptError,_that.statusMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _WorkspaceModel implements WorkspaceModel {
  const _WorkspaceModel({@JsonKey(includeToJson: false) this.connection = const PiNodeConnectionSnapshot.disconnected(), this.nodeAvailability = PiNodeCompositionAvailability.externalNode, this.eventStatus = WorkspaceEventStatus.idle, this.promptAdmissionStatus = WorkspacePromptAdmissionStatus.idle, @JsonKey(includeToJson: false) final  List<PiSessionSummary> sessions = const <PiSessionSummary>[], @JsonKey(includeToJson: false) this.selectedSessionId, @JsonKey(includeToJson: false) final  List<PiMessage> messages = const <PiMessage>[], this.sessionsLoading = false, this.conversationLoading = false, this.creatingSession = false, this.sending = false, this.stopping = false, this.nodeError, this.sessionError, this.conversationError, this.promptError, this.statusMessage}): _sessions = sessions,_messages = messages;
  

@override@JsonKey(includeToJson: false) final  PiNodeConnectionSnapshot connection;
@override@JsonKey() final  PiNodeCompositionAvailability nodeAvailability;
@override@JsonKey() final  WorkspaceEventStatus eventStatus;
@override@JsonKey() final  WorkspacePromptAdmissionStatus promptAdmissionStatus;
 final  List<PiSessionSummary> _sessions;
@override@JsonKey(includeToJson: false) List<PiSessionSummary> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override@JsonKey(includeToJson: false) final  PiSessionId? selectedSessionId;
 final  List<PiMessage> _messages;
@override@JsonKey(includeToJson: false) List<PiMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool sessionsLoading;
@override@JsonKey() final  bool conversationLoading;
@override@JsonKey() final  bool creatingSession;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool stopping;
@override final  String? nodeError;
@override final  String? sessionError;
@override final  String? conversationError;
@override final  String? promptError;
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceModel&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.nodeAvailability, nodeAvailability) || other.nodeAvailability == nodeAvailability)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.promptAdmissionStatus, promptAdmissionStatus) || other.promptAdmissionStatus == promptAdmissionStatus)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.stopping, stopping) || other.stopping == stopping)&&(identical(other.nodeError, nodeError) || other.nodeError == nodeError)&&(identical(other.sessionError, sessionError) || other.sessionError == sessionError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.promptError, promptError) || other.promptError == promptError)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connection,nodeAvailability,eventStatus,promptAdmissionStatus,const DeepCollectionEquality().hash(_sessions),selectedSessionId,const DeepCollectionEquality().hash(_messages),sessionsLoading,conversationLoading,creatingSession,sending,stopping,nodeError,sessionError,conversationError,promptError,statusMessage);

@override
String toString() {
  return 'WorkspaceModel(connection: $connection, nodeAvailability: $nodeAvailability, eventStatus: $eventStatus, promptAdmissionStatus: $promptAdmissionStatus, sessions: $sessions, selectedSessionId: $selectedSessionId, messages: $messages, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sending: $sending, stopping: $stopping, nodeError: $nodeError, sessionError: $sessionError, conversationError: $conversationError, promptError: $promptError, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceModelCopyWith<$Res> implements $WorkspaceModelCopyWith<$Res> {
  factory _$WorkspaceModelCopyWith(_WorkspaceModel value, $Res Function(_WorkspaceModel) _then) = __$WorkspaceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) PiNodeConnectionSnapshot connection, PiNodeCompositionAvailability nodeAvailability, WorkspaceEventStatus eventStatus, WorkspacePromptAdmissionStatus promptAdmissionStatus,@JsonKey(includeToJson: false) List<PiSessionSummary> sessions,@JsonKey(includeToJson: false) PiSessionId? selectedSessionId,@JsonKey(includeToJson: false) List<PiMessage> messages, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sending, bool stopping, String? nodeError, String? sessionError, String? conversationError, String? promptError, String? statusMessage
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
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? nodeAvailability = null,Object? eventStatus = null,Object? promptAdmissionStatus = null,Object? sessions = null,Object? selectedSessionId = freezed,Object? messages = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sending = null,Object? stopping = null,Object? nodeError = freezed,Object? sessionError = freezed,Object? conversationError = freezed,Object? promptError = freezed,Object? statusMessage = freezed,}) {
  return _then(_WorkspaceModel(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as PiNodeConnectionSnapshot,nodeAvailability: null == nodeAvailability ? _self.nodeAvailability : nodeAvailability // ignore: cast_nullable_to_non_nullable
as PiNodeCompositionAvailability,eventStatus: null == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceEventStatus,promptAdmissionStatus: null == promptAdmissionStatus ? _self.promptAdmissionStatus : promptAdmissionStatus // ignore: cast_nullable_to_non_nullable
as WorkspacePromptAdmissionStatus,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionSummary>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessage>,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,nodeError: freezed == nodeError ? _self.nodeError : nodeError // ignore: cast_nullable_to_non_nullable
as String?,sessionError: freezed == sessionError ? _self.sessionError : sessionError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,promptError: freezed == promptError ? _self.promptError : promptError // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
