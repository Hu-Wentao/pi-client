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

@JsonKey(includeToJson: false) PiNodeConnectionSnapshot get connection; PiNodeCompositionAvailability get nodeAvailability; WorkspaceEventStatus get eventStatus; WorkspacePromptAdmissionStatus get promptAdmissionStatus;@JsonKey(includeToJson: false) PiProjectBootstrap? get projectBootstrap;@JsonKey(includeToJson: false) List<PiKnownProject> get knownProjects;@JsonKey(includeToJson: false) PiProject? get selectedProject;@JsonKey(includeToJson: false) PiDirectoryListing? get projectDirectory;@JsonKey(includeToJson: false) List<PiSessionSummary> get sessions;@JsonKey(includeToJson: false) PiSessionId? get selectedSessionId;@JsonKey(includeToJson: false) PiSessionId? get sessionAdminSessionId;@JsonKey(includeToJson: false) PiSessionAdminOperation? get sessionAdminOperation;@JsonKey(includeToJson: false) List<PiMessage> get messages;@JsonKey(includeToJson: false) List<PiConversationEntry> get conversationEntries;@JsonKey(includeToJson: false) PiSessionHistoryCursor? get historyCursor;@JsonKey(includeToJson: false) PiSessionBranchRevision? get activeBranchRevision;@JsonKey(includeToJson: false) PiSessionTreeRevision? get treeRevision; bool get historyHasMore; bool get historyLoading;@JsonKey(includeToJson: false) PiSessionStats? get sessionStats; bool get sessionStatsLoading;@JsonKey(includeToJson: false) PiSessionTree? get sessionTree;@JsonKey(includeToJson: false) PiSessionTreeMutationOperation? get sessionTreeMutationOperation; bool get sessionTreeLoading; bool get sessionTreeMutationLoading; int get composerDraftGeneration;@JsonKey(includeToJson: false) String? get composerDraft; bool get projectLoading; bool get projectBrowsing; bool get projectValidating; bool get projectTrustApproving; bool get sessionsLoading; bool get conversationLoading; bool get creatingSession; bool get sessionAdminLoading; bool get sessionExportLoading;@JsonKey(includeToJson: false) PiSessionExportFormat? get sessionExportFormat; int get sessionExportSavedBytes; int get sessionExportTotalBytes; String? get lastExportFileName; bool get sending; bool get stopping; String? get nodeError; String? get projectError; String? get sessionError; String? get sessionAdminError; String? get sessionTreeError; String? get conversationError; String? get sessionStatsError; String? get sessionExportError; String? get promptError; String? get statusMessage;
/// Create a copy of WorkspaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceModelCopyWith<WorkspaceModel> get copyWith => _$WorkspaceModelCopyWithImpl<WorkspaceModel>(this as WorkspaceModel, _$identity);

  /// Serializes this WorkspaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceModel&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.nodeAvailability, nodeAvailability) || other.nodeAvailability == nodeAvailability)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.promptAdmissionStatus, promptAdmissionStatus) || other.promptAdmissionStatus == promptAdmissionStatus)&&(identical(other.projectBootstrap, projectBootstrap) || other.projectBootstrap == projectBootstrap)&&const DeepCollectionEquality().equals(other.knownProjects, knownProjects)&&(identical(other.selectedProject, selectedProject) || other.selectedProject == selectedProject)&&(identical(other.projectDirectory, projectDirectory) || other.projectDirectory == projectDirectory)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&(identical(other.sessionAdminSessionId, sessionAdminSessionId) || other.sessionAdminSessionId == sessionAdminSessionId)&&(identical(other.sessionAdminOperation, sessionAdminOperation) || other.sessionAdminOperation == sessionAdminOperation)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.conversationEntries, conversationEntries)&&(identical(other.historyCursor, historyCursor) || other.historyCursor == historyCursor)&&(identical(other.activeBranchRevision, activeBranchRevision) || other.activeBranchRevision == activeBranchRevision)&&(identical(other.treeRevision, treeRevision) || other.treeRevision == treeRevision)&&(identical(other.historyHasMore, historyHasMore) || other.historyHasMore == historyHasMore)&&(identical(other.historyLoading, historyLoading) || other.historyLoading == historyLoading)&&(identical(other.sessionStats, sessionStats) || other.sessionStats == sessionStats)&&(identical(other.sessionStatsLoading, sessionStatsLoading) || other.sessionStatsLoading == sessionStatsLoading)&&(identical(other.sessionTree, sessionTree) || other.sessionTree == sessionTree)&&(identical(other.sessionTreeMutationOperation, sessionTreeMutationOperation) || other.sessionTreeMutationOperation == sessionTreeMutationOperation)&&(identical(other.sessionTreeLoading, sessionTreeLoading) || other.sessionTreeLoading == sessionTreeLoading)&&(identical(other.sessionTreeMutationLoading, sessionTreeMutationLoading) || other.sessionTreeMutationLoading == sessionTreeMutationLoading)&&(identical(other.composerDraftGeneration, composerDraftGeneration) || other.composerDraftGeneration == composerDraftGeneration)&&(identical(other.composerDraft, composerDraft) || other.composerDraft == composerDraft)&&(identical(other.projectLoading, projectLoading) || other.projectLoading == projectLoading)&&(identical(other.projectBrowsing, projectBrowsing) || other.projectBrowsing == projectBrowsing)&&(identical(other.projectValidating, projectValidating) || other.projectValidating == projectValidating)&&(identical(other.projectTrustApproving, projectTrustApproving) || other.projectTrustApproving == projectTrustApproving)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sessionAdminLoading, sessionAdminLoading) || other.sessionAdminLoading == sessionAdminLoading)&&(identical(other.sessionExportLoading, sessionExportLoading) || other.sessionExportLoading == sessionExportLoading)&&(identical(other.sessionExportFormat, sessionExportFormat) || other.sessionExportFormat == sessionExportFormat)&&(identical(other.sessionExportSavedBytes, sessionExportSavedBytes) || other.sessionExportSavedBytes == sessionExportSavedBytes)&&(identical(other.sessionExportTotalBytes, sessionExportTotalBytes) || other.sessionExportTotalBytes == sessionExportTotalBytes)&&(identical(other.lastExportFileName, lastExportFileName) || other.lastExportFileName == lastExportFileName)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.stopping, stopping) || other.stopping == stopping)&&(identical(other.nodeError, nodeError) || other.nodeError == nodeError)&&(identical(other.projectError, projectError) || other.projectError == projectError)&&(identical(other.sessionError, sessionError) || other.sessionError == sessionError)&&(identical(other.sessionAdminError, sessionAdminError) || other.sessionAdminError == sessionAdminError)&&(identical(other.sessionTreeError, sessionTreeError) || other.sessionTreeError == sessionTreeError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.sessionStatsError, sessionStatsError) || other.sessionStatsError == sessionStatsError)&&(identical(other.sessionExportError, sessionExportError) || other.sessionExportError == sessionExportError)&&(identical(other.promptError, promptError) || other.promptError == promptError)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,connection,nodeAvailability,eventStatus,promptAdmissionStatus,projectBootstrap,const DeepCollectionEquality().hash(knownProjects),selectedProject,projectDirectory,const DeepCollectionEquality().hash(sessions),selectedSessionId,sessionAdminSessionId,sessionAdminOperation,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(conversationEntries),historyCursor,activeBranchRevision,treeRevision,historyHasMore,historyLoading,sessionStats,sessionStatsLoading,sessionTree,sessionTreeMutationOperation,sessionTreeLoading,sessionTreeMutationLoading,composerDraftGeneration,composerDraft,projectLoading,projectBrowsing,projectValidating,projectTrustApproving,sessionsLoading,conversationLoading,creatingSession,sessionAdminLoading,sessionExportLoading,sessionExportFormat,sessionExportSavedBytes,sessionExportTotalBytes,lastExportFileName,sending,stopping,nodeError,projectError,sessionError,sessionAdminError,sessionTreeError,conversationError,sessionStatsError,sessionExportError,promptError,statusMessage]);

@override
String toString() {
  return 'WorkspaceModel(connection: $connection, nodeAvailability: $nodeAvailability, eventStatus: $eventStatus, promptAdmissionStatus: $promptAdmissionStatus, projectBootstrap: $projectBootstrap, knownProjects: $knownProjects, selectedProject: $selectedProject, projectDirectory: $projectDirectory, sessions: $sessions, selectedSessionId: $selectedSessionId, sessionAdminSessionId: $sessionAdminSessionId, sessionAdminOperation: $sessionAdminOperation, messages: $messages, conversationEntries: $conversationEntries, historyCursor: $historyCursor, activeBranchRevision: $activeBranchRevision, treeRevision: $treeRevision, historyHasMore: $historyHasMore, historyLoading: $historyLoading, sessionStats: $sessionStats, sessionStatsLoading: $sessionStatsLoading, sessionTree: $sessionTree, sessionTreeMutationOperation: $sessionTreeMutationOperation, sessionTreeLoading: $sessionTreeLoading, sessionTreeMutationLoading: $sessionTreeMutationLoading, composerDraftGeneration: $composerDraftGeneration, composerDraft: $composerDraft, projectLoading: $projectLoading, projectBrowsing: $projectBrowsing, projectValidating: $projectValidating, projectTrustApproving: $projectTrustApproving, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sessionAdminLoading: $sessionAdminLoading, sessionExportLoading: $sessionExportLoading, sessionExportFormat: $sessionExportFormat, sessionExportSavedBytes: $sessionExportSavedBytes, sessionExportTotalBytes: $sessionExportTotalBytes, lastExportFileName: $lastExportFileName, sending: $sending, stopping: $stopping, nodeError: $nodeError, projectError: $projectError, sessionError: $sessionError, sessionAdminError: $sessionAdminError, sessionTreeError: $sessionTreeError, conversationError: $conversationError, sessionStatsError: $sessionStatsError, sessionExportError: $sessionExportError, promptError: $promptError, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class $WorkspaceModelCopyWith<$Res>  {
  factory $WorkspaceModelCopyWith(WorkspaceModel value, $Res Function(WorkspaceModel) _then) = _$WorkspaceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) PiNodeConnectionSnapshot connection, PiNodeCompositionAvailability nodeAvailability, WorkspaceEventStatus eventStatus, WorkspacePromptAdmissionStatus promptAdmissionStatus,@JsonKey(includeToJson: false) PiProjectBootstrap? projectBootstrap,@JsonKey(includeToJson: false) List<PiKnownProject> knownProjects,@JsonKey(includeToJson: false) PiProject? selectedProject,@JsonKey(includeToJson: false) PiDirectoryListing? projectDirectory,@JsonKey(includeToJson: false) List<PiSessionSummary> sessions,@JsonKey(includeToJson: false) PiSessionId? selectedSessionId,@JsonKey(includeToJson: false) PiSessionId? sessionAdminSessionId,@JsonKey(includeToJson: false) PiSessionAdminOperation? sessionAdminOperation,@JsonKey(includeToJson: false) List<PiMessage> messages,@JsonKey(includeToJson: false) List<PiConversationEntry> conversationEntries,@JsonKey(includeToJson: false) PiSessionHistoryCursor? historyCursor,@JsonKey(includeToJson: false) PiSessionBranchRevision? activeBranchRevision,@JsonKey(includeToJson: false) PiSessionTreeRevision? treeRevision, bool historyHasMore, bool historyLoading,@JsonKey(includeToJson: false) PiSessionStats? sessionStats, bool sessionStatsLoading,@JsonKey(includeToJson: false) PiSessionTree? sessionTree,@JsonKey(includeToJson: false) PiSessionTreeMutationOperation? sessionTreeMutationOperation, bool sessionTreeLoading, bool sessionTreeMutationLoading, int composerDraftGeneration,@JsonKey(includeToJson: false) String? composerDraft, bool projectLoading, bool projectBrowsing, bool projectValidating, bool projectTrustApproving, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sessionAdminLoading, bool sessionExportLoading,@JsonKey(includeToJson: false) PiSessionExportFormat? sessionExportFormat, int sessionExportSavedBytes, int sessionExportTotalBytes, String? lastExportFileName, bool sending, bool stopping, String? nodeError, String? projectError, String? sessionError, String? sessionAdminError, String? sessionTreeError, String? conversationError, String? sessionStatsError, String? sessionExportError, String? promptError, String? statusMessage
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
@pragma('vm:prefer-inline') @override $Res call({Object? connection = null,Object? nodeAvailability = null,Object? eventStatus = null,Object? promptAdmissionStatus = null,Object? projectBootstrap = freezed,Object? knownProjects = null,Object? selectedProject = freezed,Object? projectDirectory = freezed,Object? sessions = null,Object? selectedSessionId = freezed,Object? sessionAdminSessionId = freezed,Object? sessionAdminOperation = freezed,Object? messages = null,Object? conversationEntries = null,Object? historyCursor = freezed,Object? activeBranchRevision = freezed,Object? treeRevision = freezed,Object? historyHasMore = null,Object? historyLoading = null,Object? sessionStats = freezed,Object? sessionStatsLoading = null,Object? sessionTree = freezed,Object? sessionTreeMutationOperation = freezed,Object? sessionTreeLoading = null,Object? sessionTreeMutationLoading = null,Object? composerDraftGeneration = null,Object? composerDraft = freezed,Object? projectLoading = null,Object? projectBrowsing = null,Object? projectValidating = null,Object? projectTrustApproving = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sessionAdminLoading = null,Object? sessionExportLoading = null,Object? sessionExportFormat = freezed,Object? sessionExportSavedBytes = null,Object? sessionExportTotalBytes = null,Object? lastExportFileName = freezed,Object? sending = null,Object? stopping = null,Object? nodeError = freezed,Object? projectError = freezed,Object? sessionError = freezed,Object? sessionAdminError = freezed,Object? sessionTreeError = freezed,Object? conversationError = freezed,Object? sessionStatsError = freezed,Object? sessionExportError = freezed,Object? promptError = freezed,Object? statusMessage = freezed,}) {
  return _then(_self.copyWith(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as PiNodeConnectionSnapshot,nodeAvailability: null == nodeAvailability ? _self.nodeAvailability : nodeAvailability // ignore: cast_nullable_to_non_nullable
as PiNodeCompositionAvailability,eventStatus: null == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceEventStatus,promptAdmissionStatus: null == promptAdmissionStatus ? _self.promptAdmissionStatus : promptAdmissionStatus // ignore: cast_nullable_to_non_nullable
as WorkspacePromptAdmissionStatus,projectBootstrap: freezed == projectBootstrap ? _self.projectBootstrap : projectBootstrap // ignore: cast_nullable_to_non_nullable
as PiProjectBootstrap?,knownProjects: null == knownProjects ? _self.knownProjects : knownProjects // ignore: cast_nullable_to_non_nullable
as List<PiKnownProject>,selectedProject: freezed == selectedProject ? _self.selectedProject : selectedProject // ignore: cast_nullable_to_non_nullable
as PiProject?,projectDirectory: freezed == projectDirectory ? _self.projectDirectory : projectDirectory // ignore: cast_nullable_to_non_nullable
as PiDirectoryListing?,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionSummary>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,sessionAdminSessionId: freezed == sessionAdminSessionId ? _self.sessionAdminSessionId : sessionAdminSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,sessionAdminOperation: freezed == sessionAdminOperation ? _self.sessionAdminOperation : sessionAdminOperation // ignore: cast_nullable_to_non_nullable
as PiSessionAdminOperation?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessage>,conversationEntries: null == conversationEntries ? _self.conversationEntries : conversationEntries // ignore: cast_nullable_to_non_nullable
as List<PiConversationEntry>,historyCursor: freezed == historyCursor ? _self.historyCursor : historyCursor // ignore: cast_nullable_to_non_nullable
as PiSessionHistoryCursor?,activeBranchRevision: freezed == activeBranchRevision ? _self.activeBranchRevision : activeBranchRevision // ignore: cast_nullable_to_non_nullable
as PiSessionBranchRevision?,treeRevision: freezed == treeRevision ? _self.treeRevision : treeRevision // ignore: cast_nullable_to_non_nullable
as PiSessionTreeRevision?,historyHasMore: null == historyHasMore ? _self.historyHasMore : historyHasMore // ignore: cast_nullable_to_non_nullable
as bool,historyLoading: null == historyLoading ? _self.historyLoading : historyLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionStats: freezed == sessionStats ? _self.sessionStats : sessionStats // ignore: cast_nullable_to_non_nullable
as PiSessionStats?,sessionStatsLoading: null == sessionStatsLoading ? _self.sessionStatsLoading : sessionStatsLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionTree: freezed == sessionTree ? _self.sessionTree : sessionTree // ignore: cast_nullable_to_non_nullable
as PiSessionTree?,sessionTreeMutationOperation: freezed == sessionTreeMutationOperation ? _self.sessionTreeMutationOperation : sessionTreeMutationOperation // ignore: cast_nullable_to_non_nullable
as PiSessionTreeMutationOperation?,sessionTreeLoading: null == sessionTreeLoading ? _self.sessionTreeLoading : sessionTreeLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionTreeMutationLoading: null == sessionTreeMutationLoading ? _self.sessionTreeMutationLoading : sessionTreeMutationLoading // ignore: cast_nullable_to_non_nullable
as bool,composerDraftGeneration: null == composerDraftGeneration ? _self.composerDraftGeneration : composerDraftGeneration // ignore: cast_nullable_to_non_nullable
as int,composerDraft: freezed == composerDraft ? _self.composerDraft : composerDraft // ignore: cast_nullable_to_non_nullable
as String?,projectLoading: null == projectLoading ? _self.projectLoading : projectLoading // ignore: cast_nullable_to_non_nullable
as bool,projectBrowsing: null == projectBrowsing ? _self.projectBrowsing : projectBrowsing // ignore: cast_nullable_to_non_nullable
as bool,projectValidating: null == projectValidating ? _self.projectValidating : projectValidating // ignore: cast_nullable_to_non_nullable
as bool,projectTrustApproving: null == projectTrustApproving ? _self.projectTrustApproving : projectTrustApproving // ignore: cast_nullable_to_non_nullable
as bool,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sessionAdminLoading: null == sessionAdminLoading ? _self.sessionAdminLoading : sessionAdminLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionExportLoading: null == sessionExportLoading ? _self.sessionExportLoading : sessionExportLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionExportFormat: freezed == sessionExportFormat ? _self.sessionExportFormat : sessionExportFormat // ignore: cast_nullable_to_non_nullable
as PiSessionExportFormat?,sessionExportSavedBytes: null == sessionExportSavedBytes ? _self.sessionExportSavedBytes : sessionExportSavedBytes // ignore: cast_nullable_to_non_nullable
as int,sessionExportTotalBytes: null == sessionExportTotalBytes ? _self.sessionExportTotalBytes : sessionExportTotalBytes // ignore: cast_nullable_to_non_nullable
as int,lastExportFileName: freezed == lastExportFileName ? _self.lastExportFileName : lastExportFileName // ignore: cast_nullable_to_non_nullable
as String?,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,nodeError: freezed == nodeError ? _self.nodeError : nodeError // ignore: cast_nullable_to_non_nullable
as String?,projectError: freezed == projectError ? _self.projectError : projectError // ignore: cast_nullable_to_non_nullable
as String?,sessionError: freezed == sessionError ? _self.sessionError : sessionError // ignore: cast_nullable_to_non_nullable
as String?,sessionAdminError: freezed == sessionAdminError ? _self.sessionAdminError : sessionAdminError // ignore: cast_nullable_to_non_nullable
as String?,sessionTreeError: freezed == sessionTreeError ? _self.sessionTreeError : sessionTreeError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,sessionStatsError: freezed == sessionStatsError ? _self.sessionStatsError : sessionStatsError // ignore: cast_nullable_to_non_nullable
as String?,sessionExportError: freezed == sessionExportError ? _self.sessionExportError : sessionExportError // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  PiProjectBootstrap? projectBootstrap, @JsonKey(includeToJson: false)  List<PiKnownProject> knownProjects, @JsonKey(includeToJson: false)  PiProject? selectedProject, @JsonKey(includeToJson: false)  PiDirectoryListing? projectDirectory, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  PiSessionId? sessionAdminSessionId, @JsonKey(includeToJson: false)  PiSessionAdminOperation? sessionAdminOperation, @JsonKey(includeToJson: false)  List<PiMessage> messages, @JsonKey(includeToJson: false)  List<PiConversationEntry> conversationEntries, @JsonKey(includeToJson: false)  PiSessionHistoryCursor? historyCursor, @JsonKey(includeToJson: false)  PiSessionBranchRevision? activeBranchRevision, @JsonKey(includeToJson: false)  PiSessionTreeRevision? treeRevision,  bool historyHasMore,  bool historyLoading, @JsonKey(includeToJson: false)  PiSessionStats? sessionStats,  bool sessionStatsLoading, @JsonKey(includeToJson: false)  PiSessionTree? sessionTree, @JsonKey(includeToJson: false)  PiSessionTreeMutationOperation? sessionTreeMutationOperation,  bool sessionTreeLoading,  bool sessionTreeMutationLoading,  int composerDraftGeneration, @JsonKey(includeToJson: false)  String? composerDraft,  bool projectLoading,  bool projectBrowsing,  bool projectValidating,  bool projectTrustApproving,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sessionAdminLoading,  bool sessionExportLoading, @JsonKey(includeToJson: false)  PiSessionExportFormat? sessionExportFormat,  int sessionExportSavedBytes,  int sessionExportTotalBytes,  String? lastExportFileName,  bool sending,  bool stopping,  String? nodeError,  String? projectError,  String? sessionError,  String? sessionAdminError,  String? sessionTreeError,  String? conversationError,  String? sessionStatsError,  String? sessionExportError,  String? promptError,  String? statusMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.projectBootstrap,_that.knownProjects,_that.selectedProject,_that.projectDirectory,_that.sessions,_that.selectedSessionId,_that.sessionAdminSessionId,_that.sessionAdminOperation,_that.messages,_that.conversationEntries,_that.historyCursor,_that.activeBranchRevision,_that.treeRevision,_that.historyHasMore,_that.historyLoading,_that.sessionStats,_that.sessionStatsLoading,_that.sessionTree,_that.sessionTreeMutationOperation,_that.sessionTreeLoading,_that.sessionTreeMutationLoading,_that.composerDraftGeneration,_that.composerDraft,_that.projectLoading,_that.projectBrowsing,_that.projectValidating,_that.projectTrustApproving,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sessionAdminLoading,_that.sessionExportLoading,_that.sessionExportFormat,_that.sessionExportSavedBytes,_that.sessionExportTotalBytes,_that.lastExportFileName,_that.sending,_that.stopping,_that.nodeError,_that.projectError,_that.sessionError,_that.sessionAdminError,_that.sessionTreeError,_that.conversationError,_that.sessionStatsError,_that.sessionExportError,_that.promptError,_that.statusMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  PiProjectBootstrap? projectBootstrap, @JsonKey(includeToJson: false)  List<PiKnownProject> knownProjects, @JsonKey(includeToJson: false)  PiProject? selectedProject, @JsonKey(includeToJson: false)  PiDirectoryListing? projectDirectory, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  PiSessionId? sessionAdminSessionId, @JsonKey(includeToJson: false)  PiSessionAdminOperation? sessionAdminOperation, @JsonKey(includeToJson: false)  List<PiMessage> messages, @JsonKey(includeToJson: false)  List<PiConversationEntry> conversationEntries, @JsonKey(includeToJson: false)  PiSessionHistoryCursor? historyCursor, @JsonKey(includeToJson: false)  PiSessionBranchRevision? activeBranchRevision, @JsonKey(includeToJson: false)  PiSessionTreeRevision? treeRevision,  bool historyHasMore,  bool historyLoading, @JsonKey(includeToJson: false)  PiSessionStats? sessionStats,  bool sessionStatsLoading, @JsonKey(includeToJson: false)  PiSessionTree? sessionTree, @JsonKey(includeToJson: false)  PiSessionTreeMutationOperation? sessionTreeMutationOperation,  bool sessionTreeLoading,  bool sessionTreeMutationLoading,  int composerDraftGeneration, @JsonKey(includeToJson: false)  String? composerDraft,  bool projectLoading,  bool projectBrowsing,  bool projectValidating,  bool projectTrustApproving,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sessionAdminLoading,  bool sessionExportLoading, @JsonKey(includeToJson: false)  PiSessionExportFormat? sessionExportFormat,  int sessionExportSavedBytes,  int sessionExportTotalBytes,  String? lastExportFileName,  bool sending,  bool stopping,  String? nodeError,  String? projectError,  String? sessionError,  String? sessionAdminError,  String? sessionTreeError,  String? conversationError,  String? sessionStatsError,  String? sessionExportError,  String? promptError,  String? statusMessage)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel():
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.projectBootstrap,_that.knownProjects,_that.selectedProject,_that.projectDirectory,_that.sessions,_that.selectedSessionId,_that.sessionAdminSessionId,_that.sessionAdminOperation,_that.messages,_that.conversationEntries,_that.historyCursor,_that.activeBranchRevision,_that.treeRevision,_that.historyHasMore,_that.historyLoading,_that.sessionStats,_that.sessionStatsLoading,_that.sessionTree,_that.sessionTreeMutationOperation,_that.sessionTreeLoading,_that.sessionTreeMutationLoading,_that.composerDraftGeneration,_that.composerDraft,_that.projectLoading,_that.projectBrowsing,_that.projectValidating,_that.projectTrustApproving,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sessionAdminLoading,_that.sessionExportLoading,_that.sessionExportFormat,_that.sessionExportSavedBytes,_that.sessionExportTotalBytes,_that.lastExportFileName,_that.sending,_that.stopping,_that.nodeError,_that.projectError,_that.sessionError,_that.sessionAdminError,_that.sessionTreeError,_that.conversationError,_that.sessionStatsError,_that.sessionExportError,_that.promptError,_that.statusMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  PiNodeConnectionSnapshot connection,  PiNodeCompositionAvailability nodeAvailability,  WorkspaceEventStatus eventStatus,  WorkspacePromptAdmissionStatus promptAdmissionStatus, @JsonKey(includeToJson: false)  PiProjectBootstrap? projectBootstrap, @JsonKey(includeToJson: false)  List<PiKnownProject> knownProjects, @JsonKey(includeToJson: false)  PiProject? selectedProject, @JsonKey(includeToJson: false)  PiDirectoryListing? projectDirectory, @JsonKey(includeToJson: false)  List<PiSessionSummary> sessions, @JsonKey(includeToJson: false)  PiSessionId? selectedSessionId, @JsonKey(includeToJson: false)  PiSessionId? sessionAdminSessionId, @JsonKey(includeToJson: false)  PiSessionAdminOperation? sessionAdminOperation, @JsonKey(includeToJson: false)  List<PiMessage> messages, @JsonKey(includeToJson: false)  List<PiConversationEntry> conversationEntries, @JsonKey(includeToJson: false)  PiSessionHistoryCursor? historyCursor, @JsonKey(includeToJson: false)  PiSessionBranchRevision? activeBranchRevision, @JsonKey(includeToJson: false)  PiSessionTreeRevision? treeRevision,  bool historyHasMore,  bool historyLoading, @JsonKey(includeToJson: false)  PiSessionStats? sessionStats,  bool sessionStatsLoading, @JsonKey(includeToJson: false)  PiSessionTree? sessionTree, @JsonKey(includeToJson: false)  PiSessionTreeMutationOperation? sessionTreeMutationOperation,  bool sessionTreeLoading,  bool sessionTreeMutationLoading,  int composerDraftGeneration, @JsonKey(includeToJson: false)  String? composerDraft,  bool projectLoading,  bool projectBrowsing,  bool projectValidating,  bool projectTrustApproving,  bool sessionsLoading,  bool conversationLoading,  bool creatingSession,  bool sessionAdminLoading,  bool sessionExportLoading, @JsonKey(includeToJson: false)  PiSessionExportFormat? sessionExportFormat,  int sessionExportSavedBytes,  int sessionExportTotalBytes,  String? lastExportFileName,  bool sending,  bool stopping,  String? nodeError,  String? projectError,  String? sessionError,  String? sessionAdminError,  String? sessionTreeError,  String? conversationError,  String? sessionStatsError,  String? sessionExportError,  String? promptError,  String? statusMessage)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceModel() when $default != null:
return $default(_that.connection,_that.nodeAvailability,_that.eventStatus,_that.promptAdmissionStatus,_that.projectBootstrap,_that.knownProjects,_that.selectedProject,_that.projectDirectory,_that.sessions,_that.selectedSessionId,_that.sessionAdminSessionId,_that.sessionAdminOperation,_that.messages,_that.conversationEntries,_that.historyCursor,_that.activeBranchRevision,_that.treeRevision,_that.historyHasMore,_that.historyLoading,_that.sessionStats,_that.sessionStatsLoading,_that.sessionTree,_that.sessionTreeMutationOperation,_that.sessionTreeLoading,_that.sessionTreeMutationLoading,_that.composerDraftGeneration,_that.composerDraft,_that.projectLoading,_that.projectBrowsing,_that.projectValidating,_that.projectTrustApproving,_that.sessionsLoading,_that.conversationLoading,_that.creatingSession,_that.sessionAdminLoading,_that.sessionExportLoading,_that.sessionExportFormat,_that.sessionExportSavedBytes,_that.sessionExportTotalBytes,_that.lastExportFileName,_that.sending,_that.stopping,_that.nodeError,_that.projectError,_that.sessionError,_that.sessionAdminError,_that.sessionTreeError,_that.conversationError,_that.sessionStatsError,_that.sessionExportError,_that.promptError,_that.statusMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _WorkspaceModel implements WorkspaceModel {
  const _WorkspaceModel({@JsonKey(includeToJson: false) this.connection = const PiNodeConnectionSnapshot.disconnected(), this.nodeAvailability = PiNodeCompositionAvailability.externalNode, this.eventStatus = WorkspaceEventStatus.idle, this.promptAdmissionStatus = WorkspacePromptAdmissionStatus.idle, @JsonKey(includeToJson: false) this.projectBootstrap, @JsonKey(includeToJson: false) final  List<PiKnownProject> knownProjects = const <PiKnownProject>[], @JsonKey(includeToJson: false) this.selectedProject, @JsonKey(includeToJson: false) this.projectDirectory, @JsonKey(includeToJson: false) final  List<PiSessionSummary> sessions = const <PiSessionSummary>[], @JsonKey(includeToJson: false) this.selectedSessionId, @JsonKey(includeToJson: false) this.sessionAdminSessionId, @JsonKey(includeToJson: false) this.sessionAdminOperation, @JsonKey(includeToJson: false) final  List<PiMessage> messages = const <PiMessage>[], @JsonKey(includeToJson: false) final  List<PiConversationEntry> conversationEntries = const <PiConversationEntry>[], @JsonKey(includeToJson: false) this.historyCursor, @JsonKey(includeToJson: false) this.activeBranchRevision, @JsonKey(includeToJson: false) this.treeRevision, this.historyHasMore = false, this.historyLoading = false, @JsonKey(includeToJson: false) this.sessionStats, this.sessionStatsLoading = false, @JsonKey(includeToJson: false) this.sessionTree, @JsonKey(includeToJson: false) this.sessionTreeMutationOperation, this.sessionTreeLoading = false, this.sessionTreeMutationLoading = false, this.composerDraftGeneration = 0, @JsonKey(includeToJson: false) this.composerDraft, this.projectLoading = false, this.projectBrowsing = false, this.projectValidating = false, this.projectTrustApproving = false, this.sessionsLoading = false, this.conversationLoading = false, this.creatingSession = false, this.sessionAdminLoading = false, this.sessionExportLoading = false, @JsonKey(includeToJson: false) this.sessionExportFormat, this.sessionExportSavedBytes = 0, this.sessionExportTotalBytes = 0, this.lastExportFileName, this.sending = false, this.stopping = false, this.nodeError, this.projectError, this.sessionError, this.sessionAdminError, this.sessionTreeError, this.conversationError, this.sessionStatsError, this.sessionExportError, this.promptError, this.statusMessage}): _knownProjects = knownProjects,_sessions = sessions,_messages = messages,_conversationEntries = conversationEntries;
  

@override@JsonKey(includeToJson: false) final  PiNodeConnectionSnapshot connection;
@override@JsonKey() final  PiNodeCompositionAvailability nodeAvailability;
@override@JsonKey() final  WorkspaceEventStatus eventStatus;
@override@JsonKey() final  WorkspacePromptAdmissionStatus promptAdmissionStatus;
@override@JsonKey(includeToJson: false) final  PiProjectBootstrap? projectBootstrap;
 final  List<PiKnownProject> _knownProjects;
@override@JsonKey(includeToJson: false) List<PiKnownProject> get knownProjects {
  if (_knownProjects is EqualUnmodifiableListView) return _knownProjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_knownProjects);
}

@override@JsonKey(includeToJson: false) final  PiProject? selectedProject;
@override@JsonKey(includeToJson: false) final  PiDirectoryListing? projectDirectory;
 final  List<PiSessionSummary> _sessions;
@override@JsonKey(includeToJson: false) List<PiSessionSummary> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override@JsonKey(includeToJson: false) final  PiSessionId? selectedSessionId;
@override@JsonKey(includeToJson: false) final  PiSessionId? sessionAdminSessionId;
@override@JsonKey(includeToJson: false) final  PiSessionAdminOperation? sessionAdminOperation;
 final  List<PiMessage> _messages;
@override@JsonKey(includeToJson: false) List<PiMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<PiConversationEntry> _conversationEntries;
@override@JsonKey(includeToJson: false) List<PiConversationEntry> get conversationEntries {
  if (_conversationEntries is EqualUnmodifiableListView) return _conversationEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversationEntries);
}

@override@JsonKey(includeToJson: false) final  PiSessionHistoryCursor? historyCursor;
@override@JsonKey(includeToJson: false) final  PiSessionBranchRevision? activeBranchRevision;
@override@JsonKey(includeToJson: false) final  PiSessionTreeRevision? treeRevision;
@override@JsonKey() final  bool historyHasMore;
@override@JsonKey() final  bool historyLoading;
@override@JsonKey(includeToJson: false) final  PiSessionStats? sessionStats;
@override@JsonKey() final  bool sessionStatsLoading;
@override@JsonKey(includeToJson: false) final  PiSessionTree? sessionTree;
@override@JsonKey(includeToJson: false) final  PiSessionTreeMutationOperation? sessionTreeMutationOperation;
@override@JsonKey() final  bool sessionTreeLoading;
@override@JsonKey() final  bool sessionTreeMutationLoading;
@override@JsonKey() final  int composerDraftGeneration;
@override@JsonKey(includeToJson: false) final  String? composerDraft;
@override@JsonKey() final  bool projectLoading;
@override@JsonKey() final  bool projectBrowsing;
@override@JsonKey() final  bool projectValidating;
@override@JsonKey() final  bool projectTrustApproving;
@override@JsonKey() final  bool sessionsLoading;
@override@JsonKey() final  bool conversationLoading;
@override@JsonKey() final  bool creatingSession;
@override@JsonKey() final  bool sessionAdminLoading;
@override@JsonKey() final  bool sessionExportLoading;
@override@JsonKey(includeToJson: false) final  PiSessionExportFormat? sessionExportFormat;
@override@JsonKey() final  int sessionExportSavedBytes;
@override@JsonKey() final  int sessionExportTotalBytes;
@override final  String? lastExportFileName;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool stopping;
@override final  String? nodeError;
@override final  String? projectError;
@override final  String? sessionError;
@override final  String? sessionAdminError;
@override final  String? sessionTreeError;
@override final  String? conversationError;
@override final  String? sessionStatsError;
@override final  String? sessionExportError;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceModel&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.nodeAvailability, nodeAvailability) || other.nodeAvailability == nodeAvailability)&&(identical(other.eventStatus, eventStatus) || other.eventStatus == eventStatus)&&(identical(other.promptAdmissionStatus, promptAdmissionStatus) || other.promptAdmissionStatus == promptAdmissionStatus)&&(identical(other.projectBootstrap, projectBootstrap) || other.projectBootstrap == projectBootstrap)&&const DeepCollectionEquality().equals(other._knownProjects, _knownProjects)&&(identical(other.selectedProject, selectedProject) || other.selectedProject == selectedProject)&&(identical(other.projectDirectory, projectDirectory) || other.projectDirectory == projectDirectory)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.selectedSessionId, selectedSessionId) || other.selectedSessionId == selectedSessionId)&&(identical(other.sessionAdminSessionId, sessionAdminSessionId) || other.sessionAdminSessionId == sessionAdminSessionId)&&(identical(other.sessionAdminOperation, sessionAdminOperation) || other.sessionAdminOperation == sessionAdminOperation)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._conversationEntries, _conversationEntries)&&(identical(other.historyCursor, historyCursor) || other.historyCursor == historyCursor)&&(identical(other.activeBranchRevision, activeBranchRevision) || other.activeBranchRevision == activeBranchRevision)&&(identical(other.treeRevision, treeRevision) || other.treeRevision == treeRevision)&&(identical(other.historyHasMore, historyHasMore) || other.historyHasMore == historyHasMore)&&(identical(other.historyLoading, historyLoading) || other.historyLoading == historyLoading)&&(identical(other.sessionStats, sessionStats) || other.sessionStats == sessionStats)&&(identical(other.sessionStatsLoading, sessionStatsLoading) || other.sessionStatsLoading == sessionStatsLoading)&&(identical(other.sessionTree, sessionTree) || other.sessionTree == sessionTree)&&(identical(other.sessionTreeMutationOperation, sessionTreeMutationOperation) || other.sessionTreeMutationOperation == sessionTreeMutationOperation)&&(identical(other.sessionTreeLoading, sessionTreeLoading) || other.sessionTreeLoading == sessionTreeLoading)&&(identical(other.sessionTreeMutationLoading, sessionTreeMutationLoading) || other.sessionTreeMutationLoading == sessionTreeMutationLoading)&&(identical(other.composerDraftGeneration, composerDraftGeneration) || other.composerDraftGeneration == composerDraftGeneration)&&(identical(other.composerDraft, composerDraft) || other.composerDraft == composerDraft)&&(identical(other.projectLoading, projectLoading) || other.projectLoading == projectLoading)&&(identical(other.projectBrowsing, projectBrowsing) || other.projectBrowsing == projectBrowsing)&&(identical(other.projectValidating, projectValidating) || other.projectValidating == projectValidating)&&(identical(other.projectTrustApproving, projectTrustApproving) || other.projectTrustApproving == projectTrustApproving)&&(identical(other.sessionsLoading, sessionsLoading) || other.sessionsLoading == sessionsLoading)&&(identical(other.conversationLoading, conversationLoading) || other.conversationLoading == conversationLoading)&&(identical(other.creatingSession, creatingSession) || other.creatingSession == creatingSession)&&(identical(other.sessionAdminLoading, sessionAdminLoading) || other.sessionAdminLoading == sessionAdminLoading)&&(identical(other.sessionExportLoading, sessionExportLoading) || other.sessionExportLoading == sessionExportLoading)&&(identical(other.sessionExportFormat, sessionExportFormat) || other.sessionExportFormat == sessionExportFormat)&&(identical(other.sessionExportSavedBytes, sessionExportSavedBytes) || other.sessionExportSavedBytes == sessionExportSavedBytes)&&(identical(other.sessionExportTotalBytes, sessionExportTotalBytes) || other.sessionExportTotalBytes == sessionExportTotalBytes)&&(identical(other.lastExportFileName, lastExportFileName) || other.lastExportFileName == lastExportFileName)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.stopping, stopping) || other.stopping == stopping)&&(identical(other.nodeError, nodeError) || other.nodeError == nodeError)&&(identical(other.projectError, projectError) || other.projectError == projectError)&&(identical(other.sessionError, sessionError) || other.sessionError == sessionError)&&(identical(other.sessionAdminError, sessionAdminError) || other.sessionAdminError == sessionAdminError)&&(identical(other.sessionTreeError, sessionTreeError) || other.sessionTreeError == sessionTreeError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.sessionStatsError, sessionStatsError) || other.sessionStatsError == sessionStatsError)&&(identical(other.sessionExportError, sessionExportError) || other.sessionExportError == sessionExportError)&&(identical(other.promptError, promptError) || other.promptError == promptError)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,connection,nodeAvailability,eventStatus,promptAdmissionStatus,projectBootstrap,const DeepCollectionEquality().hash(_knownProjects),selectedProject,projectDirectory,const DeepCollectionEquality().hash(_sessions),selectedSessionId,sessionAdminSessionId,sessionAdminOperation,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_conversationEntries),historyCursor,activeBranchRevision,treeRevision,historyHasMore,historyLoading,sessionStats,sessionStatsLoading,sessionTree,sessionTreeMutationOperation,sessionTreeLoading,sessionTreeMutationLoading,composerDraftGeneration,composerDraft,projectLoading,projectBrowsing,projectValidating,projectTrustApproving,sessionsLoading,conversationLoading,creatingSession,sessionAdminLoading,sessionExportLoading,sessionExportFormat,sessionExportSavedBytes,sessionExportTotalBytes,lastExportFileName,sending,stopping,nodeError,projectError,sessionError,sessionAdminError,sessionTreeError,conversationError,sessionStatsError,sessionExportError,promptError,statusMessage]);

@override
String toString() {
  return 'WorkspaceModel(connection: $connection, nodeAvailability: $nodeAvailability, eventStatus: $eventStatus, promptAdmissionStatus: $promptAdmissionStatus, projectBootstrap: $projectBootstrap, knownProjects: $knownProjects, selectedProject: $selectedProject, projectDirectory: $projectDirectory, sessions: $sessions, selectedSessionId: $selectedSessionId, sessionAdminSessionId: $sessionAdminSessionId, sessionAdminOperation: $sessionAdminOperation, messages: $messages, conversationEntries: $conversationEntries, historyCursor: $historyCursor, activeBranchRevision: $activeBranchRevision, treeRevision: $treeRevision, historyHasMore: $historyHasMore, historyLoading: $historyLoading, sessionStats: $sessionStats, sessionStatsLoading: $sessionStatsLoading, sessionTree: $sessionTree, sessionTreeMutationOperation: $sessionTreeMutationOperation, sessionTreeLoading: $sessionTreeLoading, sessionTreeMutationLoading: $sessionTreeMutationLoading, composerDraftGeneration: $composerDraftGeneration, composerDraft: $composerDraft, projectLoading: $projectLoading, projectBrowsing: $projectBrowsing, projectValidating: $projectValidating, projectTrustApproving: $projectTrustApproving, sessionsLoading: $sessionsLoading, conversationLoading: $conversationLoading, creatingSession: $creatingSession, sessionAdminLoading: $sessionAdminLoading, sessionExportLoading: $sessionExportLoading, sessionExportFormat: $sessionExportFormat, sessionExportSavedBytes: $sessionExportSavedBytes, sessionExportTotalBytes: $sessionExportTotalBytes, lastExportFileName: $lastExportFileName, sending: $sending, stopping: $stopping, nodeError: $nodeError, projectError: $projectError, sessionError: $sessionError, sessionAdminError: $sessionAdminError, sessionTreeError: $sessionTreeError, conversationError: $conversationError, sessionStatsError: $sessionStatsError, sessionExportError: $sessionExportError, promptError: $promptError, statusMessage: $statusMessage)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceModelCopyWith<$Res> implements $WorkspaceModelCopyWith<$Res> {
  factory _$WorkspaceModelCopyWith(_WorkspaceModel value, $Res Function(_WorkspaceModel) _then) = __$WorkspaceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) PiNodeConnectionSnapshot connection, PiNodeCompositionAvailability nodeAvailability, WorkspaceEventStatus eventStatus, WorkspacePromptAdmissionStatus promptAdmissionStatus,@JsonKey(includeToJson: false) PiProjectBootstrap? projectBootstrap,@JsonKey(includeToJson: false) List<PiKnownProject> knownProjects,@JsonKey(includeToJson: false) PiProject? selectedProject,@JsonKey(includeToJson: false) PiDirectoryListing? projectDirectory,@JsonKey(includeToJson: false) List<PiSessionSummary> sessions,@JsonKey(includeToJson: false) PiSessionId? selectedSessionId,@JsonKey(includeToJson: false) PiSessionId? sessionAdminSessionId,@JsonKey(includeToJson: false) PiSessionAdminOperation? sessionAdminOperation,@JsonKey(includeToJson: false) List<PiMessage> messages,@JsonKey(includeToJson: false) List<PiConversationEntry> conversationEntries,@JsonKey(includeToJson: false) PiSessionHistoryCursor? historyCursor,@JsonKey(includeToJson: false) PiSessionBranchRevision? activeBranchRevision,@JsonKey(includeToJson: false) PiSessionTreeRevision? treeRevision, bool historyHasMore, bool historyLoading,@JsonKey(includeToJson: false) PiSessionStats? sessionStats, bool sessionStatsLoading,@JsonKey(includeToJson: false) PiSessionTree? sessionTree,@JsonKey(includeToJson: false) PiSessionTreeMutationOperation? sessionTreeMutationOperation, bool sessionTreeLoading, bool sessionTreeMutationLoading, int composerDraftGeneration,@JsonKey(includeToJson: false) String? composerDraft, bool projectLoading, bool projectBrowsing, bool projectValidating, bool projectTrustApproving, bool sessionsLoading, bool conversationLoading, bool creatingSession, bool sessionAdminLoading, bool sessionExportLoading,@JsonKey(includeToJson: false) PiSessionExportFormat? sessionExportFormat, int sessionExportSavedBytes, int sessionExportTotalBytes, String? lastExportFileName, bool sending, bool stopping, String? nodeError, String? projectError, String? sessionError, String? sessionAdminError, String? sessionTreeError, String? conversationError, String? sessionStatsError, String? sessionExportError, String? promptError, String? statusMessage
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
@override @pragma('vm:prefer-inline') $Res call({Object? connection = null,Object? nodeAvailability = null,Object? eventStatus = null,Object? promptAdmissionStatus = null,Object? projectBootstrap = freezed,Object? knownProjects = null,Object? selectedProject = freezed,Object? projectDirectory = freezed,Object? sessions = null,Object? selectedSessionId = freezed,Object? sessionAdminSessionId = freezed,Object? sessionAdminOperation = freezed,Object? messages = null,Object? conversationEntries = null,Object? historyCursor = freezed,Object? activeBranchRevision = freezed,Object? treeRevision = freezed,Object? historyHasMore = null,Object? historyLoading = null,Object? sessionStats = freezed,Object? sessionStatsLoading = null,Object? sessionTree = freezed,Object? sessionTreeMutationOperation = freezed,Object? sessionTreeLoading = null,Object? sessionTreeMutationLoading = null,Object? composerDraftGeneration = null,Object? composerDraft = freezed,Object? projectLoading = null,Object? projectBrowsing = null,Object? projectValidating = null,Object? projectTrustApproving = null,Object? sessionsLoading = null,Object? conversationLoading = null,Object? creatingSession = null,Object? sessionAdminLoading = null,Object? sessionExportLoading = null,Object? sessionExportFormat = freezed,Object? sessionExportSavedBytes = null,Object? sessionExportTotalBytes = null,Object? lastExportFileName = freezed,Object? sending = null,Object? stopping = null,Object? nodeError = freezed,Object? projectError = freezed,Object? sessionError = freezed,Object? sessionAdminError = freezed,Object? sessionTreeError = freezed,Object? conversationError = freezed,Object? sessionStatsError = freezed,Object? sessionExportError = freezed,Object? promptError = freezed,Object? statusMessage = freezed,}) {
  return _then(_WorkspaceModel(
connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as PiNodeConnectionSnapshot,nodeAvailability: null == nodeAvailability ? _self.nodeAvailability : nodeAvailability // ignore: cast_nullable_to_non_nullable
as PiNodeCompositionAvailability,eventStatus: null == eventStatus ? _self.eventStatus : eventStatus // ignore: cast_nullable_to_non_nullable
as WorkspaceEventStatus,promptAdmissionStatus: null == promptAdmissionStatus ? _self.promptAdmissionStatus : promptAdmissionStatus // ignore: cast_nullable_to_non_nullable
as WorkspacePromptAdmissionStatus,projectBootstrap: freezed == projectBootstrap ? _self.projectBootstrap : projectBootstrap // ignore: cast_nullable_to_non_nullable
as PiProjectBootstrap?,knownProjects: null == knownProjects ? _self._knownProjects : knownProjects // ignore: cast_nullable_to_non_nullable
as List<PiKnownProject>,selectedProject: freezed == selectedProject ? _self.selectedProject : selectedProject // ignore: cast_nullable_to_non_nullable
as PiProject?,projectDirectory: freezed == projectDirectory ? _self.projectDirectory : projectDirectory // ignore: cast_nullable_to_non_nullable
as PiDirectoryListing?,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<PiSessionSummary>,selectedSessionId: freezed == selectedSessionId ? _self.selectedSessionId : selectedSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,sessionAdminSessionId: freezed == sessionAdminSessionId ? _self.sessionAdminSessionId : sessionAdminSessionId // ignore: cast_nullable_to_non_nullable
as PiSessionId?,sessionAdminOperation: freezed == sessionAdminOperation ? _self.sessionAdminOperation : sessionAdminOperation // ignore: cast_nullable_to_non_nullable
as PiSessionAdminOperation?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<PiMessage>,conversationEntries: null == conversationEntries ? _self._conversationEntries : conversationEntries // ignore: cast_nullable_to_non_nullable
as List<PiConversationEntry>,historyCursor: freezed == historyCursor ? _self.historyCursor : historyCursor // ignore: cast_nullable_to_non_nullable
as PiSessionHistoryCursor?,activeBranchRevision: freezed == activeBranchRevision ? _self.activeBranchRevision : activeBranchRevision // ignore: cast_nullable_to_non_nullable
as PiSessionBranchRevision?,treeRevision: freezed == treeRevision ? _self.treeRevision : treeRevision // ignore: cast_nullable_to_non_nullable
as PiSessionTreeRevision?,historyHasMore: null == historyHasMore ? _self.historyHasMore : historyHasMore // ignore: cast_nullable_to_non_nullable
as bool,historyLoading: null == historyLoading ? _self.historyLoading : historyLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionStats: freezed == sessionStats ? _self.sessionStats : sessionStats // ignore: cast_nullable_to_non_nullable
as PiSessionStats?,sessionStatsLoading: null == sessionStatsLoading ? _self.sessionStatsLoading : sessionStatsLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionTree: freezed == sessionTree ? _self.sessionTree : sessionTree // ignore: cast_nullable_to_non_nullable
as PiSessionTree?,sessionTreeMutationOperation: freezed == sessionTreeMutationOperation ? _self.sessionTreeMutationOperation : sessionTreeMutationOperation // ignore: cast_nullable_to_non_nullable
as PiSessionTreeMutationOperation?,sessionTreeLoading: null == sessionTreeLoading ? _self.sessionTreeLoading : sessionTreeLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionTreeMutationLoading: null == sessionTreeMutationLoading ? _self.sessionTreeMutationLoading : sessionTreeMutationLoading // ignore: cast_nullable_to_non_nullable
as bool,composerDraftGeneration: null == composerDraftGeneration ? _self.composerDraftGeneration : composerDraftGeneration // ignore: cast_nullable_to_non_nullable
as int,composerDraft: freezed == composerDraft ? _self.composerDraft : composerDraft // ignore: cast_nullable_to_non_nullable
as String?,projectLoading: null == projectLoading ? _self.projectLoading : projectLoading // ignore: cast_nullable_to_non_nullable
as bool,projectBrowsing: null == projectBrowsing ? _self.projectBrowsing : projectBrowsing // ignore: cast_nullable_to_non_nullable
as bool,projectValidating: null == projectValidating ? _self.projectValidating : projectValidating // ignore: cast_nullable_to_non_nullable
as bool,projectTrustApproving: null == projectTrustApproving ? _self.projectTrustApproving : projectTrustApproving // ignore: cast_nullable_to_non_nullable
as bool,sessionsLoading: null == sessionsLoading ? _self.sessionsLoading : sessionsLoading // ignore: cast_nullable_to_non_nullable
as bool,conversationLoading: null == conversationLoading ? _self.conversationLoading : conversationLoading // ignore: cast_nullable_to_non_nullable
as bool,creatingSession: null == creatingSession ? _self.creatingSession : creatingSession // ignore: cast_nullable_to_non_nullable
as bool,sessionAdminLoading: null == sessionAdminLoading ? _self.sessionAdminLoading : sessionAdminLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionExportLoading: null == sessionExportLoading ? _self.sessionExportLoading : sessionExportLoading // ignore: cast_nullable_to_non_nullable
as bool,sessionExportFormat: freezed == sessionExportFormat ? _self.sessionExportFormat : sessionExportFormat // ignore: cast_nullable_to_non_nullable
as PiSessionExportFormat?,sessionExportSavedBytes: null == sessionExportSavedBytes ? _self.sessionExportSavedBytes : sessionExportSavedBytes // ignore: cast_nullable_to_non_nullable
as int,sessionExportTotalBytes: null == sessionExportTotalBytes ? _self.sessionExportTotalBytes : sessionExportTotalBytes // ignore: cast_nullable_to_non_nullable
as int,lastExportFileName: freezed == lastExportFileName ? _self.lastExportFileName : lastExportFileName // ignore: cast_nullable_to_non_nullable
as String?,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,stopping: null == stopping ? _self.stopping : stopping // ignore: cast_nullable_to_non_nullable
as bool,nodeError: freezed == nodeError ? _self.nodeError : nodeError // ignore: cast_nullable_to_non_nullable
as String?,projectError: freezed == projectError ? _self.projectError : projectError // ignore: cast_nullable_to_non_nullable
as String?,sessionError: freezed == sessionError ? _self.sessionError : sessionError // ignore: cast_nullable_to_non_nullable
as String?,sessionAdminError: freezed == sessionAdminError ? _self.sessionAdminError : sessionAdminError // ignore: cast_nullable_to_non_nullable
as String?,sessionTreeError: freezed == sessionTreeError ? _self.sessionTreeError : sessionTreeError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,sessionStatsError: freezed == sessionStatsError ? _self.sessionStatsError : sessionStatsError // ignore: cast_nullable_to_non_nullable
as String?,sessionExportError: freezed == sessionExportError ? _self.sessionExportError : sessionExportError // ignore: cast_nullable_to_non_nullable
as String?,promptError: freezed == promptError ? _self.promptError : promptError // ignore: cast_nullable_to_non_nullable
as String?,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
