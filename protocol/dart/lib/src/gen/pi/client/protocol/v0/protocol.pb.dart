// This is a generated file - do not edit.
//
// Generated from pi/client/protocol/v0/protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'protocol.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'protocol.pbenum.dart';

enum PiTransportFrame_Operation {
  clientProtocolOffer,
  serverHandshakeAccepted,
  serverHandshakeRejected,
  healthRequest,
  healthResponse,
  getProjectBootstrapRequest,
  getProjectBootstrapResponse,
  browseDirectoryRequest,
  browseDirectoryResponse,
  validateProjectRequest,
  validateProjectResponse,
  listKnownProjectsRequest,
  listKnownProjectsResponse,
  listSessionsRequest,
  listSessionsResponse,
  getSessionRequest,
  getSessionResponse,
  createSessionRequest,
  createSessionResponse,
  promptCommand,
  abortCommand,
  requestRejected,
  commandAccepted,
  commandRejected,
  approveProjectTrustRequest,
  approveProjectTrustResponse,
  renameSessionCommand,
  clearSessionNameCommand,
  autoNameSessionCommand,
  deleteSessionCommand,
  sessionAdminCommandOutcome,
  getSessionTreeRequest,
  getSessionTreeResponse,
  sessionEventStream,
  eventStream,
  navigateSessionTreeCommand,
  forkSessionCommand,
  cloneSessionCommand,
  sessionTreeMutationOutcome,
  cancel,
  windowUpdate,
  transferOpen,
  transferChunk,
  transferAck,
  transferComplete,
  transferAbort,
  error,
  notSet
}

/// PiTransportFrame is the single public Protobuf wire envelope. Numeric
/// multiplexing identifiers use uint64; domain and transport resource
/// identifiers remain opaque strings.
class PiTransportFrame extends $pb.GeneratedMessage {
  factory PiTransportFrame({
    $fixnum.Int64? frameSequence,
    ClientProtocolOffer? clientProtocolOffer,
    ServerHandshakeAccepted? serverHandshakeAccepted,
    ServerHandshakeRejected? serverHandshakeRejected,
    HealthRequest? healthRequest,
    HealthResponse? healthResponse,
    GetProjectBootstrapRequest? getProjectBootstrapRequest,
    GetProjectBootstrapResponse? getProjectBootstrapResponse,
    BrowseDirectoryRequest? browseDirectoryRequest,
    BrowseDirectoryResponse? browseDirectoryResponse,
    ValidateProjectRequest? validateProjectRequest,
    ValidateProjectResponse? validateProjectResponse,
    ListKnownProjectsRequest? listKnownProjectsRequest,
    ListKnownProjectsResponse? listKnownProjectsResponse,
    ListSessionsRequest? listSessionsRequest,
    ListSessionsResponse? listSessionsResponse,
    GetSessionRequest? getSessionRequest,
    GetSessionResponse? getSessionResponse,
    CreateSessionRequest? createSessionRequest,
    CreateSessionResponse? createSessionResponse,
    PromptCommand? promptCommand,
    AbortCommand? abortCommand,
    RequestRejected? requestRejected,
    CommandAccepted? commandAccepted,
    CommandRejected? commandRejected,
    ApproveProjectTrustRequest? approveProjectTrustRequest,
    ApproveProjectTrustResponse? approveProjectTrustResponse,
    RenameSessionCommand? renameSessionCommand,
    ClearSessionNameCommand? clearSessionNameCommand,
    AutoNameSessionCommand? autoNameSessionCommand,
    DeleteSessionCommand? deleteSessionCommand,
    SessionAdminCommandOutcome? sessionAdminCommandOutcome,
    GetSessionTreeRequest? getSessionTreeRequest,
    GetSessionTreeResponse? getSessionTreeResponse,
    SessionEventStreamEnvelope? sessionEventStream,
    EventStreamEnvelope? eventStream,
    NavigateSessionTreeCommand? navigateSessionTreeCommand,
    ForkSessionCommand? forkSessionCommand,
    CloneSessionCommand? cloneSessionCommand,
    SessionTreeMutationOutcome? sessionTreeMutationOutcome,
    Cancel? cancel,
    WindowUpdate? windowUpdate,
    TransferOpen? transferOpen,
    TransferChunk? transferChunk,
    TransferAck? transferAck,
    TransferComplete? transferComplete,
    TransferAbort? transferAbort,
    ErrorEnvelope? error,
  }) {
    final result = create();
    if (frameSequence != null) result.frameSequence = frameSequence;
    if (clientProtocolOffer != null)
      result.clientProtocolOffer = clientProtocolOffer;
    if (serverHandshakeAccepted != null)
      result.serverHandshakeAccepted = serverHandshakeAccepted;
    if (serverHandshakeRejected != null)
      result.serverHandshakeRejected = serverHandshakeRejected;
    if (healthRequest != null) result.healthRequest = healthRequest;
    if (healthResponse != null) result.healthResponse = healthResponse;
    if (getProjectBootstrapRequest != null)
      result.getProjectBootstrapRequest = getProjectBootstrapRequest;
    if (getProjectBootstrapResponse != null)
      result.getProjectBootstrapResponse = getProjectBootstrapResponse;
    if (browseDirectoryRequest != null)
      result.browseDirectoryRequest = browseDirectoryRequest;
    if (browseDirectoryResponse != null)
      result.browseDirectoryResponse = browseDirectoryResponse;
    if (validateProjectRequest != null)
      result.validateProjectRequest = validateProjectRequest;
    if (validateProjectResponse != null)
      result.validateProjectResponse = validateProjectResponse;
    if (listKnownProjectsRequest != null)
      result.listKnownProjectsRequest = listKnownProjectsRequest;
    if (listKnownProjectsResponse != null)
      result.listKnownProjectsResponse = listKnownProjectsResponse;
    if (listSessionsRequest != null)
      result.listSessionsRequest = listSessionsRequest;
    if (listSessionsResponse != null)
      result.listSessionsResponse = listSessionsResponse;
    if (getSessionRequest != null) result.getSessionRequest = getSessionRequest;
    if (getSessionResponse != null)
      result.getSessionResponse = getSessionResponse;
    if (createSessionRequest != null)
      result.createSessionRequest = createSessionRequest;
    if (createSessionResponse != null)
      result.createSessionResponse = createSessionResponse;
    if (promptCommand != null) result.promptCommand = promptCommand;
    if (abortCommand != null) result.abortCommand = abortCommand;
    if (requestRejected != null) result.requestRejected = requestRejected;
    if (commandAccepted != null) result.commandAccepted = commandAccepted;
    if (commandRejected != null) result.commandRejected = commandRejected;
    if (approveProjectTrustRequest != null)
      result.approveProjectTrustRequest = approveProjectTrustRequest;
    if (approveProjectTrustResponse != null)
      result.approveProjectTrustResponse = approveProjectTrustResponse;
    if (renameSessionCommand != null)
      result.renameSessionCommand = renameSessionCommand;
    if (clearSessionNameCommand != null)
      result.clearSessionNameCommand = clearSessionNameCommand;
    if (autoNameSessionCommand != null)
      result.autoNameSessionCommand = autoNameSessionCommand;
    if (deleteSessionCommand != null)
      result.deleteSessionCommand = deleteSessionCommand;
    if (sessionAdminCommandOutcome != null)
      result.sessionAdminCommandOutcome = sessionAdminCommandOutcome;
    if (getSessionTreeRequest != null)
      result.getSessionTreeRequest = getSessionTreeRequest;
    if (getSessionTreeResponse != null)
      result.getSessionTreeResponse = getSessionTreeResponse;
    if (sessionEventStream != null)
      result.sessionEventStream = sessionEventStream;
    if (eventStream != null) result.eventStream = eventStream;
    if (navigateSessionTreeCommand != null)
      result.navigateSessionTreeCommand = navigateSessionTreeCommand;
    if (forkSessionCommand != null)
      result.forkSessionCommand = forkSessionCommand;
    if (cloneSessionCommand != null)
      result.cloneSessionCommand = cloneSessionCommand;
    if (sessionTreeMutationOutcome != null)
      result.sessionTreeMutationOutcome = sessionTreeMutationOutcome;
    if (cancel != null) result.cancel = cancel;
    if (windowUpdate != null) result.windowUpdate = windowUpdate;
    if (transferOpen != null) result.transferOpen = transferOpen;
    if (transferChunk != null) result.transferChunk = transferChunk;
    if (transferAck != null) result.transferAck = transferAck;
    if (transferComplete != null) result.transferComplete = transferComplete;
    if (transferAbort != null) result.transferAbort = transferAbort;
    if (error != null) result.error = error;
    return result;
  }

  PiTransportFrame._();

  factory PiTransportFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PiTransportFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, PiTransportFrame_Operation>
      _PiTransportFrame_OperationByTag = {
    10: PiTransportFrame_Operation.clientProtocolOffer,
    11: PiTransportFrame_Operation.serverHandshakeAccepted,
    12: PiTransportFrame_Operation.serverHandshakeRejected,
    20: PiTransportFrame_Operation.healthRequest,
    21: PiTransportFrame_Operation.healthResponse,
    22: PiTransportFrame_Operation.getProjectBootstrapRequest,
    23: PiTransportFrame_Operation.getProjectBootstrapResponse,
    24: PiTransportFrame_Operation.browseDirectoryRequest,
    25: PiTransportFrame_Operation.browseDirectoryResponse,
    26: PiTransportFrame_Operation.validateProjectRequest,
    27: PiTransportFrame_Operation.validateProjectResponse,
    28: PiTransportFrame_Operation.listKnownProjectsRequest,
    29: PiTransportFrame_Operation.listKnownProjectsResponse,
    30: PiTransportFrame_Operation.listSessionsRequest,
    31: PiTransportFrame_Operation.listSessionsResponse,
    32: PiTransportFrame_Operation.getSessionRequest,
    33: PiTransportFrame_Operation.getSessionResponse,
    34: PiTransportFrame_Operation.createSessionRequest,
    35: PiTransportFrame_Operation.createSessionResponse,
    36: PiTransportFrame_Operation.promptCommand,
    37: PiTransportFrame_Operation.abortCommand,
    38: PiTransportFrame_Operation.requestRejected,
    39: PiTransportFrame_Operation.commandAccepted,
    40: PiTransportFrame_Operation.commandRejected,
    41: PiTransportFrame_Operation.approveProjectTrustRequest,
    42: PiTransportFrame_Operation.approveProjectTrustResponse,
    43: PiTransportFrame_Operation.renameSessionCommand,
    44: PiTransportFrame_Operation.clearSessionNameCommand,
    45: PiTransportFrame_Operation.autoNameSessionCommand,
    46: PiTransportFrame_Operation.deleteSessionCommand,
    47: PiTransportFrame_Operation.sessionAdminCommandOutcome,
    48: PiTransportFrame_Operation.getSessionTreeRequest,
    49: PiTransportFrame_Operation.getSessionTreeResponse,
    50: PiTransportFrame_Operation.sessionEventStream,
    51: PiTransportFrame_Operation.eventStream,
    52: PiTransportFrame_Operation.navigateSessionTreeCommand,
    53: PiTransportFrame_Operation.forkSessionCommand,
    54: PiTransportFrame_Operation.cloneSessionCommand,
    55: PiTransportFrame_Operation.sessionTreeMutationOutcome,
    60: PiTransportFrame_Operation.cancel,
    61: PiTransportFrame_Operation.windowUpdate,
    70: PiTransportFrame_Operation.transferOpen,
    71: PiTransportFrame_Operation.transferChunk,
    72: PiTransportFrame_Operation.transferAck,
    73: PiTransportFrame_Operation.transferComplete,
    74: PiTransportFrame_Operation.transferAbort,
    80: PiTransportFrame_Operation.error,
    0: PiTransportFrame_Operation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PiTransportFrame',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [
      10,
      11,
      12,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31,
      32,
      33,
      34,
      35,
      36,
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
      60,
      61,
      70,
      71,
      72,
      73,
      74,
      80
    ])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'frameSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<ClientProtocolOffer>(10, _omitFieldNames ? '' : 'clientProtocolOffer',
        subBuilder: ClientProtocolOffer.create)
    ..aOM<ServerHandshakeAccepted>(
        11, _omitFieldNames ? '' : 'serverHandshakeAccepted',
        subBuilder: ServerHandshakeAccepted.create)
    ..aOM<ServerHandshakeRejected>(
        12, _omitFieldNames ? '' : 'serverHandshakeRejected',
        subBuilder: ServerHandshakeRejected.create)
    ..aOM<HealthRequest>(20, _omitFieldNames ? '' : 'healthRequest',
        subBuilder: HealthRequest.create)
    ..aOM<HealthResponse>(21, _omitFieldNames ? '' : 'healthResponse',
        subBuilder: HealthResponse.create)
    ..aOM<GetProjectBootstrapRequest>(
        22, _omitFieldNames ? '' : 'getProjectBootstrapRequest',
        subBuilder: GetProjectBootstrapRequest.create)
    ..aOM<GetProjectBootstrapResponse>(
        23, _omitFieldNames ? '' : 'getProjectBootstrapResponse',
        subBuilder: GetProjectBootstrapResponse.create)
    ..aOM<BrowseDirectoryRequest>(
        24, _omitFieldNames ? '' : 'browseDirectoryRequest',
        subBuilder: BrowseDirectoryRequest.create)
    ..aOM<BrowseDirectoryResponse>(
        25, _omitFieldNames ? '' : 'browseDirectoryResponse',
        subBuilder: BrowseDirectoryResponse.create)
    ..aOM<ValidateProjectRequest>(
        26, _omitFieldNames ? '' : 'validateProjectRequest',
        subBuilder: ValidateProjectRequest.create)
    ..aOM<ValidateProjectResponse>(
        27, _omitFieldNames ? '' : 'validateProjectResponse',
        subBuilder: ValidateProjectResponse.create)
    ..aOM<ListKnownProjectsRequest>(
        28, _omitFieldNames ? '' : 'listKnownProjectsRequest',
        subBuilder: ListKnownProjectsRequest.create)
    ..aOM<ListKnownProjectsResponse>(
        29, _omitFieldNames ? '' : 'listKnownProjectsResponse',
        subBuilder: ListKnownProjectsResponse.create)
    ..aOM<ListSessionsRequest>(30, _omitFieldNames ? '' : 'listSessionsRequest',
        subBuilder: ListSessionsRequest.create)
    ..aOM<ListSessionsResponse>(
        31, _omitFieldNames ? '' : 'listSessionsResponse',
        subBuilder: ListSessionsResponse.create)
    ..aOM<GetSessionRequest>(32, _omitFieldNames ? '' : 'getSessionRequest',
        subBuilder: GetSessionRequest.create)
    ..aOM<GetSessionResponse>(33, _omitFieldNames ? '' : 'getSessionResponse',
        subBuilder: GetSessionResponse.create)
    ..aOM<CreateSessionRequest>(
        34, _omitFieldNames ? '' : 'createSessionRequest',
        subBuilder: CreateSessionRequest.create)
    ..aOM<CreateSessionResponse>(
        35, _omitFieldNames ? '' : 'createSessionResponse',
        subBuilder: CreateSessionResponse.create)
    ..aOM<PromptCommand>(36, _omitFieldNames ? '' : 'promptCommand',
        subBuilder: PromptCommand.create)
    ..aOM<AbortCommand>(37, _omitFieldNames ? '' : 'abortCommand',
        subBuilder: AbortCommand.create)
    ..aOM<RequestRejected>(38, _omitFieldNames ? '' : 'requestRejected',
        subBuilder: RequestRejected.create)
    ..aOM<CommandAccepted>(39, _omitFieldNames ? '' : 'commandAccepted',
        subBuilder: CommandAccepted.create)
    ..aOM<CommandRejected>(40, _omitFieldNames ? '' : 'commandRejected',
        subBuilder: CommandRejected.create)
    ..aOM<ApproveProjectTrustRequest>(
        41, _omitFieldNames ? '' : 'approveProjectTrustRequest',
        subBuilder: ApproveProjectTrustRequest.create)
    ..aOM<ApproveProjectTrustResponse>(
        42, _omitFieldNames ? '' : 'approveProjectTrustResponse',
        subBuilder: ApproveProjectTrustResponse.create)
    ..aOM<RenameSessionCommand>(
        43, _omitFieldNames ? '' : 'renameSessionCommand',
        subBuilder: RenameSessionCommand.create)
    ..aOM<ClearSessionNameCommand>(
        44, _omitFieldNames ? '' : 'clearSessionNameCommand',
        subBuilder: ClearSessionNameCommand.create)
    ..aOM<AutoNameSessionCommand>(
        45, _omitFieldNames ? '' : 'autoNameSessionCommand',
        subBuilder: AutoNameSessionCommand.create)
    ..aOM<DeleteSessionCommand>(
        46, _omitFieldNames ? '' : 'deleteSessionCommand',
        subBuilder: DeleteSessionCommand.create)
    ..aOM<SessionAdminCommandOutcome>(
        47, _omitFieldNames ? '' : 'sessionAdminCommandOutcome',
        subBuilder: SessionAdminCommandOutcome.create)
    ..aOM<GetSessionTreeRequest>(
        48, _omitFieldNames ? '' : 'getSessionTreeRequest',
        subBuilder: GetSessionTreeRequest.create)
    ..aOM<GetSessionTreeResponse>(
        49, _omitFieldNames ? '' : 'getSessionTreeResponse',
        subBuilder: GetSessionTreeResponse.create)
    ..aOM<SessionEventStreamEnvelope>(
        50, _omitFieldNames ? '' : 'sessionEventStream',
        subBuilder: SessionEventStreamEnvelope.create)
    ..aOM<EventStreamEnvelope>(51, _omitFieldNames ? '' : 'eventStream',
        subBuilder: EventStreamEnvelope.create)
    ..aOM<NavigateSessionTreeCommand>(
        52, _omitFieldNames ? '' : 'navigateSessionTreeCommand',
        subBuilder: NavigateSessionTreeCommand.create)
    ..aOM<ForkSessionCommand>(53, _omitFieldNames ? '' : 'forkSessionCommand',
        subBuilder: ForkSessionCommand.create)
    ..aOM<CloneSessionCommand>(54, _omitFieldNames ? '' : 'cloneSessionCommand',
        subBuilder: CloneSessionCommand.create)
    ..aOM<SessionTreeMutationOutcome>(
        55, _omitFieldNames ? '' : 'sessionTreeMutationOutcome',
        subBuilder: SessionTreeMutationOutcome.create)
    ..aOM<Cancel>(60, _omitFieldNames ? '' : 'cancel',
        subBuilder: Cancel.create)
    ..aOM<WindowUpdate>(61, _omitFieldNames ? '' : 'windowUpdate',
        subBuilder: WindowUpdate.create)
    ..aOM<TransferOpen>(70, _omitFieldNames ? '' : 'transferOpen',
        subBuilder: TransferOpen.create)
    ..aOM<TransferChunk>(71, _omitFieldNames ? '' : 'transferChunk',
        subBuilder: TransferChunk.create)
    ..aOM<TransferAck>(72, _omitFieldNames ? '' : 'transferAck',
        subBuilder: TransferAck.create)
    ..aOM<TransferComplete>(73, _omitFieldNames ? '' : 'transferComplete',
        subBuilder: TransferComplete.create)
    ..aOM<TransferAbort>(74, _omitFieldNames ? '' : 'transferAbort',
        subBuilder: TransferAbort.create)
    ..aOM<ErrorEnvelope>(80, _omitFieldNames ? '' : 'error',
        subBuilder: ErrorEnvelope.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PiTransportFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PiTransportFrame copyWith(void Function(PiTransportFrame) updates) =>
      super.copyWith((message) => updates(message as PiTransportFrame))
          as PiTransportFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PiTransportFrame create() => PiTransportFrame._();
  @$core.override
  PiTransportFrame createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PiTransportFrame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PiTransportFrame>(create);
  static PiTransportFrame? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  @$pb.TagNumber(32)
  @$pb.TagNumber(33)
  @$pb.TagNumber(34)
  @$pb.TagNumber(35)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  @$pb.TagNumber(38)
  @$pb.TagNumber(39)
  @$pb.TagNumber(40)
  @$pb.TagNumber(41)
  @$pb.TagNumber(42)
  @$pb.TagNumber(43)
  @$pb.TagNumber(44)
  @$pb.TagNumber(45)
  @$pb.TagNumber(46)
  @$pb.TagNumber(47)
  @$pb.TagNumber(48)
  @$pb.TagNumber(49)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
  @$pb.TagNumber(52)
  @$pb.TagNumber(53)
  @$pb.TagNumber(54)
  @$pb.TagNumber(55)
  @$pb.TagNumber(60)
  @$pb.TagNumber(61)
  @$pb.TagNumber(70)
  @$pb.TagNumber(71)
  @$pb.TagNumber(72)
  @$pb.TagNumber(73)
  @$pb.TagNumber(74)
  @$pb.TagNumber(80)
  PiTransportFrame_Operation whichOperation() =>
      _PiTransportFrame_OperationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  @$pb.TagNumber(32)
  @$pb.TagNumber(33)
  @$pb.TagNumber(34)
  @$pb.TagNumber(35)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  @$pb.TagNumber(38)
  @$pb.TagNumber(39)
  @$pb.TagNumber(40)
  @$pb.TagNumber(41)
  @$pb.TagNumber(42)
  @$pb.TagNumber(43)
  @$pb.TagNumber(44)
  @$pb.TagNumber(45)
  @$pb.TagNumber(46)
  @$pb.TagNumber(47)
  @$pb.TagNumber(48)
  @$pb.TagNumber(49)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
  @$pb.TagNumber(52)
  @$pb.TagNumber(53)
  @$pb.TagNumber(54)
  @$pb.TagNumber(55)
  @$pb.TagNumber(60)
  @$pb.TagNumber(61)
  @$pb.TagNumber(70)
  @$pb.TagNumber(71)
  @$pb.TagNumber(72)
  @$pb.TagNumber(73)
  @$pb.TagNumber(74)
  @$pb.TagNumber(80)
  void clearOperation() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get frameSequence => $_getI64(0);
  @$pb.TagNumber(1)
  set frameSequence($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrameSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrameSequence() => $_clearField(1);

  @$pb.TagNumber(10)
  ClientProtocolOffer get clientProtocolOffer => $_getN(1);
  @$pb.TagNumber(10)
  set clientProtocolOffer(ClientProtocolOffer value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasClientProtocolOffer() => $_has(1);
  @$pb.TagNumber(10)
  void clearClientProtocolOffer() => $_clearField(10);
  @$pb.TagNumber(10)
  ClientProtocolOffer ensureClientProtocolOffer() => $_ensure(1);

  @$pb.TagNumber(11)
  ServerHandshakeAccepted get serverHandshakeAccepted => $_getN(2);
  @$pb.TagNumber(11)
  set serverHandshakeAccepted(ServerHandshakeAccepted value) =>
      $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasServerHandshakeAccepted() => $_has(2);
  @$pb.TagNumber(11)
  void clearServerHandshakeAccepted() => $_clearField(11);
  @$pb.TagNumber(11)
  ServerHandshakeAccepted ensureServerHandshakeAccepted() => $_ensure(2);

  @$pb.TagNumber(12)
  ServerHandshakeRejected get serverHandshakeRejected => $_getN(3);
  @$pb.TagNumber(12)
  set serverHandshakeRejected(ServerHandshakeRejected value) =>
      $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasServerHandshakeRejected() => $_has(3);
  @$pb.TagNumber(12)
  void clearServerHandshakeRejected() => $_clearField(12);
  @$pb.TagNumber(12)
  ServerHandshakeRejected ensureServerHandshakeRejected() => $_ensure(3);

  @$pb.TagNumber(20)
  HealthRequest get healthRequest => $_getN(4);
  @$pb.TagNumber(20)
  set healthRequest(HealthRequest value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasHealthRequest() => $_has(4);
  @$pb.TagNumber(20)
  void clearHealthRequest() => $_clearField(20);
  @$pb.TagNumber(20)
  HealthRequest ensureHealthRequest() => $_ensure(4);

  @$pb.TagNumber(21)
  HealthResponse get healthResponse => $_getN(5);
  @$pb.TagNumber(21)
  set healthResponse(HealthResponse value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasHealthResponse() => $_has(5);
  @$pb.TagNumber(21)
  void clearHealthResponse() => $_clearField(21);
  @$pb.TagNumber(21)
  HealthResponse ensureHealthResponse() => $_ensure(5);

  @$pb.TagNumber(22)
  GetProjectBootstrapRequest get getProjectBootstrapRequest => $_getN(6);
  @$pb.TagNumber(22)
  set getProjectBootstrapRequest(GetProjectBootstrapRequest value) =>
      $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasGetProjectBootstrapRequest() => $_has(6);
  @$pb.TagNumber(22)
  void clearGetProjectBootstrapRequest() => $_clearField(22);
  @$pb.TagNumber(22)
  GetProjectBootstrapRequest ensureGetProjectBootstrapRequest() => $_ensure(6);

  @$pb.TagNumber(23)
  GetProjectBootstrapResponse get getProjectBootstrapResponse => $_getN(7);
  @$pb.TagNumber(23)
  set getProjectBootstrapResponse(GetProjectBootstrapResponse value) =>
      $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasGetProjectBootstrapResponse() => $_has(7);
  @$pb.TagNumber(23)
  void clearGetProjectBootstrapResponse() => $_clearField(23);
  @$pb.TagNumber(23)
  GetProjectBootstrapResponse ensureGetProjectBootstrapResponse() =>
      $_ensure(7);

  @$pb.TagNumber(24)
  BrowseDirectoryRequest get browseDirectoryRequest => $_getN(8);
  @$pb.TagNumber(24)
  set browseDirectoryRequest(BrowseDirectoryRequest value) =>
      $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasBrowseDirectoryRequest() => $_has(8);
  @$pb.TagNumber(24)
  void clearBrowseDirectoryRequest() => $_clearField(24);
  @$pb.TagNumber(24)
  BrowseDirectoryRequest ensureBrowseDirectoryRequest() => $_ensure(8);

  @$pb.TagNumber(25)
  BrowseDirectoryResponse get browseDirectoryResponse => $_getN(9);
  @$pb.TagNumber(25)
  set browseDirectoryResponse(BrowseDirectoryResponse value) =>
      $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasBrowseDirectoryResponse() => $_has(9);
  @$pb.TagNumber(25)
  void clearBrowseDirectoryResponse() => $_clearField(25);
  @$pb.TagNumber(25)
  BrowseDirectoryResponse ensureBrowseDirectoryResponse() => $_ensure(9);

  @$pb.TagNumber(26)
  ValidateProjectRequest get validateProjectRequest => $_getN(10);
  @$pb.TagNumber(26)
  set validateProjectRequest(ValidateProjectRequest value) =>
      $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasValidateProjectRequest() => $_has(10);
  @$pb.TagNumber(26)
  void clearValidateProjectRequest() => $_clearField(26);
  @$pb.TagNumber(26)
  ValidateProjectRequest ensureValidateProjectRequest() => $_ensure(10);

  @$pb.TagNumber(27)
  ValidateProjectResponse get validateProjectResponse => $_getN(11);
  @$pb.TagNumber(27)
  set validateProjectResponse(ValidateProjectResponse value) =>
      $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasValidateProjectResponse() => $_has(11);
  @$pb.TagNumber(27)
  void clearValidateProjectResponse() => $_clearField(27);
  @$pb.TagNumber(27)
  ValidateProjectResponse ensureValidateProjectResponse() => $_ensure(11);

  @$pb.TagNumber(28)
  ListKnownProjectsRequest get listKnownProjectsRequest => $_getN(12);
  @$pb.TagNumber(28)
  set listKnownProjectsRequest(ListKnownProjectsRequest value) =>
      $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasListKnownProjectsRequest() => $_has(12);
  @$pb.TagNumber(28)
  void clearListKnownProjectsRequest() => $_clearField(28);
  @$pb.TagNumber(28)
  ListKnownProjectsRequest ensureListKnownProjectsRequest() => $_ensure(12);

  @$pb.TagNumber(29)
  ListKnownProjectsResponse get listKnownProjectsResponse => $_getN(13);
  @$pb.TagNumber(29)
  set listKnownProjectsResponse(ListKnownProjectsResponse value) =>
      $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasListKnownProjectsResponse() => $_has(13);
  @$pb.TagNumber(29)
  void clearListKnownProjectsResponse() => $_clearField(29);
  @$pb.TagNumber(29)
  ListKnownProjectsResponse ensureListKnownProjectsResponse() => $_ensure(13);

  @$pb.TagNumber(30)
  ListSessionsRequest get listSessionsRequest => $_getN(14);
  @$pb.TagNumber(30)
  set listSessionsRequest(ListSessionsRequest value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasListSessionsRequest() => $_has(14);
  @$pb.TagNumber(30)
  void clearListSessionsRequest() => $_clearField(30);
  @$pb.TagNumber(30)
  ListSessionsRequest ensureListSessionsRequest() => $_ensure(14);

  @$pb.TagNumber(31)
  ListSessionsResponse get listSessionsResponse => $_getN(15);
  @$pb.TagNumber(31)
  set listSessionsResponse(ListSessionsResponse value) => $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasListSessionsResponse() => $_has(15);
  @$pb.TagNumber(31)
  void clearListSessionsResponse() => $_clearField(31);
  @$pb.TagNumber(31)
  ListSessionsResponse ensureListSessionsResponse() => $_ensure(15);

  @$pb.TagNumber(32)
  GetSessionRequest get getSessionRequest => $_getN(16);
  @$pb.TagNumber(32)
  set getSessionRequest(GetSessionRequest value) => $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasGetSessionRequest() => $_has(16);
  @$pb.TagNumber(32)
  void clearGetSessionRequest() => $_clearField(32);
  @$pb.TagNumber(32)
  GetSessionRequest ensureGetSessionRequest() => $_ensure(16);

  @$pb.TagNumber(33)
  GetSessionResponse get getSessionResponse => $_getN(17);
  @$pb.TagNumber(33)
  set getSessionResponse(GetSessionResponse value) => $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasGetSessionResponse() => $_has(17);
  @$pb.TagNumber(33)
  void clearGetSessionResponse() => $_clearField(33);
  @$pb.TagNumber(33)
  GetSessionResponse ensureGetSessionResponse() => $_ensure(17);

  @$pb.TagNumber(34)
  CreateSessionRequest get createSessionRequest => $_getN(18);
  @$pb.TagNumber(34)
  set createSessionRequest(CreateSessionRequest value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasCreateSessionRequest() => $_has(18);
  @$pb.TagNumber(34)
  void clearCreateSessionRequest() => $_clearField(34);
  @$pb.TagNumber(34)
  CreateSessionRequest ensureCreateSessionRequest() => $_ensure(18);

  @$pb.TagNumber(35)
  CreateSessionResponse get createSessionResponse => $_getN(19);
  @$pb.TagNumber(35)
  set createSessionResponse(CreateSessionResponse value) =>
      $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasCreateSessionResponse() => $_has(19);
  @$pb.TagNumber(35)
  void clearCreateSessionResponse() => $_clearField(35);
  @$pb.TagNumber(35)
  CreateSessionResponse ensureCreateSessionResponse() => $_ensure(19);

  @$pb.TagNumber(36)
  PromptCommand get promptCommand => $_getN(20);
  @$pb.TagNumber(36)
  set promptCommand(PromptCommand value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasPromptCommand() => $_has(20);
  @$pb.TagNumber(36)
  void clearPromptCommand() => $_clearField(36);
  @$pb.TagNumber(36)
  PromptCommand ensurePromptCommand() => $_ensure(20);

  @$pb.TagNumber(37)
  AbortCommand get abortCommand => $_getN(21);
  @$pb.TagNumber(37)
  set abortCommand(AbortCommand value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasAbortCommand() => $_has(21);
  @$pb.TagNumber(37)
  void clearAbortCommand() => $_clearField(37);
  @$pb.TagNumber(37)
  AbortCommand ensureAbortCommand() => $_ensure(21);

  @$pb.TagNumber(38)
  RequestRejected get requestRejected => $_getN(22);
  @$pb.TagNumber(38)
  set requestRejected(RequestRejected value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasRequestRejected() => $_has(22);
  @$pb.TagNumber(38)
  void clearRequestRejected() => $_clearField(38);
  @$pb.TagNumber(38)
  RequestRejected ensureRequestRejected() => $_ensure(22);

  @$pb.TagNumber(39)
  CommandAccepted get commandAccepted => $_getN(23);
  @$pb.TagNumber(39)
  set commandAccepted(CommandAccepted value) => $_setField(39, value);
  @$pb.TagNumber(39)
  $core.bool hasCommandAccepted() => $_has(23);
  @$pb.TagNumber(39)
  void clearCommandAccepted() => $_clearField(39);
  @$pb.TagNumber(39)
  CommandAccepted ensureCommandAccepted() => $_ensure(23);

  @$pb.TagNumber(40)
  CommandRejected get commandRejected => $_getN(24);
  @$pb.TagNumber(40)
  set commandRejected(CommandRejected value) => $_setField(40, value);
  @$pb.TagNumber(40)
  $core.bool hasCommandRejected() => $_has(24);
  @$pb.TagNumber(40)
  void clearCommandRejected() => $_clearField(40);
  @$pb.TagNumber(40)
  CommandRejected ensureCommandRejected() => $_ensure(24);

  @$pb.TagNumber(41)
  ApproveProjectTrustRequest get approveProjectTrustRequest => $_getN(25);
  @$pb.TagNumber(41)
  set approveProjectTrustRequest(ApproveProjectTrustRequest value) =>
      $_setField(41, value);
  @$pb.TagNumber(41)
  $core.bool hasApproveProjectTrustRequest() => $_has(25);
  @$pb.TagNumber(41)
  void clearApproveProjectTrustRequest() => $_clearField(41);
  @$pb.TagNumber(41)
  ApproveProjectTrustRequest ensureApproveProjectTrustRequest() => $_ensure(25);

  @$pb.TagNumber(42)
  ApproveProjectTrustResponse get approveProjectTrustResponse => $_getN(26);
  @$pb.TagNumber(42)
  set approveProjectTrustResponse(ApproveProjectTrustResponse value) =>
      $_setField(42, value);
  @$pb.TagNumber(42)
  $core.bool hasApproveProjectTrustResponse() => $_has(26);
  @$pb.TagNumber(42)
  void clearApproveProjectTrustResponse() => $_clearField(42);
  @$pb.TagNumber(42)
  ApproveProjectTrustResponse ensureApproveProjectTrustResponse() =>
      $_ensure(26);

  @$pb.TagNumber(43)
  RenameSessionCommand get renameSessionCommand => $_getN(27);
  @$pb.TagNumber(43)
  set renameSessionCommand(RenameSessionCommand value) => $_setField(43, value);
  @$pb.TagNumber(43)
  $core.bool hasRenameSessionCommand() => $_has(27);
  @$pb.TagNumber(43)
  void clearRenameSessionCommand() => $_clearField(43);
  @$pb.TagNumber(43)
  RenameSessionCommand ensureRenameSessionCommand() => $_ensure(27);

  @$pb.TagNumber(44)
  ClearSessionNameCommand get clearSessionNameCommand => $_getN(28);
  @$pb.TagNumber(44)
  set clearSessionNameCommand(ClearSessionNameCommand value) =>
      $_setField(44, value);
  @$pb.TagNumber(44)
  $core.bool hasClearSessionNameCommand() => $_has(28);
  @$pb.TagNumber(44)
  void clearClearSessionNameCommand() => $_clearField(44);
  @$pb.TagNumber(44)
  ClearSessionNameCommand ensureClearSessionNameCommand() => $_ensure(28);

  @$pb.TagNumber(45)
  AutoNameSessionCommand get autoNameSessionCommand => $_getN(29);
  @$pb.TagNumber(45)
  set autoNameSessionCommand(AutoNameSessionCommand value) =>
      $_setField(45, value);
  @$pb.TagNumber(45)
  $core.bool hasAutoNameSessionCommand() => $_has(29);
  @$pb.TagNumber(45)
  void clearAutoNameSessionCommand() => $_clearField(45);
  @$pb.TagNumber(45)
  AutoNameSessionCommand ensureAutoNameSessionCommand() => $_ensure(29);

  @$pb.TagNumber(46)
  DeleteSessionCommand get deleteSessionCommand => $_getN(30);
  @$pb.TagNumber(46)
  set deleteSessionCommand(DeleteSessionCommand value) => $_setField(46, value);
  @$pb.TagNumber(46)
  $core.bool hasDeleteSessionCommand() => $_has(30);
  @$pb.TagNumber(46)
  void clearDeleteSessionCommand() => $_clearField(46);
  @$pb.TagNumber(46)
  DeleteSessionCommand ensureDeleteSessionCommand() => $_ensure(30);

  @$pb.TagNumber(47)
  SessionAdminCommandOutcome get sessionAdminCommandOutcome => $_getN(31);
  @$pb.TagNumber(47)
  set sessionAdminCommandOutcome(SessionAdminCommandOutcome value) =>
      $_setField(47, value);
  @$pb.TagNumber(47)
  $core.bool hasSessionAdminCommandOutcome() => $_has(31);
  @$pb.TagNumber(47)
  void clearSessionAdminCommandOutcome() => $_clearField(47);
  @$pb.TagNumber(47)
  SessionAdminCommandOutcome ensureSessionAdminCommandOutcome() => $_ensure(31);

  @$pb.TagNumber(48)
  GetSessionTreeRequest get getSessionTreeRequest => $_getN(32);
  @$pb.TagNumber(48)
  set getSessionTreeRequest(GetSessionTreeRequest value) =>
      $_setField(48, value);
  @$pb.TagNumber(48)
  $core.bool hasGetSessionTreeRequest() => $_has(32);
  @$pb.TagNumber(48)
  void clearGetSessionTreeRequest() => $_clearField(48);
  @$pb.TagNumber(48)
  GetSessionTreeRequest ensureGetSessionTreeRequest() => $_ensure(32);

  @$pb.TagNumber(49)
  GetSessionTreeResponse get getSessionTreeResponse => $_getN(33);
  @$pb.TagNumber(49)
  set getSessionTreeResponse(GetSessionTreeResponse value) =>
      $_setField(49, value);
  @$pb.TagNumber(49)
  $core.bool hasGetSessionTreeResponse() => $_has(33);
  @$pb.TagNumber(49)
  void clearGetSessionTreeResponse() => $_clearField(49);
  @$pb.TagNumber(49)
  GetSessionTreeResponse ensureGetSessionTreeResponse() => $_ensure(33);

  @$pb.TagNumber(50)
  SessionEventStreamEnvelope get sessionEventStream => $_getN(34);
  @$pb.TagNumber(50)
  set sessionEventStream(SessionEventStreamEnvelope value) =>
      $_setField(50, value);
  @$pb.TagNumber(50)
  $core.bool hasSessionEventStream() => $_has(34);
  @$pb.TagNumber(50)
  void clearSessionEventStream() => $_clearField(50);
  @$pb.TagNumber(50)
  SessionEventStreamEnvelope ensureSessionEventStream() => $_ensure(34);

  @$pb.TagNumber(51)
  EventStreamEnvelope get eventStream => $_getN(35);
  @$pb.TagNumber(51)
  set eventStream(EventStreamEnvelope value) => $_setField(51, value);
  @$pb.TagNumber(51)
  $core.bool hasEventStream() => $_has(35);
  @$pb.TagNumber(51)
  void clearEventStream() => $_clearField(51);
  @$pb.TagNumber(51)
  EventStreamEnvelope ensureEventStream() => $_ensure(35);

  @$pb.TagNumber(52)
  NavigateSessionTreeCommand get navigateSessionTreeCommand => $_getN(36);
  @$pb.TagNumber(52)
  set navigateSessionTreeCommand(NavigateSessionTreeCommand value) =>
      $_setField(52, value);
  @$pb.TagNumber(52)
  $core.bool hasNavigateSessionTreeCommand() => $_has(36);
  @$pb.TagNumber(52)
  void clearNavigateSessionTreeCommand() => $_clearField(52);
  @$pb.TagNumber(52)
  NavigateSessionTreeCommand ensureNavigateSessionTreeCommand() => $_ensure(36);

  @$pb.TagNumber(53)
  ForkSessionCommand get forkSessionCommand => $_getN(37);
  @$pb.TagNumber(53)
  set forkSessionCommand(ForkSessionCommand value) => $_setField(53, value);
  @$pb.TagNumber(53)
  $core.bool hasForkSessionCommand() => $_has(37);
  @$pb.TagNumber(53)
  void clearForkSessionCommand() => $_clearField(53);
  @$pb.TagNumber(53)
  ForkSessionCommand ensureForkSessionCommand() => $_ensure(37);

  @$pb.TagNumber(54)
  CloneSessionCommand get cloneSessionCommand => $_getN(38);
  @$pb.TagNumber(54)
  set cloneSessionCommand(CloneSessionCommand value) => $_setField(54, value);
  @$pb.TagNumber(54)
  $core.bool hasCloneSessionCommand() => $_has(38);
  @$pb.TagNumber(54)
  void clearCloneSessionCommand() => $_clearField(54);
  @$pb.TagNumber(54)
  CloneSessionCommand ensureCloneSessionCommand() => $_ensure(38);

  @$pb.TagNumber(55)
  SessionTreeMutationOutcome get sessionTreeMutationOutcome => $_getN(39);
  @$pb.TagNumber(55)
  set sessionTreeMutationOutcome(SessionTreeMutationOutcome value) =>
      $_setField(55, value);
  @$pb.TagNumber(55)
  $core.bool hasSessionTreeMutationOutcome() => $_has(39);
  @$pb.TagNumber(55)
  void clearSessionTreeMutationOutcome() => $_clearField(55);
  @$pb.TagNumber(55)
  SessionTreeMutationOutcome ensureSessionTreeMutationOutcome() => $_ensure(39);

  @$pb.TagNumber(60)
  Cancel get cancel => $_getN(40);
  @$pb.TagNumber(60)
  set cancel(Cancel value) => $_setField(60, value);
  @$pb.TagNumber(60)
  $core.bool hasCancel() => $_has(40);
  @$pb.TagNumber(60)
  void clearCancel() => $_clearField(60);
  @$pb.TagNumber(60)
  Cancel ensureCancel() => $_ensure(40);

  @$pb.TagNumber(61)
  WindowUpdate get windowUpdate => $_getN(41);
  @$pb.TagNumber(61)
  set windowUpdate(WindowUpdate value) => $_setField(61, value);
  @$pb.TagNumber(61)
  $core.bool hasWindowUpdate() => $_has(41);
  @$pb.TagNumber(61)
  void clearWindowUpdate() => $_clearField(61);
  @$pb.TagNumber(61)
  WindowUpdate ensureWindowUpdate() => $_ensure(41);

  @$pb.TagNumber(70)
  TransferOpen get transferOpen => $_getN(42);
  @$pb.TagNumber(70)
  set transferOpen(TransferOpen value) => $_setField(70, value);
  @$pb.TagNumber(70)
  $core.bool hasTransferOpen() => $_has(42);
  @$pb.TagNumber(70)
  void clearTransferOpen() => $_clearField(70);
  @$pb.TagNumber(70)
  TransferOpen ensureTransferOpen() => $_ensure(42);

  @$pb.TagNumber(71)
  TransferChunk get transferChunk => $_getN(43);
  @$pb.TagNumber(71)
  set transferChunk(TransferChunk value) => $_setField(71, value);
  @$pb.TagNumber(71)
  $core.bool hasTransferChunk() => $_has(43);
  @$pb.TagNumber(71)
  void clearTransferChunk() => $_clearField(71);
  @$pb.TagNumber(71)
  TransferChunk ensureTransferChunk() => $_ensure(43);

  @$pb.TagNumber(72)
  TransferAck get transferAck => $_getN(44);
  @$pb.TagNumber(72)
  set transferAck(TransferAck value) => $_setField(72, value);
  @$pb.TagNumber(72)
  $core.bool hasTransferAck() => $_has(44);
  @$pb.TagNumber(72)
  void clearTransferAck() => $_clearField(72);
  @$pb.TagNumber(72)
  TransferAck ensureTransferAck() => $_ensure(44);

  @$pb.TagNumber(73)
  TransferComplete get transferComplete => $_getN(45);
  @$pb.TagNumber(73)
  set transferComplete(TransferComplete value) => $_setField(73, value);
  @$pb.TagNumber(73)
  $core.bool hasTransferComplete() => $_has(45);
  @$pb.TagNumber(73)
  void clearTransferComplete() => $_clearField(73);
  @$pb.TagNumber(73)
  TransferComplete ensureTransferComplete() => $_ensure(45);

  @$pb.TagNumber(74)
  TransferAbort get transferAbort => $_getN(46);
  @$pb.TagNumber(74)
  set transferAbort(TransferAbort value) => $_setField(74, value);
  @$pb.TagNumber(74)
  $core.bool hasTransferAbort() => $_has(46);
  @$pb.TagNumber(74)
  void clearTransferAbort() => $_clearField(74);
  @$pb.TagNumber(74)
  TransferAbort ensureTransferAbort() => $_ensure(46);

  @$pb.TagNumber(80)
  ErrorEnvelope get error => $_getN(47);
  @$pb.TagNumber(80)
  set error(ErrorEnvelope value) => $_setField(80, value);
  @$pb.TagNumber(80)
  $core.bool hasError() => $_has(47);
  @$pb.TagNumber(80)
  void clearError() => $_clearField(80);
  @$pb.TagNumber(80)
  ErrorEnvelope ensureError() => $_ensure(47);
}

/// ProtocolVersion is the numeric SemVer core used for exact wire negotiation.
/// The v0 package accepts only major zero. Prerelease and build identifiers are
/// intentionally not part of protocol identity.
class ProtocolVersion extends $pb.GeneratedMessage {
  factory ProtocolVersion({
    $core.int? major,
    $core.int? minor,
    $core.int? patch,
  }) {
    final result = create();
    if (major != null) result.major = major;
    if (minor != null) result.minor = minor;
    if (patch != null) result.patch = patch;
    return result;
  }

  ProtocolVersion._();

  factory ProtocolVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProtocolVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProtocolVersion',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'major', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'minor', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'patch', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtocolVersion copyWith(void Function(ProtocolVersion) updates) =>
      super.copyWith((message) => updates(message as ProtocolVersion))
          as ProtocolVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProtocolVersion create() => ProtocolVersion._();
  @$core.override
  ProtocolVersion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProtocolVersion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProtocolVersion>(create);
  static ProtocolVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get major => $_getIZ(0);
  @$pb.TagNumber(1)
  set major($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMajor() => $_has(0);
  @$pb.TagNumber(1)
  void clearMajor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minor => $_getIZ(1);
  @$pb.TagNumber(2)
  set minor($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinor() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get patch => $_getIZ(2);
  @$pb.TagNumber(3)
  set patch($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPatch() => $_has(2);
  @$pb.TagNumber(3)
  void clearPatch() => $_clearField(3);
}

/// protocol_versions is ordered by client preference. The server selects one
/// exact offered version and a subset of the advertised capabilities.
class ClientProtocolOffer extends $pb.GeneratedMessage {
  factory ClientProtocolOffer({
    $core.Iterable<ProtocolVersion>? protocolVersions,
    $core.Iterable<Capability>? capabilities,
    $core.String? clientInstanceId,
    $core.String? implementationName,
    $core.String? implementationVersion,
    $core.int? maxFrameBytes,
    $core.int? maxTransferChunkBytes,
  }) {
    final result = create();
    if (protocolVersions != null)
      result.protocolVersions.addAll(protocolVersions);
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (clientInstanceId != null) result.clientInstanceId = clientInstanceId;
    if (implementationName != null)
      result.implementationName = implementationName;
    if (implementationVersion != null)
      result.implementationVersion = implementationVersion;
    if (maxFrameBytes != null) result.maxFrameBytes = maxFrameBytes;
    if (maxTransferChunkBytes != null)
      result.maxTransferChunkBytes = maxTransferChunkBytes;
    return result;
  }

  ClientProtocolOffer._();

  factory ClientProtocolOffer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientProtocolOffer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientProtocolOffer',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..pPM<ProtocolVersion>(1, _omitFieldNames ? '' : 'protocolVersions',
        subBuilder: ProtocolVersion.create)
    ..pc<Capability>(
        2, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..aOS(3, _omitFieldNames ? '' : 'clientInstanceId')
    ..aOS(4, _omitFieldNames ? '' : 'implementationName')
    ..aOS(5, _omitFieldNames ? '' : 'implementationVersion')
    ..aI(6, _omitFieldNames ? '' : 'maxFrameBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'maxTransferChunkBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProtocolOffer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientProtocolOffer copyWith(void Function(ClientProtocolOffer) updates) =>
      super.copyWith((message) => updates(message as ClientProtocolOffer))
          as ClientProtocolOffer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientProtocolOffer create() => ClientProtocolOffer._();
  @$core.override
  ClientProtocolOffer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientProtocolOffer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientProtocolOffer>(create);
  static ClientProtocolOffer? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProtocolVersion> get protocolVersions => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Capability> get capabilities => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get clientInstanceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientInstanceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientInstanceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientInstanceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get implementationName => $_getSZ(3);
  @$pb.TagNumber(4)
  set implementationName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImplementationName() => $_has(3);
  @$pb.TagNumber(4)
  void clearImplementationName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get implementationVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set implementationVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasImplementationVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearImplementationVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxFrameBytes => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxFrameBytes($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxFrameBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxFrameBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxTransferChunkBytes => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxTransferChunkBytes($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxTransferChunkBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxTransferChunkBytes() => $_clearField(7);
}

class ServerHandshakeAccepted extends $pb.GeneratedMessage {
  factory ServerHandshakeAccepted({
    ProtocolVersion? selectedProtocolVersion,
    $core.Iterable<Capability>? capabilities,
    $core.String? nodeInstanceId,
    $core.String? implementationName,
    $core.String? implementationVersion,
    $core.int? maxFrameBytes,
    $core.int? maxTransferChunkBytes,
  }) {
    final result = create();
    if (selectedProtocolVersion != null)
      result.selectedProtocolVersion = selectedProtocolVersion;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (nodeInstanceId != null) result.nodeInstanceId = nodeInstanceId;
    if (implementationName != null)
      result.implementationName = implementationName;
    if (implementationVersion != null)
      result.implementationVersion = implementationVersion;
    if (maxFrameBytes != null) result.maxFrameBytes = maxFrameBytes;
    if (maxTransferChunkBytes != null)
      result.maxTransferChunkBytes = maxTransferChunkBytes;
    return result;
  }

  ServerHandshakeAccepted._();

  factory ServerHandshakeAccepted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerHandshakeAccepted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerHandshakeAccepted',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<ProtocolVersion>(1, _omitFieldNames ? '' : 'selectedProtocolVersion',
        subBuilder: ProtocolVersion.create)
    ..pc<Capability>(
        2, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..aOS(3, _omitFieldNames ? '' : 'nodeInstanceId')
    ..aOS(4, _omitFieldNames ? '' : 'implementationName')
    ..aOS(5, _omitFieldNames ? '' : 'implementationVersion')
    ..aI(6, _omitFieldNames ? '' : 'maxFrameBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'maxTransferChunkBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHandshakeAccepted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHandshakeAccepted copyWith(
          void Function(ServerHandshakeAccepted) updates) =>
      super.copyWith((message) => updates(message as ServerHandshakeAccepted))
          as ServerHandshakeAccepted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerHandshakeAccepted create() => ServerHandshakeAccepted._();
  @$core.override
  ServerHandshakeAccepted createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerHandshakeAccepted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerHandshakeAccepted>(create);
  static ServerHandshakeAccepted? _defaultInstance;

  @$pb.TagNumber(1)
  ProtocolVersion get selectedProtocolVersion => $_getN(0);
  @$pb.TagNumber(1)
  set selectedProtocolVersion(ProtocolVersion value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSelectedProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSelectedProtocolVersion() => $_clearField(1);
  @$pb.TagNumber(1)
  ProtocolVersion ensureSelectedProtocolVersion() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Capability> get capabilities => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get nodeInstanceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeInstanceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeInstanceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeInstanceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get implementationName => $_getSZ(3);
  @$pb.TagNumber(4)
  set implementationName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImplementationName() => $_has(3);
  @$pb.TagNumber(4)
  void clearImplementationName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get implementationVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set implementationVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasImplementationVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearImplementationVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxFrameBytes => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxFrameBytes($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxFrameBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxFrameBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxTransferChunkBytes => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxTransferChunkBytes($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxTransferChunkBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxTransferChunkBytes() => $_clearField(7);
}

class ServerHandshakeRejected extends $pb.GeneratedMessage {
  factory ServerHandshakeRejected({
    StableError? error,
    $core.Iterable<ProtocolVersion>? supportedProtocolVersions,
  }) {
    final result = create();
    if (error != null) result.error = error;
    if (supportedProtocolVersions != null)
      result.supportedProtocolVersions.addAll(supportedProtocolVersions);
    return result;
  }

  ServerHandshakeRejected._();

  factory ServerHandshakeRejected.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerHandshakeRejected.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerHandshakeRejected',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<StableError>(1, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..pPM<ProtocolVersion>(
        2, _omitFieldNames ? '' : 'supportedProtocolVersions',
        subBuilder: ProtocolVersion.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHandshakeRejected clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerHandshakeRejected copyWith(
          void Function(ServerHandshakeRejected) updates) =>
      super.copyWith((message) => updates(message as ServerHandshakeRejected))
          as ServerHandshakeRejected;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerHandshakeRejected create() => ServerHandshakeRejected._();
  @$core.override
  ServerHandshakeRejected createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerHandshakeRejected getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerHandshakeRejected>(create);
  static ServerHandshakeRejected? _defaultInstance;

  @$pb.TagNumber(1)
  StableError get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(StableError value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  StableError ensureError() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<ProtocolVersion> get supportedProtocolVersions => $_getList(1);
}

class HealthRequest extends $pb.GeneratedMessage {
  factory HealthRequest({
    $fixnum.Int64? requestId,
    $core.bool? includeBuildInfo,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (includeBuildInfo != null) result.includeBuildInfo = includeBuildInfo;
    return result;
  }

  HealthRequest._();

  factory HealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(2, _omitFieldNames ? '' : 'includeBuildInfo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthRequest copyWith(void Function(HealthRequest) updates) =>
      super.copyWith((message) => updates(message as HealthRequest))
          as HealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthRequest create() => HealthRequest._();
  @$core.override
  HealthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthRequest>(create);
  static HealthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeBuildInfo => $_getBF(1);
  @$pb.TagNumber(2)
  set includeBuildInfo($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeBuildInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeBuildInfo() => $_clearField(2);
}

class HealthResponse extends $pb.GeneratedMessage {
  factory HealthResponse({
    $fixnum.Int64? requestId,
    HealthStatus? status,
    $core.String? nodeVersion,
    $fixnum.Int64? uptimeMillis,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (status != null) result.status = status;
    if (nodeVersion != null) result.nodeVersion = nodeVersion;
    if (uptimeMillis != null) result.uptimeMillis = uptimeMillis;
    return result;
  }

  HealthResponse._();

  factory HealthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HealthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<HealthStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: HealthStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'nodeVersion')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'uptimeMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthResponse copyWith(void Function(HealthResponse) updates) =>
      super.copyWith((message) => updates(message as HealthResponse))
          as HealthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthResponse create() => HealthResponse._();
  @$core.override
  HealthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthResponse>(create);
  static HealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  HealthStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(HealthStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get uptimeMillis => $_getI64(3);
  @$pb.TagNumber(4)
  set uptimeMillis($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUptimeMillis() => $_has(3);
  @$pb.TagNumber(4)
  void clearUptimeMillis() => $_clearField(4);
}

class GetProjectBootstrapRequest extends $pb.GeneratedMessage {
  factory GetProjectBootstrapRequest({
    $fixnum.Int64? requestId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  GetProjectBootstrapRequest._();

  factory GetProjectBootstrapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProjectBootstrapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProjectBootstrapRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProjectBootstrapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProjectBootstrapRequest copyWith(
          void Function(GetProjectBootstrapRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetProjectBootstrapRequest))
          as GetProjectBootstrapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProjectBootstrapRequest create() => GetProjectBootstrapRequest._();
  @$core.override
  GetProjectBootstrapRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProjectBootstrapRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProjectBootstrapRequest>(create);
  static GetProjectBootstrapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);
}

class GetProjectBootstrapResponse extends $pb.GeneratedMessage {
  factory GetProjectBootstrapResponse({
    $fixnum.Int64? requestId,
    $core.String? homeDirectory,
    ProjectSnapshot? defaultProject,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (homeDirectory != null) result.homeDirectory = homeDirectory;
    if (defaultProject != null) result.defaultProject = defaultProject;
    return result;
  }

  GetProjectBootstrapResponse._();

  factory GetProjectBootstrapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProjectBootstrapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProjectBootstrapResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'homeDirectory')
    ..aOM<ProjectSnapshot>(3, _omitFieldNames ? '' : 'defaultProject',
        subBuilder: ProjectSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProjectBootstrapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProjectBootstrapResponse copyWith(
          void Function(GetProjectBootstrapResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetProjectBootstrapResponse))
          as GetProjectBootstrapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProjectBootstrapResponse create() =>
      GetProjectBootstrapResponse._();
  @$core.override
  GetProjectBootstrapResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProjectBootstrapResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProjectBootstrapResponse>(create);
  static GetProjectBootstrapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get homeDirectory => $_getSZ(1);
  @$pb.TagNumber(2)
  set homeDirectory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomeDirectory() => $_clearField(2);

  @$pb.TagNumber(3)
  ProjectSnapshot get defaultProject => $_getN(2);
  @$pb.TagNumber(3)
  set defaultProject(ProjectSnapshot value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultProject() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultProject() => $_clearField(3);
  @$pb.TagNumber(3)
  ProjectSnapshot ensureDefaultProject() => $_ensure(2);
}

class BrowseDirectoryRequest extends $pb.GeneratedMessage {
  factory BrowseDirectoryRequest({
    $fixnum.Int64? requestId,
    $core.String? directory,
    $core.int? maxChildren,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (directory != null) result.directory = directory;
    if (maxChildren != null) result.maxChildren = maxChildren;
    return result;
  }

  BrowseDirectoryRequest._();

  factory BrowseDirectoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BrowseDirectoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BrowseDirectoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'directory')
    ..aI(3, _omitFieldNames ? '' : 'maxChildren',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BrowseDirectoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BrowseDirectoryRequest copyWith(
          void Function(BrowseDirectoryRequest) updates) =>
      super.copyWith((message) => updates(message as BrowseDirectoryRequest))
          as BrowseDirectoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BrowseDirectoryRequest create() => BrowseDirectoryRequest._();
  @$core.override
  BrowseDirectoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BrowseDirectoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BrowseDirectoryRequest>(create);
  static BrowseDirectoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get directory => $_getSZ(1);
  @$pb.TagNumber(2)
  set directory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearDirectory() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxChildren => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxChildren($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxChildren() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxChildren() => $_clearField(3);
}

class BrowseDirectoryResponse extends $pb.GeneratedMessage {
  factory BrowseDirectoryResponse({
    $fixnum.Int64? requestId,
    DirectoryListingSnapshot? directory,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (directory != null) result.directory = directory;
    return result;
  }

  BrowseDirectoryResponse._();

  factory BrowseDirectoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BrowseDirectoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BrowseDirectoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<DirectoryListingSnapshot>(2, _omitFieldNames ? '' : 'directory',
        subBuilder: DirectoryListingSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BrowseDirectoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BrowseDirectoryResponse copyWith(
          void Function(BrowseDirectoryResponse) updates) =>
      super.copyWith((message) => updates(message as BrowseDirectoryResponse))
          as BrowseDirectoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BrowseDirectoryResponse create() => BrowseDirectoryResponse._();
  @$core.override
  BrowseDirectoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BrowseDirectoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BrowseDirectoryResponse>(create);
  static BrowseDirectoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  DirectoryListingSnapshot get directory => $_getN(1);
  @$pb.TagNumber(2)
  set directory(DirectoryListingSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearDirectory() => $_clearField(2);
  @$pb.TagNumber(2)
  DirectoryListingSnapshot ensureDirectory() => $_ensure(1);
}

class ValidateProjectRequest extends $pb.GeneratedMessage {
  factory ValidateProjectRequest({
    $fixnum.Int64? requestId,
    $core.String? candidateDirectory,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (candidateDirectory != null)
      result.candidateDirectory = candidateDirectory;
    return result;
  }

  ValidateProjectRequest._();

  factory ValidateProjectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateProjectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateProjectRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'candidateDirectory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateProjectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateProjectRequest copyWith(
          void Function(ValidateProjectRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateProjectRequest))
          as ValidateProjectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateProjectRequest create() => ValidateProjectRequest._();
  @$core.override
  ValidateProjectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateProjectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateProjectRequest>(create);
  static ValidateProjectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get candidateDirectory => $_getSZ(1);
  @$pb.TagNumber(2)
  set candidateDirectory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCandidateDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCandidateDirectory() => $_clearField(2);
}

class ValidateProjectResponse extends $pb.GeneratedMessage {
  factory ValidateProjectResponse({
    $fixnum.Int64? requestId,
    ProjectSnapshot? project,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (project != null) result.project = project;
    return result;
  }

  ValidateProjectResponse._();

  factory ValidateProjectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateProjectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateProjectResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<ProjectSnapshot>(2, _omitFieldNames ? '' : 'project',
        subBuilder: ProjectSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateProjectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateProjectResponse copyWith(
          void Function(ValidateProjectResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateProjectResponse))
          as ValidateProjectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateProjectResponse create() => ValidateProjectResponse._();
  @$core.override
  ValidateProjectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateProjectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateProjectResponse>(create);
  static ValidateProjectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  ProjectSnapshot get project => $_getN(1);
  @$pb.TagNumber(2)
  set project(ProjectSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProject() => $_has(1);
  @$pb.TagNumber(2)
  void clearProject() => $_clearField(2);
  @$pb.TagNumber(2)
  ProjectSnapshot ensureProject() => $_ensure(1);
}

class ListKnownProjectsRequest extends $pb.GeneratedMessage {
  factory ListKnownProjectsRequest({
    $fixnum.Int64? requestId,
    $core.int? maxProjects,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (maxProjects != null) result.maxProjects = maxProjects;
    return result;
  }

  ListKnownProjectsRequest._();

  factory ListKnownProjectsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListKnownProjectsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListKnownProjectsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(2, _omitFieldNames ? '' : 'maxProjects',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListKnownProjectsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListKnownProjectsRequest copyWith(
          void Function(ListKnownProjectsRequest) updates) =>
      super.copyWith((message) => updates(message as ListKnownProjectsRequest))
          as ListKnownProjectsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListKnownProjectsRequest create() => ListKnownProjectsRequest._();
  @$core.override
  ListKnownProjectsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListKnownProjectsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListKnownProjectsRequest>(create);
  static ListKnownProjectsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxProjects => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxProjects($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxProjects() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxProjects() => $_clearField(2);
}

class ListKnownProjectsResponse extends $pb.GeneratedMessage {
  factory ListKnownProjectsResponse({
    $fixnum.Int64? requestId,
    $core.Iterable<KnownProjectSnapshot>? projects,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (projects != null) result.projects.addAll(projects);
    return result;
  }

  ListKnownProjectsResponse._();

  factory ListKnownProjectsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListKnownProjectsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListKnownProjectsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<KnownProjectSnapshot>(2, _omitFieldNames ? '' : 'projects',
        subBuilder: KnownProjectSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListKnownProjectsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListKnownProjectsResponse copyWith(
          void Function(ListKnownProjectsResponse) updates) =>
      super.copyWith((message) => updates(message as ListKnownProjectsResponse))
          as ListKnownProjectsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListKnownProjectsResponse create() => ListKnownProjectsResponse._();
  @$core.override
  ListKnownProjectsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListKnownProjectsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListKnownProjectsResponse>(create);
  static ListKnownProjectsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<KnownProjectSnapshot> get projects => $_getList(1);
}

class ApproveProjectTrustRequest extends $pb.GeneratedMessage {
  factory ApproveProjectTrustRequest({
    $fixnum.Int64? requestId,
    $core.String? projectId,
    $core.String? trustRevision,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (projectId != null) result.projectId = projectId;
    if (trustRevision != null) result.trustRevision = trustRevision;
    return result;
  }

  ApproveProjectTrustRequest._();

  factory ApproveProjectTrustRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApproveProjectTrustRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproveProjectTrustRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'trustRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveProjectTrustRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveProjectTrustRequest copyWith(
          void Function(ApproveProjectTrustRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ApproveProjectTrustRequest))
          as ApproveProjectTrustRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveProjectTrustRequest create() => ApproveProjectTrustRequest._();
  @$core.override
  ApproveProjectTrustRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApproveProjectTrustRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApproveProjectTrustRequest>(create);
  static ApproveProjectTrustRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get trustRevision => $_getSZ(2);
  @$pb.TagNumber(3)
  set trustRevision($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTrustRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearTrustRevision() => $_clearField(3);
}

class ApproveProjectTrustResponse extends $pb.GeneratedMessage {
  factory ApproveProjectTrustResponse({
    $fixnum.Int64? requestId,
    ProjectSnapshot? project,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (project != null) result.project = project;
    return result;
  }

  ApproveProjectTrustResponse._();

  factory ApproveProjectTrustResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApproveProjectTrustResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproveProjectTrustResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<ProjectSnapshot>(2, _omitFieldNames ? '' : 'project',
        subBuilder: ProjectSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveProjectTrustResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveProjectTrustResponse copyWith(
          void Function(ApproveProjectTrustResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ApproveProjectTrustResponse))
          as ApproveProjectTrustResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveProjectTrustResponse create() =>
      ApproveProjectTrustResponse._();
  @$core.override
  ApproveProjectTrustResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApproveProjectTrustResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApproveProjectTrustResponse>(create);
  static ApproveProjectTrustResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  ProjectSnapshot get project => $_getN(1);
  @$pb.TagNumber(2)
  set project(ProjectSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProject() => $_has(1);
  @$pb.TagNumber(2)
  void clearProject() => $_clearField(2);
  @$pb.TagNumber(2)
  ProjectSnapshot ensureProject() => $_ensure(1);
}

class DirectoryListingSnapshot extends $pb.GeneratedMessage {
  factory DirectoryListingSnapshot({
    $core.String? canonicalDirectory,
    $core.String? parentDirectory,
    $core.Iterable<DirectoryEntrySnapshot>? children,
    $core.bool? truncated,
  }) {
    final result = create();
    if (canonicalDirectory != null)
      result.canonicalDirectory = canonicalDirectory;
    if (parentDirectory != null) result.parentDirectory = parentDirectory;
    if (children != null) result.children.addAll(children);
    if (truncated != null) result.truncated = truncated;
    return result;
  }

  DirectoryListingSnapshot._();

  factory DirectoryListingSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DirectoryListingSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DirectoryListingSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'canonicalDirectory')
    ..aOS(2, _omitFieldNames ? '' : 'parentDirectory')
    ..pPM<DirectoryEntrySnapshot>(3, _omitFieldNames ? '' : 'children',
        subBuilder: DirectoryEntrySnapshot.create)
    ..aOB(4, _omitFieldNames ? '' : 'truncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryListingSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryListingSnapshot copyWith(
          void Function(DirectoryListingSnapshot) updates) =>
      super.copyWith((message) => updates(message as DirectoryListingSnapshot))
          as DirectoryListingSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DirectoryListingSnapshot create() => DirectoryListingSnapshot._();
  @$core.override
  DirectoryListingSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DirectoryListingSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DirectoryListingSnapshot>(create);
  static DirectoryListingSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get canonicalDirectory => $_getSZ(0);
  @$pb.TagNumber(1)
  set canonicalDirectory($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCanonicalDirectory() => $_has(0);
  @$pb.TagNumber(1)
  void clearCanonicalDirectory() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get parentDirectory => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentDirectory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentDirectory() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<DirectoryEntrySnapshot> get children => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get truncated => $_getBF(3);
  @$pb.TagNumber(4)
  set truncated($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTruncated() => $_has(3);
  @$pb.TagNumber(4)
  void clearTruncated() => $_clearField(4);
}

class DirectoryEntrySnapshot extends $pb.GeneratedMessage {
  factory DirectoryEntrySnapshot({
    $core.String? name,
    $core.String? canonicalPath,
    $core.bool? isSymbolicLink,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (canonicalPath != null) result.canonicalPath = canonicalPath;
    if (isSymbolicLink != null) result.isSymbolicLink = isSymbolicLink;
    return result;
  }

  DirectoryEntrySnapshot._();

  factory DirectoryEntrySnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DirectoryEntrySnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DirectoryEntrySnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'canonicalPath')
    ..aOB(3, _omitFieldNames ? '' : 'isSymbolicLink')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryEntrySnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryEntrySnapshot copyWith(
          void Function(DirectoryEntrySnapshot) updates) =>
      super.copyWith((message) => updates(message as DirectoryEntrySnapshot))
          as DirectoryEntrySnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DirectoryEntrySnapshot create() => DirectoryEntrySnapshot._();
  @$core.override
  DirectoryEntrySnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DirectoryEntrySnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DirectoryEntrySnapshot>(create);
  static DirectoryEntrySnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get canonicalPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set canonicalPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCanonicalPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearCanonicalPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isSymbolicLink => $_getBF(2);
  @$pb.TagNumber(3)
  set isSymbolicLink($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsSymbolicLink() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsSymbolicLink() => $_clearField(3);
}

class ProjectTrustSnapshot extends $pb.GeneratedMessage {
  factory ProjectTrustSnapshot({
    ProjectTrustStatus? status,
    $core.Iterable<ProjectTrustReason>? reasons,
    $core.String? revision,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (reasons != null) result.reasons.addAll(reasons);
    if (revision != null) result.revision = revision;
    return result;
  }

  ProjectTrustSnapshot._();

  factory ProjectTrustSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProjectTrustSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectTrustSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aE<ProjectTrustStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ProjectTrustStatus.values)
    ..pc<ProjectTrustReason>(
        2, _omitFieldNames ? '' : 'reasons', $pb.PbFieldType.KE,
        valueOf: ProjectTrustReason.valueOf,
        enumValues: ProjectTrustReason.values,
        defaultEnumValue: ProjectTrustReason.PROJECT_TRUST_REASON_UNSPECIFIED)
    ..aOS(3, _omitFieldNames ? '' : 'revision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectTrustSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectTrustSnapshot copyWith(void Function(ProjectTrustSnapshot) updates) =>
      super.copyWith((message) => updates(message as ProjectTrustSnapshot))
          as ProjectTrustSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProjectTrustSnapshot create() => ProjectTrustSnapshot._();
  @$core.override
  ProjectTrustSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProjectTrustSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectTrustSnapshot>(create);
  static ProjectTrustSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  ProjectTrustStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ProjectTrustStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ProjectTrustReason> get reasons => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get revision => $_getSZ(2);
  @$pb.TagNumber(3)
  set revision($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => $_clearField(3);
}

class ProjectIdentitySnapshot extends $pb.GeneratedMessage {
  factory ProjectIdentitySnapshot({
    $core.String? projectId,
    $core.String? canonicalWorkingDirectory,
    $core.bool? isGitRepository,
    $core.String? gitRoot,
    $core.String? mainWorktreeRoot,
    $core.String? branch,
    $core.bool? isLinkedWorktree,
    $core.bool? isDetachedHead,
    $core.String? worktreeId,
    $core.String? mainProjectId,
  }) {
    final result = create();
    if (projectId != null) result.projectId = projectId;
    if (canonicalWorkingDirectory != null)
      result.canonicalWorkingDirectory = canonicalWorkingDirectory;
    if (isGitRepository != null) result.isGitRepository = isGitRepository;
    if (gitRoot != null) result.gitRoot = gitRoot;
    if (mainWorktreeRoot != null) result.mainWorktreeRoot = mainWorktreeRoot;
    if (branch != null) result.branch = branch;
    if (isLinkedWorktree != null) result.isLinkedWorktree = isLinkedWorktree;
    if (isDetachedHead != null) result.isDetachedHead = isDetachedHead;
    if (worktreeId != null) result.worktreeId = worktreeId;
    if (mainProjectId != null) result.mainProjectId = mainProjectId;
    return result;
  }

  ProjectIdentitySnapshot._();

  factory ProjectIdentitySnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProjectIdentitySnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectIdentitySnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'projectId')
    ..aOS(2, _omitFieldNames ? '' : 'canonicalWorkingDirectory')
    ..aOB(3, _omitFieldNames ? '' : 'isGitRepository')
    ..aOS(4, _omitFieldNames ? '' : 'gitRoot')
    ..aOS(5, _omitFieldNames ? '' : 'mainWorktreeRoot')
    ..aOS(6, _omitFieldNames ? '' : 'branch')
    ..aOB(7, _omitFieldNames ? '' : 'isLinkedWorktree')
    ..aOB(8, _omitFieldNames ? '' : 'isDetachedHead')
    ..aOS(9, _omitFieldNames ? '' : 'worktreeId')
    ..aOS(10, _omitFieldNames ? '' : 'mainProjectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectIdentitySnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectIdentitySnapshot copyWith(
          void Function(ProjectIdentitySnapshot) updates) =>
      super.copyWith((message) => updates(message as ProjectIdentitySnapshot))
          as ProjectIdentitySnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProjectIdentitySnapshot create() => ProjectIdentitySnapshot._();
  @$core.override
  ProjectIdentitySnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProjectIdentitySnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectIdentitySnapshot>(create);
  static ProjectIdentitySnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get projectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set projectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get canonicalWorkingDirectory => $_getSZ(1);
  @$pb.TagNumber(2)
  set canonicalWorkingDirectory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCanonicalWorkingDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCanonicalWorkingDirectory() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGitRepository => $_getBF(2);
  @$pb.TagNumber(3)
  set isGitRepository($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGitRepository() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGitRepository() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get gitRoot => $_getSZ(3);
  @$pb.TagNumber(4)
  set gitRoot($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGitRoot() => $_has(3);
  @$pb.TagNumber(4)
  void clearGitRoot() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mainWorktreeRoot => $_getSZ(4);
  @$pb.TagNumber(5)
  set mainWorktreeRoot($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMainWorktreeRoot() => $_has(4);
  @$pb.TagNumber(5)
  void clearMainWorktreeRoot() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get branch => $_getSZ(5);
  @$pb.TagNumber(6)
  set branch($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBranch() => $_has(5);
  @$pb.TagNumber(6)
  void clearBranch() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isLinkedWorktree => $_getBF(6);
  @$pb.TagNumber(7)
  set isLinkedWorktree($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsLinkedWorktree() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsLinkedWorktree() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isDetachedHead => $_getBF(7);
  @$pb.TagNumber(8)
  set isDetachedHead($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsDetachedHead() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsDetachedHead() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get worktreeId => $_getSZ(8);
  @$pb.TagNumber(9)
  set worktreeId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWorktreeId() => $_has(8);
  @$pb.TagNumber(9)
  void clearWorktreeId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get mainProjectId => $_getSZ(9);
  @$pb.TagNumber(10)
  set mainProjectId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMainProjectId() => $_has(9);
  @$pb.TagNumber(10)
  void clearMainProjectId() => $_clearField(10);
}

class ProjectSnapshot extends $pb.GeneratedMessage {
  factory ProjectSnapshot({
    ProjectIdentitySnapshot? identity,
    ProjectTrustSnapshot? trust,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (trust != null) result.trust = trust;
    return result;
  }

  ProjectSnapshot._();

  factory ProjectSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProjectSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProjectSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<ProjectIdentitySnapshot>(1, _omitFieldNames ? '' : 'identity',
        subBuilder: ProjectIdentitySnapshot.create)
    ..aOM<ProjectTrustSnapshot>(2, _omitFieldNames ? '' : 'trust',
        subBuilder: ProjectTrustSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProjectSnapshot copyWith(void Function(ProjectSnapshot) updates) =>
      super.copyWith((message) => updates(message as ProjectSnapshot))
          as ProjectSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProjectSnapshot create() => ProjectSnapshot._();
  @$core.override
  ProjectSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProjectSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProjectSnapshot>(create);
  static ProjectSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  ProjectIdentitySnapshot get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity(ProjectIdentitySnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);
  @$pb.TagNumber(1)
  ProjectIdentitySnapshot ensureIdentity() => $_ensure(0);

  @$pb.TagNumber(2)
  ProjectTrustSnapshot get trust => $_getN(1);
  @$pb.TagNumber(2)
  set trust(ProjectTrustSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTrust() => $_has(1);
  @$pb.TagNumber(2)
  void clearTrust() => $_clearField(2);
  @$pb.TagNumber(2)
  ProjectTrustSnapshot ensureTrust() => $_ensure(1);
}

class KnownProjectSnapshot extends $pb.GeneratedMessage {
  factory KnownProjectSnapshot({
    ProjectSnapshot? project,
    $fixnum.Int64? lastSessionAtUnixMillis,
    $core.int? sessionCount,
  }) {
    final result = create();
    if (project != null) result.project = project;
    if (lastSessionAtUnixMillis != null)
      result.lastSessionAtUnixMillis = lastSessionAtUnixMillis;
    if (sessionCount != null) result.sessionCount = sessionCount;
    return result;
  }

  KnownProjectSnapshot._();

  factory KnownProjectSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KnownProjectSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KnownProjectSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<ProjectSnapshot>(1, _omitFieldNames ? '' : 'project',
        subBuilder: ProjectSnapshot.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'lastSessionAtUnixMillis',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'sessionCount',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownProjectSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KnownProjectSnapshot copyWith(void Function(KnownProjectSnapshot) updates) =>
      super.copyWith((message) => updates(message as KnownProjectSnapshot))
          as KnownProjectSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KnownProjectSnapshot create() => KnownProjectSnapshot._();
  @$core.override
  KnownProjectSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KnownProjectSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<KnownProjectSnapshot>(create);
  static KnownProjectSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  ProjectSnapshot get project => $_getN(0);
  @$pb.TagNumber(1)
  set project(ProjectSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProject() => $_has(0);
  @$pb.TagNumber(1)
  void clearProject() => $_clearField(1);
  @$pb.TagNumber(1)
  ProjectSnapshot ensureProject() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastSessionAtUnixMillis => $_getI64(1);
  @$pb.TagNumber(2)
  set lastSessionAtUnixMillis($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSessionAtUnixMillis() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSessionAtUnixMillis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sessionCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set sessionCount($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionCount() => $_clearField(3);
}

class ListSessionsRequest extends $pb.GeneratedMessage {
  factory ListSessionsRequest({
    $fixnum.Int64? requestId,
    $core.String? projectId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  ListSessionsRequest._();

  factory ListSessionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSessionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSessionsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest copyWith(void Function(ListSessionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSessionsRequest))
          as ListSessionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest create() => ListSessionsRequest._();
  @$core.override
  ListSessionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSessionsRequest>(create);
  static ListSessionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);
}

class ListSessionsResponse extends $pb.GeneratedMessage {
  factory ListSessionsResponse({
    $fixnum.Int64? requestId,
    $core.Iterable<SessionSummarySnapshot>? sessions,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (sessions != null) result.sessions.addAll(sessions);
    return result;
  }

  ListSessionsResponse._();

  factory ListSessionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSessionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSessionsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<SessionSummarySnapshot>(2, _omitFieldNames ? '' : 'sessions',
        subBuilder: SessionSummarySnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse copyWith(void Function(ListSessionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSessionsResponse))
          as ListSessionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse create() => ListSessionsResponse._();
  @$core.override
  ListSessionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSessionsResponse>(create);
  static ListSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<SessionSummarySnapshot> get sessions => $_getList(1);
}

class GetSessionRequest extends $pb.GeneratedMessage {
  factory GetSessionRequest({
    $fixnum.Int64? requestId,
    $core.String? sessionId,
    $core.String? projectId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (sessionId != null) result.sessionId = sessionId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  GetSessionRequest._();

  factory GetSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRequest copyWith(void Function(GetSessionRequest) updates) =>
      super.copyWith((message) => updates(message as GetSessionRequest))
          as GetSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionRequest create() => GetSessionRequest._();
  @$core.override
  GetSessionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionRequest>(create);
  static GetSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);
}

class GetSessionResponse extends $pb.GeneratedMessage {
  factory GetSessionResponse({
    $fixnum.Int64? requestId,
    SessionDetailSnapshot? session,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (session != null) result.session = session;
    return result;
  }

  GetSessionResponse._();

  factory GetSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<SessionDetailSnapshot>(2, _omitFieldNames ? '' : 'session',
        subBuilder: SessionDetailSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionResponse copyWith(void Function(GetSessionResponse) updates) =>
      super.copyWith((message) => updates(message as GetSessionResponse))
          as GetSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionResponse create() => GetSessionResponse._();
  @$core.override
  GetSessionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionResponse>(create);
  static GetSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  SessionDetailSnapshot get session => $_getN(1);
  @$pb.TagNumber(2)
  set session(SessionDetailSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearSession() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionDetailSnapshot ensureSession() => $_ensure(1);
}

class CreateSessionRequest extends $pb.GeneratedMessage {
  factory CreateSessionRequest({
    $fixnum.Int64? requestId,
    $core.String? projectId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (projectId != null) result.projectId = projectId;
    return result;
  }

  CreateSessionRequest._();

  factory CreateSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest copyWith(void Function(CreateSessionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSessionRequest))
          as CreateSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSessionRequest create() => CreateSessionRequest._();
  @$core.override
  CreateSessionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionRequest>(create);
  static CreateSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);
}

class CreateSessionResponse extends $pb.GeneratedMessage {
  factory CreateSessionResponse({
    $fixnum.Int64? requestId,
    SessionDetailSnapshot? session,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (session != null) result.session = session;
    return result;
  }

  CreateSessionResponse._();

  factory CreateSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<SessionDetailSnapshot>(2, _omitFieldNames ? '' : 'session',
        subBuilder: SessionDetailSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse copyWith(
          void Function(CreateSessionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSessionResponse))
          as CreateSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSessionResponse create() => CreateSessionResponse._();
  @$core.override
  CreateSessionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionResponse>(create);
  static CreateSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  SessionDetailSnapshot get session => $_getN(1);
  @$pb.TagNumber(2)
  set session(SessionDetailSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearSession() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionDetailSnapshot ensureSession() => $_ensure(1);
}

class PromptCommand extends $pb.GeneratedMessage {
  factory PromptCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? sessionId,
    $core.String? prompt,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (sessionId != null) result.sessionId = sessionId;
    if (prompt != null) result.prompt = prompt;
    return result;
  }

  PromptCommand._();

  factory PromptCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromptCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromptCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..aOS(4, _omitFieldNames ? '' : 'prompt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptCommand copyWith(void Function(PromptCommand) updates) =>
      super.copyWith((message) => updates(message as PromptCommand))
          as PromptCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromptCommand create() => PromptCommand._();
  @$core.override
  PromptCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromptCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromptCommand>(create);
  static PromptCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get prompt => $_getSZ(3);
  @$pb.TagNumber(4)
  set prompt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPrompt() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrompt() => $_clearField(4);
}

class AbortCommand extends $pb.GeneratedMessage {
  factory AbortCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? sessionId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  AbortCommand._();

  factory AbortCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AbortCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AbortCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbortCommand copyWith(void Function(AbortCommand) updates) =>
      super.copyWith((message) => updates(message as AbortCommand))
          as AbortCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbortCommand create() => AbortCommand._();
  @$core.override
  AbortCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AbortCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AbortCommand>(create);
  static AbortCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);
}

class RenameSessionCommand extends $pb.GeneratedMessage {
  factory RenameSessionCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    $core.String? name,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (name != null) result.name = name;
    return result;
  }

  RenameSessionCommand._();

  factory RenameSessionCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RenameSessionCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameSessionCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameSessionCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameSessionCommand copyWith(void Function(RenameSessionCommand) updates) =>
      super.copyWith((message) => updates(message as RenameSessionCommand))
          as RenameSessionCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RenameSessionCommand create() => RenameSessionCommand._();
  @$core.override
  RenameSessionCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RenameSessionCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameSessionCommand>(create);
  static RenameSessionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);
}

class ClearSessionNameCommand extends $pb.GeneratedMessage {
  factory ClearSessionNameCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  ClearSessionNameCommand._();

  factory ClearSessionNameCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearSessionNameCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearSessionNameCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearSessionNameCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearSessionNameCommand copyWith(
          void Function(ClearSessionNameCommand) updates) =>
      super.copyWith((message) => updates(message as ClearSessionNameCommand))
          as ClearSessionNameCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearSessionNameCommand create() => ClearSessionNameCommand._();
  @$core.override
  ClearSessionNameCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearSessionNameCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearSessionNameCommand>(create);
  static ClearSessionNameCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);
}

class AutoNameSessionCommand extends $pb.GeneratedMessage {
  factory AutoNameSessionCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    $core.int? timeoutMillis,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (timeoutMillis != null) result.timeoutMillis = timeoutMillis;
    return result;
  }

  AutoNameSessionCommand._();

  factory AutoNameSessionCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AutoNameSessionCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutoNameSessionCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aI(5, _omitFieldNames ? '' : 'timeoutMillis',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoNameSessionCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoNameSessionCommand copyWith(
          void Function(AutoNameSessionCommand) updates) =>
      super.copyWith((message) => updates(message as AutoNameSessionCommand))
          as AutoNameSessionCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoNameSessionCommand create() => AutoNameSessionCommand._();
  @$core.override
  AutoNameSessionCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AutoNameSessionCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutoNameSessionCommand>(create);
  static AutoNameSessionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get timeoutMillis => $_getIZ(4);
  @$pb.TagNumber(5)
  set timeoutMillis($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimeoutMillis() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeoutMillis() => $_clearField(5);
}

class DeleteSessionConfirmationEvidence extends $pb.GeneratedMessage {
  factory DeleteSessionConfirmationEvidence({
    $core.String? sessionId,
    $core.String? adminRevision,
    $core.String? displayedTitle,
    $core.bool? destructiveActionAcknowledged,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (adminRevision != null) result.adminRevision = adminRevision;
    if (displayedTitle != null) result.displayedTitle = displayedTitle;
    if (destructiveActionAcknowledged != null)
      result.destructiveActionAcknowledged = destructiveActionAcknowledged;
    return result;
  }

  DeleteSessionConfirmationEvidence._();

  factory DeleteSessionConfirmationEvidence.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteSessionConfirmationEvidence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteSessionConfirmationEvidence',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'adminRevision')
    ..aOS(3, _omitFieldNames ? '' : 'displayedTitle')
    ..aOB(4, _omitFieldNames ? '' : 'destructiveActionAcknowledged')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionConfirmationEvidence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionConfirmationEvidence copyWith(
          void Function(DeleteSessionConfirmationEvidence) updates) =>
      super.copyWith((message) =>
              updates(message as DeleteSessionConfirmationEvidence))
          as DeleteSessionConfirmationEvidence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteSessionConfirmationEvidence create() =>
      DeleteSessionConfirmationEvidence._();
  @$core.override
  DeleteSessionConfirmationEvidence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteSessionConfirmationEvidence getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteSessionConfirmationEvidence>(
          create);
  static DeleteSessionConfirmationEvidence? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get adminRevision => $_getSZ(1);
  @$pb.TagNumber(2)
  set adminRevision($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAdminRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearAdminRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayedTitle => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayedTitle($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayedTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayedTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get destructiveActionAcknowledged => $_getBF(3);
  @$pb.TagNumber(4)
  set destructiveActionAcknowledged($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestructiveActionAcknowledged() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestructiveActionAcknowledged() => $_clearField(4);
}

class DeleteSessionCommand extends $pb.GeneratedMessage {
  factory DeleteSessionCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    DeleteSessionConfirmationEvidence? confirmation,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (confirmation != null) result.confirmation = confirmation;
    return result;
  }

  DeleteSessionCommand._();

  factory DeleteSessionCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteSessionCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteSessionCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aOM<DeleteSessionConfirmationEvidence>(
        5, _omitFieldNames ? '' : 'confirmation',
        subBuilder: DeleteSessionConfirmationEvidence.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionCommand copyWith(void Function(DeleteSessionCommand) updates) =>
      super.copyWith((message) => updates(message as DeleteSessionCommand))
          as DeleteSessionCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteSessionCommand create() => DeleteSessionCommand._();
  @$core.override
  DeleteSessionCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteSessionCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteSessionCommand>(create);
  static DeleteSessionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  DeleteSessionConfirmationEvidence get confirmation => $_getN(4);
  @$pb.TagNumber(5)
  set confirmation(DeleteSessionConfirmationEvidence value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmation() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmation() => $_clearField(5);
  @$pb.TagNumber(5)
  DeleteSessionConfirmationEvidence ensureConfirmation() => $_ensure(4);
}

class DeleteSessionOutcome extends $pb.GeneratedMessage {
  factory DeleteSessionOutcome({
    $core.String? sessionId,
    $core.int? reparentedChildCount,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (reparentedChildCount != null)
      result.reparentedChildCount = reparentedChildCount;
    return result;
  }

  DeleteSessionOutcome._();

  factory DeleteSessionOutcome.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteSessionOutcome.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteSessionOutcome',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aI(2, _omitFieldNames ? '' : 'reparentedChildCount',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionOutcome clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSessionOutcome copyWith(void Function(DeleteSessionOutcome) updates) =>
      super.copyWith((message) => updates(message as DeleteSessionOutcome))
          as DeleteSessionOutcome;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteSessionOutcome create() => DeleteSessionOutcome._();
  @$core.override
  DeleteSessionOutcome createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteSessionOutcome getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteSessionOutcome>(create);
  static DeleteSessionOutcome? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get reparentedChildCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set reparentedChildCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReparentedChildCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearReparentedChildCount() => $_clearField(2);
}

enum SessionAdminCommandOutcome_Outcome { session, deletion, error, notSet }

class SessionAdminCommandOutcome extends $pb.GeneratedMessage {
  factory SessionAdminCommandOutcome({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    SessionAdminOperation? operation,
    SessionSummarySnapshot? session,
    DeleteSessionOutcome? deletion,
    StableError? error,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (operation != null) result.operation = operation;
    if (session != null) result.session = session;
    if (deletion != null) result.deletion = deletion;
    if (error != null) result.error = error;
    return result;
  }

  SessionAdminCommandOutcome._();

  factory SessionAdminCommandOutcome.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionAdminCommandOutcome.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SessionAdminCommandOutcome_Outcome>
      _SessionAdminCommandOutcome_OutcomeByTag = {
    10: SessionAdminCommandOutcome_Outcome.session,
    11: SessionAdminCommandOutcome_Outcome.deletion,
    12: SessionAdminCommandOutcome_Outcome.error,
    0: SessionAdminCommandOutcome_Outcome.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionAdminCommandOutcome',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aE<SessionAdminOperation>(3, _omitFieldNames ? '' : 'operation',
        enumValues: SessionAdminOperation.values)
    ..aOM<SessionSummarySnapshot>(10, _omitFieldNames ? '' : 'session',
        subBuilder: SessionSummarySnapshot.create)
    ..aOM<DeleteSessionOutcome>(11, _omitFieldNames ? '' : 'deletion',
        subBuilder: DeleteSessionOutcome.create)
    ..aOM<StableError>(12, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionAdminCommandOutcome clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionAdminCommandOutcome copyWith(
          void Function(SessionAdminCommandOutcome) updates) =>
      super.copyWith(
              (message) => updates(message as SessionAdminCommandOutcome))
          as SessionAdminCommandOutcome;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionAdminCommandOutcome create() => SessionAdminCommandOutcome._();
  @$core.override
  SessionAdminCommandOutcome createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionAdminCommandOutcome getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionAdminCommandOutcome>(create);
  static SessionAdminCommandOutcome? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  SessionAdminCommandOutcome_Outcome whichOutcome() =>
      _SessionAdminCommandOutcome_OutcomeByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  void clearOutcome() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  SessionAdminOperation get operation => $_getN(2);
  @$pb.TagNumber(3)
  set operation(SessionAdminOperation value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOperation() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperation() => $_clearField(3);

  @$pb.TagNumber(10)
  SessionSummarySnapshot get session => $_getN(3);
  @$pb.TagNumber(10)
  set session(SessionSummarySnapshot value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSession() => $_has(3);
  @$pb.TagNumber(10)
  void clearSession() => $_clearField(10);
  @$pb.TagNumber(10)
  SessionSummarySnapshot ensureSession() => $_ensure(3);

  @$pb.TagNumber(11)
  DeleteSessionOutcome get deletion => $_getN(4);
  @$pb.TagNumber(11)
  set deletion(DeleteSessionOutcome value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDeletion() => $_has(4);
  @$pb.TagNumber(11)
  void clearDeletion() => $_clearField(11);
  @$pb.TagNumber(11)
  DeleteSessionOutcome ensureDeletion() => $_ensure(4);

  @$pb.TagNumber(12)
  StableError get error => $_getN(5);
  @$pb.TagNumber(12)
  set error(StableError value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(12)
  void clearError() => $_clearField(12);
  @$pb.TagNumber(12)
  StableError ensureError() => $_ensure(5);
}

class GetSessionTreeRequest extends $pb.GeneratedMessage {
  factory GetSessionTreeRequest({
    $fixnum.Int64? requestId,
    $core.String? projectId,
    $core.String? sessionId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  GetSessionTreeRequest._();

  factory GetSessionTreeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionTreeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionTreeRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'projectId')
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionTreeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionTreeRequest copyWith(
          void Function(GetSessionTreeRequest) updates) =>
      super.copyWith((message) => updates(message as GetSessionTreeRequest))
          as GetSessionTreeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionTreeRequest create() => GetSessionTreeRequest._();
  @$core.override
  GetSessionTreeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionTreeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionTreeRequest>(create);
  static GetSessionTreeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get projectId => $_getSZ(1);
  @$pb.TagNumber(2)
  set projectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProjectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);
}

class GetSessionTreeResponse extends $pb.GeneratedMessage {
  factory GetSessionTreeResponse({
    $fixnum.Int64? requestId,
    SessionTreeSnapshot? tree,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (tree != null) result.tree = tree;
    return result;
  }

  GetSessionTreeResponse._();

  factory GetSessionTreeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionTreeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionTreeResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<SessionTreeSnapshot>(2, _omitFieldNames ? '' : 'tree',
        subBuilder: SessionTreeSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionTreeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionTreeResponse copyWith(
          void Function(GetSessionTreeResponse) updates) =>
      super.copyWith((message) => updates(message as GetSessionTreeResponse))
          as GetSessionTreeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionTreeResponse create() => GetSessionTreeResponse._();
  @$core.override
  GetSessionTreeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionTreeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionTreeResponse>(create);
  static GetSessionTreeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  SessionTreeSnapshot get tree => $_getN(1);
  @$pb.TagNumber(2)
  set tree(SessionTreeSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTree() => $_has(1);
  @$pb.TagNumber(2)
  void clearTree() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionTreeSnapshot ensureTree() => $_ensure(1);
}

class NavigateSessionTreeCommand extends $pb.GeneratedMessage {
  factory NavigateSessionTreeCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    $core.String? entryId,
    $core.String? expectedAdminRevision,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (entryId != null) result.entryId = entryId;
    if (expectedAdminRevision != null)
      result.expectedAdminRevision = expectedAdminRevision;
    return result;
  }

  NavigateSessionTreeCommand._();

  factory NavigateSessionTreeCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NavigateSessionTreeCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NavigateSessionTreeCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aOS(5, _omitFieldNames ? '' : 'entryId')
    ..aOS(6, _omitFieldNames ? '' : 'expectedAdminRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NavigateSessionTreeCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NavigateSessionTreeCommand copyWith(
          void Function(NavigateSessionTreeCommand) updates) =>
      super.copyWith(
              (message) => updates(message as NavigateSessionTreeCommand))
          as NavigateSessionTreeCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NavigateSessionTreeCommand create() => NavigateSessionTreeCommand._();
  @$core.override
  NavigateSessionTreeCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NavigateSessionTreeCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NavigateSessionTreeCommand>(create);
  static NavigateSessionTreeCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get entryId => $_getSZ(4);
  @$pb.TagNumber(5)
  set entryId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEntryId() => $_has(4);
  @$pb.TagNumber(5)
  void clearEntryId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get expectedAdminRevision => $_getSZ(5);
  @$pb.TagNumber(6)
  set expectedAdminRevision($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedAdminRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedAdminRevision() => $_clearField(6);
}

class ForkSessionCommand extends $pb.GeneratedMessage {
  factory ForkSessionCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    $core.String? userEntryId,
    $core.String? expectedAdminRevision,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (userEntryId != null) result.userEntryId = userEntryId;
    if (expectedAdminRevision != null)
      result.expectedAdminRevision = expectedAdminRevision;
    return result;
  }

  ForkSessionCommand._();

  factory ForkSessionCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForkSessionCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForkSessionCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aOS(5, _omitFieldNames ? '' : 'userEntryId')
    ..aOS(6, _omitFieldNames ? '' : 'expectedAdminRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkSessionCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForkSessionCommand copyWith(void Function(ForkSessionCommand) updates) =>
      super.copyWith((message) => updates(message as ForkSessionCommand))
          as ForkSessionCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForkSessionCommand create() => ForkSessionCommand._();
  @$core.override
  ForkSessionCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForkSessionCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForkSessionCommand>(create);
  static ForkSessionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userEntryId => $_getSZ(4);
  @$pb.TagNumber(5)
  set userEntryId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserEntryId() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserEntryId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get expectedAdminRevision => $_getSZ(5);
  @$pb.TagNumber(6)
  set expectedAdminRevision($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedAdminRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedAdminRevision() => $_clearField(6);
}

class CloneSessionCommand extends $pb.GeneratedMessage {
  factory CloneSessionCommand({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    $core.String? projectId,
    $core.String? sessionId,
    $core.String? expectedAdminRevision,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (projectId != null) result.projectId = projectId;
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedAdminRevision != null)
      result.expectedAdminRevision = expectedAdminRevision;
    return result;
  }

  CloneSessionCommand._();

  factory CloneSessionCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloneSessionCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloneSessionCommand',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOS(3, _omitFieldNames ? '' : 'projectId')
    ..aOS(4, _omitFieldNames ? '' : 'sessionId')
    ..aOS(5, _omitFieldNames ? '' : 'expectedAdminRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloneSessionCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloneSessionCommand copyWith(void Function(CloneSessionCommand) updates) =>
      super.copyWith((message) => updates(message as CloneSessionCommand))
          as CloneSessionCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloneSessionCommand create() => CloneSessionCommand._();
  @$core.override
  CloneSessionCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloneSessionCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloneSessionCommand>(create);
  static CloneSessionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get projectId => $_getSZ(2);
  @$pb.TagNumber(3)
  set projectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProjectId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSessionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get expectedAdminRevision => $_getSZ(4);
  @$pb.TagNumber(5)
  set expectedAdminRevision($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedAdminRevision() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedAdminRevision() => $_clearField(5);
}

class SessionTreeMutationResult extends $pb.GeneratedMessage {
  factory SessionTreeMutationResult({
    SessionDetailSnapshot? session,
    SessionTreeSnapshot? tree,
    $core.String? editorText,
  }) {
    final result = create();
    if (session != null) result.session = session;
    if (tree != null) result.tree = tree;
    if (editorText != null) result.editorText = editorText;
    return result;
  }

  SessionTreeMutationResult._();

  factory SessionTreeMutationResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionTreeMutationResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionTreeMutationResult',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<SessionDetailSnapshot>(1, _omitFieldNames ? '' : 'session',
        subBuilder: SessionDetailSnapshot.create)
    ..aOM<SessionTreeSnapshot>(2, _omitFieldNames ? '' : 'tree',
        subBuilder: SessionTreeSnapshot.create)
    ..aOS(3, _omitFieldNames ? '' : 'editorText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeMutationResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeMutationResult copyWith(
          void Function(SessionTreeMutationResult) updates) =>
      super.copyWith((message) => updates(message as SessionTreeMutationResult))
          as SessionTreeMutationResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionTreeMutationResult create() => SessionTreeMutationResult._();
  @$core.override
  SessionTreeMutationResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionTreeMutationResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionTreeMutationResult>(create);
  static SessionTreeMutationResult? _defaultInstance;

  @$pb.TagNumber(1)
  SessionDetailSnapshot get session => $_getN(0);
  @$pb.TagNumber(1)
  set session(SessionDetailSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionDetailSnapshot ensureSession() => $_ensure(0);

  @$pb.TagNumber(2)
  SessionTreeSnapshot get tree => $_getN(1);
  @$pb.TagNumber(2)
  set tree(SessionTreeSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTree() => $_has(1);
  @$pb.TagNumber(2)
  void clearTree() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionTreeSnapshot ensureTree() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get editorText => $_getSZ(2);
  @$pb.TagNumber(3)
  set editorText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEditorText() => $_has(2);
  @$pb.TagNumber(3)
  void clearEditorText() => $_clearField(3);
}

enum SessionTreeMutationOutcome_Outcome { result, error, notSet }

class SessionTreeMutationOutcome extends $pb.GeneratedMessage {
  factory SessionTreeMutationOutcome({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    SessionTreeMutationOperation? operation,
    SessionTreeMutationResult? result,
    StableError? error,
  }) {
    final result$ = create();
    if (requestId != null) result$.requestId = requestId;
    if (commandId != null) result$.commandId = commandId;
    if (operation != null) result$.operation = operation;
    if (result != null) result$.result = result;
    if (error != null) result$.error = error;
    return result$;
  }

  SessionTreeMutationOutcome._();

  factory SessionTreeMutationOutcome.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionTreeMutationOutcome.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SessionTreeMutationOutcome_Outcome>
      _SessionTreeMutationOutcome_OutcomeByTag = {
    10: SessionTreeMutationOutcome_Outcome.result,
    11: SessionTreeMutationOutcome_Outcome.error,
    0: SessionTreeMutationOutcome_Outcome.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionTreeMutationOutcome',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [10, 11])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aE<SessionTreeMutationOperation>(3, _omitFieldNames ? '' : 'operation',
        enumValues: SessionTreeMutationOperation.values)
    ..aOM<SessionTreeMutationResult>(10, _omitFieldNames ? '' : 'result',
        subBuilder: SessionTreeMutationResult.create)
    ..aOM<StableError>(11, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeMutationOutcome clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeMutationOutcome copyWith(
          void Function(SessionTreeMutationOutcome) updates) =>
      super.copyWith(
              (message) => updates(message as SessionTreeMutationOutcome))
          as SessionTreeMutationOutcome;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionTreeMutationOutcome create() => SessionTreeMutationOutcome._();
  @$core.override
  SessionTreeMutationOutcome createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionTreeMutationOutcome getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionTreeMutationOutcome>(create);
  static SessionTreeMutationOutcome? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  SessionTreeMutationOutcome_Outcome whichOutcome() =>
      _SessionTreeMutationOutcome_OutcomeByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearOutcome() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  SessionTreeMutationOperation get operation => $_getN(2);
  @$pb.TagNumber(3)
  set operation(SessionTreeMutationOperation value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOperation() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperation() => $_clearField(3);

  @$pb.TagNumber(10)
  SessionTreeMutationResult get result => $_getN(3);
  @$pb.TagNumber(10)
  set result(SessionTreeMutationResult value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasResult() => $_has(3);
  @$pb.TagNumber(10)
  void clearResult() => $_clearField(10);
  @$pb.TagNumber(10)
  SessionTreeMutationResult ensureResult() => $_ensure(3);

  @$pb.TagNumber(11)
  StableError get error => $_getN(4);
  @$pb.TagNumber(11)
  set error(StableError value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(11)
  void clearError() => $_clearField(11);
  @$pb.TagNumber(11)
  StableError ensureError() => $_ensure(4);
}

class RequestRejected extends $pb.GeneratedMessage {
  factory RequestRejected({
    $fixnum.Int64? requestId,
    StableError? error,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (error != null) result.error = error;
    return result;
  }

  RequestRejected._();

  factory RequestRejected.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestRejected.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestRejected',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<StableError>(2, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestRejected clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestRejected copyWith(void Function(RequestRejected) updates) =>
      super.copyWith((message) => updates(message as RequestRejected))
          as RequestRejected;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestRejected create() => RequestRejected._();
  @$core.override
  RequestRejected createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestRejected getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestRejected>(create);
  static RequestRejected? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  StableError get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(StableError value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  StableError ensureError() => $_ensure(1);
}

class CommandAccepted extends $pb.GeneratedMessage {
  factory CommandAccepted({
    $fixnum.Int64? requestId,
    $core.String? commandId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    return result;
  }

  CommandAccepted._();

  factory CommandAccepted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandAccepted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandAccepted',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandAccepted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandAccepted copyWith(void Function(CommandAccepted) updates) =>
      super.copyWith((message) => updates(message as CommandAccepted))
          as CommandAccepted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandAccepted create() => CommandAccepted._();
  @$core.override
  CommandAccepted createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandAccepted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandAccepted>(create);
  static CommandAccepted? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);
}

class CommandRejected extends $pb.GeneratedMessage {
  factory CommandRejected({
    $fixnum.Int64? requestId,
    $core.String? commandId,
    StableError? error,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (commandId != null) result.commandId = commandId;
    if (error != null) result.error = error;
    return result;
  }

  CommandRejected._();

  factory CommandRejected.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandRejected.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandRejected',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'commandId')
    ..aOM<StableError>(3, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandRejected clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandRejected copyWith(void Function(CommandRejected) updates) =>
      super.copyWith((message) => updates(message as CommandRejected))
          as CommandRejected;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandRejected create() => CommandRejected._();
  @$core.override
  CommandRejected createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandRejected getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandRejected>(create);
  static CommandRejected? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commandId => $_getSZ(1);
  @$pb.TagNumber(2)
  set commandId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommandId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommandId() => $_clearField(2);

  @$pb.TagNumber(3)
  StableError get error => $_getN(2);
  @$pb.TagNumber(3)
  set error(StableError value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  StableError ensureError() => $_ensure(2);
}

class SessionSummarySnapshot extends $pb.GeneratedMessage {
  factory SessionSummarySnapshot({
    $core.String? sessionId,
    $core.String? title,
    $core.String? workingDirectory,
    $fixnum.Int64? createdAtUnixMillis,
    $fixnum.Int64? updatedAtUnixMillis,
    $core.bool? isRunning,
    $core.bool? hasUnread,
    $core.String? adminRevision,
    $core.bool? hasCustomName,
    $core.String? parentSessionId,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (title != null) result.title = title;
    if (workingDirectory != null) result.workingDirectory = workingDirectory;
    if (createdAtUnixMillis != null)
      result.createdAtUnixMillis = createdAtUnixMillis;
    if (updatedAtUnixMillis != null)
      result.updatedAtUnixMillis = updatedAtUnixMillis;
    if (isRunning != null) result.isRunning = isRunning;
    if (hasUnread != null) result.hasUnread = hasUnread;
    if (adminRevision != null) result.adminRevision = adminRevision;
    if (hasCustomName != null) result.hasCustomName = hasCustomName;
    if (parentSessionId != null) result.parentSessionId = parentSessionId;
    return result;
  }

  SessionSummarySnapshot._();

  factory SessionSummarySnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionSummarySnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionSummarySnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'workingDirectory')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'createdAtUnixMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'updatedAtUnixMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(6, _omitFieldNames ? '' : 'isRunning')
    ..aOB(7, _omitFieldNames ? '' : 'hasUnread')
    ..aOS(8, _omitFieldNames ? '' : 'adminRevision')
    ..aOB(9, _omitFieldNames ? '' : 'hasCustomName')
    ..aOS(10, _omitFieldNames ? '' : 'parentSessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSummarySnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSummarySnapshot copyWith(
          void Function(SessionSummarySnapshot) updates) =>
      super.copyWith((message) => updates(message as SessionSummarySnapshot))
          as SessionSummarySnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionSummarySnapshot create() => SessionSummarySnapshot._();
  @$core.override
  SessionSummarySnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionSummarySnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionSummarySnapshot>(create);
  static SessionSummarySnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get workingDirectory => $_getSZ(2);
  @$pb.TagNumber(3)
  set workingDirectory($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWorkingDirectory() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkingDirectory() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAtUnixMillis => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAtUnixMillis($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAtUnixMillis() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAtUnixMillis() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get updatedAtUnixMillis => $_getI64(4);
  @$pb.TagNumber(5)
  set updatedAtUnixMillis($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAtUnixMillis() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAtUnixMillis() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isRunning => $_getBF(5);
  @$pb.TagNumber(6)
  set isRunning($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsRunning() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsRunning() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get hasUnread => $_getBF(6);
  @$pb.TagNumber(7)
  set hasUnread($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHasUnread() => $_has(6);
  @$pb.TagNumber(7)
  void clearHasUnread() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get adminRevision => $_getSZ(7);
  @$pb.TagNumber(8)
  set adminRevision($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAdminRevision() => $_has(7);
  @$pb.TagNumber(8)
  void clearAdminRevision() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasCustomName => $_getBF(8);
  @$pb.TagNumber(9)
  set hasCustomName($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHasCustomName() => $_has(8);
  @$pb.TagNumber(9)
  void clearHasCustomName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get parentSessionId => $_getSZ(9);
  @$pb.TagNumber(10)
  set parentSessionId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasParentSessionId() => $_has(9);
  @$pb.TagNumber(10)
  void clearParentSessionId() => $_clearField(10);
}

class SessionDetailSnapshot extends $pb.GeneratedMessage {
  factory SessionDetailSnapshot({
    SessionSummarySnapshot? summary,
    $core.Iterable<MessageSnapshot>? messages,
  }) {
    final result = create();
    if (summary != null) result.summary = summary;
    if (messages != null) result.messages.addAll(messages);
    return result;
  }

  SessionDetailSnapshot._();

  factory SessionDetailSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionDetailSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionDetailSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<SessionSummarySnapshot>(1, _omitFieldNames ? '' : 'summary',
        subBuilder: SessionSummarySnapshot.create)
    ..pPM<MessageSnapshot>(2, _omitFieldNames ? '' : 'messages',
        subBuilder: MessageSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionDetailSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionDetailSnapshot copyWith(
          void Function(SessionDetailSnapshot) updates) =>
      super.copyWith((message) => updates(message as SessionDetailSnapshot))
          as SessionDetailSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionDetailSnapshot create() => SessionDetailSnapshot._();
  @$core.override
  SessionDetailSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionDetailSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionDetailSnapshot>(create);
  static SessionDetailSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSummarySnapshot get summary => $_getN(0);
  @$pb.TagNumber(1)
  set summary(SessionSummarySnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSummary() => $_has(0);
  @$pb.TagNumber(1)
  void clearSummary() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSummarySnapshot ensureSummary() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<MessageSnapshot> get messages => $_getList(1);
}

class MessageSnapshot extends $pb.GeneratedMessage {
  factory MessageSnapshot({
    $core.String? messageId,
    MessageRole? role,
    $core.String? text,
    $fixnum.Int64? createdAtUnixMillis,
    $core.bool? isStreaming,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (role != null) result.role = role;
    if (text != null) result.text = text;
    if (createdAtUnixMillis != null)
      result.createdAtUnixMillis = createdAtUnixMillis;
    if (isStreaming != null) result.isStreaming = isStreaming;
    return result;
  }

  MessageSnapshot._();

  factory MessageSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aE<MessageRole>(2, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'createdAtUnixMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'isStreaming')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSnapshot copyWith(void Function(MessageSnapshot) updates) =>
      super.copyWith((message) => updates(message as MessageSnapshot))
          as MessageSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSnapshot create() => MessageSnapshot._();
  @$core.override
  MessageSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageSnapshot>(create);
  static MessageSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  MessageRole get role => $_getN(1);
  @$pb.TagNumber(2)
  set role(MessageRole value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAtUnixMillis => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAtUnixMillis($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAtUnixMillis() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAtUnixMillis() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isStreaming => $_getBF(4);
  @$pb.TagNumber(5)
  set isStreaming($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsStreaming() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsStreaming() => $_clearField(5);
}

class SessionTreeNodeSnapshot extends $pb.GeneratedMessage {
  factory SessionTreeNodeSnapshot({
    $core.String? entryId,
    $core.String? parentEntryId,
    SessionTreeEntryKind? kind,
    $core.String? text,
    $fixnum.Int64? createdAtUnixMillis,
    $core.String? label,
    $core.int? depth,
    $core.bool? isOnActivePath,
    $core.bool? hasChildren,
    $core.bool? canEditFromHere,
    $core.bool? canFork,
  }) {
    final result = create();
    if (entryId != null) result.entryId = entryId;
    if (parentEntryId != null) result.parentEntryId = parentEntryId;
    if (kind != null) result.kind = kind;
    if (text != null) result.text = text;
    if (createdAtUnixMillis != null)
      result.createdAtUnixMillis = createdAtUnixMillis;
    if (label != null) result.label = label;
    if (depth != null) result.depth = depth;
    if (isOnActivePath != null) result.isOnActivePath = isOnActivePath;
    if (hasChildren != null) result.hasChildren = hasChildren;
    if (canEditFromHere != null) result.canEditFromHere = canEditFromHere;
    if (canFork != null) result.canFork = canFork;
    return result;
  }

  SessionTreeNodeSnapshot._();

  factory SessionTreeNodeSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionTreeNodeSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionTreeNodeSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'parentEntryId')
    ..aE<SessionTreeEntryKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: SessionTreeEntryKind.values)
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'createdAtUnixMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'label')
    ..aI(7, _omitFieldNames ? '' : 'depth', fieldType: $pb.PbFieldType.OU3)
    ..aOB(8, _omitFieldNames ? '' : 'isOnActivePath')
    ..aOB(9, _omitFieldNames ? '' : 'hasChildren')
    ..aOB(10, _omitFieldNames ? '' : 'canEditFromHere')
    ..aOB(11, _omitFieldNames ? '' : 'canFork')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeNodeSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeNodeSnapshot copyWith(
          void Function(SessionTreeNodeSnapshot) updates) =>
      super.copyWith((message) => updates(message as SessionTreeNodeSnapshot))
          as SessionTreeNodeSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionTreeNodeSnapshot create() => SessionTreeNodeSnapshot._();
  @$core.override
  SessionTreeNodeSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionTreeNodeSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionTreeNodeSnapshot>(create);
  static SessionTreeNodeSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get parentEntryId => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentEntryId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentEntryId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentEntryId() => $_clearField(2);

  @$pb.TagNumber(3)
  SessionTreeEntryKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(SessionTreeEntryKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAtUnixMillis => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAtUnixMillis($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAtUnixMillis() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAtUnixMillis() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get label => $_getSZ(5);
  @$pb.TagNumber(6)
  set label($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearLabel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get depth => $_getIZ(6);
  @$pb.TagNumber(7)
  set depth($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDepth() => $_has(6);
  @$pb.TagNumber(7)
  void clearDepth() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isOnActivePath => $_getBF(7);
  @$pb.TagNumber(8)
  set isOnActivePath($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsOnActivePath() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsOnActivePath() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasChildren => $_getBF(8);
  @$pb.TagNumber(9)
  set hasChildren($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHasChildren() => $_has(8);
  @$pb.TagNumber(9)
  void clearHasChildren() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get canEditFromHere => $_getBF(9);
  @$pb.TagNumber(10)
  set canEditFromHere($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCanEditFromHere() => $_has(9);
  @$pb.TagNumber(10)
  void clearCanEditFromHere() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get canFork => $_getBF(10);
  @$pb.TagNumber(11)
  set canFork($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCanFork() => $_has(10);
  @$pb.TagNumber(11)
  void clearCanFork() => $_clearField(11);
}

class SessionTreeSnapshot extends $pb.GeneratedMessage {
  factory SessionTreeSnapshot({
    $core.String? sessionId,
    $core.Iterable<SessionTreeNodeSnapshot>? nodes,
    $core.Iterable<$core.String>? activePathEntryIds,
    $core.String? activeLeafEntryId,
    $core.bool? canCloneActiveBranch,
    $core.String? adminRevision,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (nodes != null) result.nodes.addAll(nodes);
    if (activePathEntryIds != null)
      result.activePathEntryIds.addAll(activePathEntryIds);
    if (activeLeafEntryId != null) result.activeLeafEntryId = activeLeafEntryId;
    if (canCloneActiveBranch != null)
      result.canCloneActiveBranch = canCloneActiveBranch;
    if (adminRevision != null) result.adminRevision = adminRevision;
    return result;
  }

  SessionTreeSnapshot._();

  factory SessionTreeSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionTreeSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionTreeSnapshot',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..pPM<SessionTreeNodeSnapshot>(2, _omitFieldNames ? '' : 'nodes',
        subBuilder: SessionTreeNodeSnapshot.create)
    ..pPS(3, _omitFieldNames ? '' : 'activePathEntryIds')
    ..aOS(4, _omitFieldNames ? '' : 'activeLeafEntryId')
    ..aOB(5, _omitFieldNames ? '' : 'canCloneActiveBranch')
    ..aOS(6, _omitFieldNames ? '' : 'adminRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionTreeSnapshot copyWith(void Function(SessionTreeSnapshot) updates) =>
      super.copyWith((message) => updates(message as SessionTreeSnapshot))
          as SessionTreeSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionTreeSnapshot create() => SessionTreeSnapshot._();
  @$core.override
  SessionTreeSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionTreeSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionTreeSnapshot>(create);
  static SessionTreeSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<SessionTreeNodeSnapshot> get nodes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get activePathEntryIds => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get activeLeafEntryId => $_getSZ(3);
  @$pb.TagNumber(4)
  set activeLeafEntryId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActiveLeafEntryId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveLeafEntryId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get canCloneActiveBranch => $_getBF(4);
  @$pb.TagNumber(5)
  set canCloneActiveBranch($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCanCloneActiveBranch() => $_has(4);
  @$pb.TagNumber(5)
  void clearCanCloneActiveBranch() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get adminRevision => $_getSZ(5);
  @$pb.TagNumber(6)
  set adminRevision($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAdminRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearAdminRevision() => $_clearField(6);
}

enum SessionEventStreamEnvelope_Event {
  messageAdded,
  messageDelta,
  runningChanged,
  commandCompleted,
  streamClosed,
  notSet
}

/// Each stream is bound to one session. event_sequence is strictly increasing
/// within stream_id and is independent of PiTransportFrame.frame_sequence.
class SessionEventStreamEnvelope extends $pb.GeneratedMessage {
  factory SessionEventStreamEnvelope({
    $core.String? streamId,
    $core.String? sessionId,
    $fixnum.Int64? eventSequence,
    MessageAddedEvent? messageAdded,
    MessageDeltaEvent? messageDelta,
    SessionRunningChangedEvent? runningChanged,
    CommandCompletedEvent? commandCompleted,
    StreamClosedEvent? streamClosed,
  }) {
    final result = create();
    if (streamId != null) result.streamId = streamId;
    if (sessionId != null) result.sessionId = sessionId;
    if (eventSequence != null) result.eventSequence = eventSequence;
    if (messageAdded != null) result.messageAdded = messageAdded;
    if (messageDelta != null) result.messageDelta = messageDelta;
    if (runningChanged != null) result.runningChanged = runningChanged;
    if (commandCompleted != null) result.commandCompleted = commandCompleted;
    if (streamClosed != null) result.streamClosed = streamClosed;
    return result;
  }

  SessionEventStreamEnvelope._();

  factory SessionEventStreamEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionEventStreamEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SessionEventStreamEnvelope_Event>
      _SessionEventStreamEnvelope_EventByTag = {
    10: SessionEventStreamEnvelope_Event.messageAdded,
    11: SessionEventStreamEnvelope_Event.messageDelta,
    12: SessionEventStreamEnvelope_Event.runningChanged,
    13: SessionEventStreamEnvelope_Event.commandCompleted,
    14: SessionEventStreamEnvelope_Event.streamClosed,
    0: SessionEventStreamEnvelope_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionEventStreamEnvelope',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12, 13, 14])
    ..aOS(1, _omitFieldNames ? '' : 'streamId')
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'eventSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MessageAddedEvent>(10, _omitFieldNames ? '' : 'messageAdded',
        subBuilder: MessageAddedEvent.create)
    ..aOM<MessageDeltaEvent>(11, _omitFieldNames ? '' : 'messageDelta',
        subBuilder: MessageDeltaEvent.create)
    ..aOM<SessionRunningChangedEvent>(
        12, _omitFieldNames ? '' : 'runningChanged',
        subBuilder: SessionRunningChangedEvent.create)
    ..aOM<CommandCompletedEvent>(13, _omitFieldNames ? '' : 'commandCompleted',
        subBuilder: CommandCompletedEvent.create)
    ..aOM<StreamClosedEvent>(14, _omitFieldNames ? '' : 'streamClosed',
        subBuilder: StreamClosedEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionEventStreamEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionEventStreamEnvelope copyWith(
          void Function(SessionEventStreamEnvelope) updates) =>
      super.copyWith(
              (message) => updates(message as SessionEventStreamEnvelope))
          as SessionEventStreamEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionEventStreamEnvelope create() => SessionEventStreamEnvelope._();
  @$core.override
  SessionEventStreamEnvelope createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionEventStreamEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionEventStreamEnvelope>(create);
  static SessionEventStreamEnvelope? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  SessionEventStreamEnvelope_Event whichEvent() =>
      _SessionEventStreamEnvelope_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get streamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set streamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStreamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStreamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get eventSequence => $_getI64(2);
  @$pb.TagNumber(3)
  set eventSequence($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEventSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearEventSequence() => $_clearField(3);

  @$pb.TagNumber(10)
  MessageAddedEvent get messageAdded => $_getN(3);
  @$pb.TagNumber(10)
  set messageAdded(MessageAddedEvent value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasMessageAdded() => $_has(3);
  @$pb.TagNumber(10)
  void clearMessageAdded() => $_clearField(10);
  @$pb.TagNumber(10)
  MessageAddedEvent ensureMessageAdded() => $_ensure(3);

  @$pb.TagNumber(11)
  MessageDeltaEvent get messageDelta => $_getN(4);
  @$pb.TagNumber(11)
  set messageDelta(MessageDeltaEvent value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMessageDelta() => $_has(4);
  @$pb.TagNumber(11)
  void clearMessageDelta() => $_clearField(11);
  @$pb.TagNumber(11)
  MessageDeltaEvent ensureMessageDelta() => $_ensure(4);

  @$pb.TagNumber(12)
  SessionRunningChangedEvent get runningChanged => $_getN(5);
  @$pb.TagNumber(12)
  set runningChanged(SessionRunningChangedEvent value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasRunningChanged() => $_has(5);
  @$pb.TagNumber(12)
  void clearRunningChanged() => $_clearField(12);
  @$pb.TagNumber(12)
  SessionRunningChangedEvent ensureRunningChanged() => $_ensure(5);

  @$pb.TagNumber(13)
  CommandCompletedEvent get commandCompleted => $_getN(6);
  @$pb.TagNumber(13)
  set commandCompleted(CommandCompletedEvent value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCommandCompleted() => $_has(6);
  @$pb.TagNumber(13)
  void clearCommandCompleted() => $_clearField(13);
  @$pb.TagNumber(13)
  CommandCompletedEvent ensureCommandCompleted() => $_ensure(6);

  @$pb.TagNumber(14)
  StreamClosedEvent get streamClosed => $_getN(7);
  @$pb.TagNumber(14)
  set streamClosed(StreamClosedEvent value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasStreamClosed() => $_has(7);
  @$pb.TagNumber(14)
  void clearStreamClosed() => $_clearField(14);
  @$pb.TagNumber(14)
  StreamClosedEvent ensureStreamClosed() => $_ensure(7);
}

class MessageAddedEvent extends $pb.GeneratedMessage {
  factory MessageAddedEvent({
    MessageSnapshot? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  MessageAddedEvent._();

  factory MessageAddedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageAddedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageAddedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOM<MessageSnapshot>(1, _omitFieldNames ? '' : 'message',
        subBuilder: MessageSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageAddedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageAddedEvent copyWith(void Function(MessageAddedEvent) updates) =>
      super.copyWith((message) => updates(message as MessageAddedEvent))
          as MessageAddedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageAddedEvent create() => MessageAddedEvent._();
  @$core.override
  MessageAddedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageAddedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageAddedEvent>(create);
  static MessageAddedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  MessageSnapshot get message => $_getN(0);
  @$pb.TagNumber(1)
  set message(MessageSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  MessageSnapshot ensureMessage() => $_ensure(0);
}

class MessageDeltaEvent extends $pb.GeneratedMessage {
  factory MessageDeltaEvent({
    $core.String? messageId,
    $core.String? delta,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (delta != null) result.delta = delta;
    return result;
  }

  MessageDeltaEvent._();

  factory MessageDeltaEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageDeltaEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageDeltaEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'delta')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageDeltaEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageDeltaEvent copyWith(void Function(MessageDeltaEvent) updates) =>
      super.copyWith((message) => updates(message as MessageDeltaEvent))
          as MessageDeltaEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageDeltaEvent create() => MessageDeltaEvent._();
  @$core.override
  MessageDeltaEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageDeltaEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageDeltaEvent>(create);
  static MessageDeltaEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get delta => $_getSZ(1);
  @$pb.TagNumber(2)
  set delta($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDelta() => $_has(1);
  @$pb.TagNumber(2)
  void clearDelta() => $_clearField(2);
}

class SessionRunningChangedEvent extends $pb.GeneratedMessage {
  factory SessionRunningChangedEvent({
    $core.bool? isRunning,
  }) {
    final result = create();
    if (isRunning != null) result.isRunning = isRunning;
    return result;
  }

  SessionRunningChangedEvent._();

  factory SessionRunningChangedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionRunningChangedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionRunningChangedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isRunning')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRunningChangedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRunningChangedEvent copyWith(
          void Function(SessionRunningChangedEvent) updates) =>
      super.copyWith(
              (message) => updates(message as SessionRunningChangedEvent))
          as SessionRunningChangedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionRunningChangedEvent create() => SessionRunningChangedEvent._();
  @$core.override
  SessionRunningChangedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionRunningChangedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionRunningChangedEvent>(create);
  static SessionRunningChangedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isRunning => $_getBF(0);
  @$pb.TagNumber(1)
  set isRunning($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsRunning() => $_clearField(1);
}

class CommandCompletedEvent extends $pb.GeneratedMessage {
  factory CommandCompletedEvent({
    $core.String? commandId,
    $core.bool? succeeded,
    StableError? error,
  }) {
    final result = create();
    if (commandId != null) result.commandId = commandId;
    if (succeeded != null) result.succeeded = succeeded;
    if (error != null) result.error = error;
    return result;
  }

  CommandCompletedEvent._();

  factory CommandCompletedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandCompletedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandCompletedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aOB(2, _omitFieldNames ? '' : 'succeeded')
    ..aOM<StableError>(3, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandCompletedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandCompletedEvent copyWith(
          void Function(CommandCompletedEvent) updates) =>
      super.copyWith((message) => updates(message as CommandCompletedEvent))
          as CommandCompletedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandCompletedEvent create() => CommandCompletedEvent._();
  @$core.override
  CommandCompletedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandCompletedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandCompletedEvent>(create);
  static CommandCompletedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get succeeded => $_getBF(1);
  @$pb.TagNumber(2)
  set succeeded($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSucceeded() => $_has(1);
  @$pb.TagNumber(2)
  void clearSucceeded() => $_clearField(2);

  @$pb.TagNumber(3)
  StableError get error => $_getN(2);
  @$pb.TagNumber(3)
  set error(StableError value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  StableError ensureError() => $_ensure(2);
}

enum EventStreamEnvelope_Event {
  heartbeat,
  healthStatusChanged,
  streamClosed,
  notSet
}

/// EventStreamEnvelope retains non-session streams used by transport health and
/// future bounded control surfaces.
class EventStreamEnvelope extends $pb.GeneratedMessage {
  factory EventStreamEnvelope({
    $core.String? streamId,
    $fixnum.Int64? eventSequence,
    HeartbeatEvent? heartbeat,
    HealthStatusChangedEvent? healthStatusChanged,
    StreamClosedEvent? streamClosed,
  }) {
    final result = create();
    if (streamId != null) result.streamId = streamId;
    if (eventSequence != null) result.eventSequence = eventSequence;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (healthStatusChanged != null)
      result.healthStatusChanged = healthStatusChanged;
    if (streamClosed != null) result.streamClosed = streamClosed;
    return result;
  }

  EventStreamEnvelope._();

  factory EventStreamEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EventStreamEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, EventStreamEnvelope_Event>
      _EventStreamEnvelope_EventByTag = {
    10: EventStreamEnvelope_Event.heartbeat,
    11: EventStreamEnvelope_Event.healthStatusChanged,
    12: EventStreamEnvelope_Event.streamClosed,
    0: EventStreamEnvelope_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventStreamEnvelope',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12])
    ..aOS(1, _omitFieldNames ? '' : 'streamId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'eventSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<HeartbeatEvent>(10, _omitFieldNames ? '' : 'heartbeat',
        subBuilder: HeartbeatEvent.create)
    ..aOM<HealthStatusChangedEvent>(
        11, _omitFieldNames ? '' : 'healthStatusChanged',
        subBuilder: HealthStatusChangedEvent.create)
    ..aOM<StreamClosedEvent>(12, _omitFieldNames ? '' : 'streamClosed',
        subBuilder: StreamClosedEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventStreamEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventStreamEnvelope copyWith(void Function(EventStreamEnvelope) updates) =>
      super.copyWith((message) => updates(message as EventStreamEnvelope))
          as EventStreamEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EventStreamEnvelope create() => EventStreamEnvelope._();
  @$core.override
  EventStreamEnvelope createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EventStreamEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EventStreamEnvelope>(create);
  static EventStreamEnvelope? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  EventStreamEnvelope_Event whichEvent() =>
      _EventStreamEnvelope_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get streamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set streamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStreamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStreamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get eventSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set eventSequence($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEventSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventSequence() => $_clearField(2);

  @$pb.TagNumber(10)
  HeartbeatEvent get heartbeat => $_getN(2);
  @$pb.TagNumber(10)
  set heartbeat(HeartbeatEvent value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHeartbeat() => $_has(2);
  @$pb.TagNumber(10)
  void clearHeartbeat() => $_clearField(10);
  @$pb.TagNumber(10)
  HeartbeatEvent ensureHeartbeat() => $_ensure(2);

  @$pb.TagNumber(11)
  HealthStatusChangedEvent get healthStatusChanged => $_getN(3);
  @$pb.TagNumber(11)
  set healthStatusChanged(HealthStatusChangedEvent value) =>
      $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasHealthStatusChanged() => $_has(3);
  @$pb.TagNumber(11)
  void clearHealthStatusChanged() => $_clearField(11);
  @$pb.TagNumber(11)
  HealthStatusChangedEvent ensureHealthStatusChanged() => $_ensure(3);

  @$pb.TagNumber(12)
  StreamClosedEvent get streamClosed => $_getN(4);
  @$pb.TagNumber(12)
  set streamClosed(StreamClosedEvent value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStreamClosed() => $_has(4);
  @$pb.TagNumber(12)
  void clearStreamClosed() => $_clearField(12);
  @$pb.TagNumber(12)
  StreamClosedEvent ensureStreamClosed() => $_ensure(4);
}

class HeartbeatEvent extends $pb.GeneratedMessage {
  factory HeartbeatEvent({
    $fixnum.Int64? observedUnixMillis,
  }) {
    final result = create();
    if (observedUnixMillis != null)
      result.observedUnixMillis = observedUnixMillis;
    return result;
  }

  HeartbeatEvent._();

  factory HeartbeatEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeartbeatEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'observedUnixMillis', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatEvent copyWith(void Function(HeartbeatEvent) updates) =>
      super.copyWith((message) => updates(message as HeartbeatEvent))
          as HeartbeatEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeartbeatEvent create() => HeartbeatEvent._();
  @$core.override
  HeartbeatEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeartbeatEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeartbeatEvent>(create);
  static HeartbeatEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get observedUnixMillis => $_getI64(0);
  @$pb.TagNumber(1)
  set observedUnixMillis($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObservedUnixMillis() => $_has(0);
  @$pb.TagNumber(1)
  void clearObservedUnixMillis() => $_clearField(1);
}

class HealthStatusChangedEvent extends $pb.GeneratedMessage {
  factory HealthStatusChangedEvent({
    HealthStatus? status,
    $core.String? summary,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (summary != null) result.summary = summary;
    return result;
  }

  HealthStatusChangedEvent._();

  factory HealthStatusChangedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HealthStatusChangedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthStatusChangedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aE<HealthStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: HealthStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'summary')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthStatusChangedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthStatusChangedEvent copyWith(
          void Function(HealthStatusChangedEvent) updates) =>
      super.copyWith((message) => updates(message as HealthStatusChangedEvent))
          as HealthStatusChangedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthStatusChangedEvent create() => HealthStatusChangedEvent._();
  @$core.override
  HealthStatusChangedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HealthStatusChangedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthStatusChangedEvent>(create);
  static HealthStatusChangedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  HealthStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(HealthStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get summary => $_getSZ(1);
  @$pb.TagNumber(2)
  set summary($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSummary() => $_has(1);
  @$pb.TagNumber(2)
  void clearSummary() => $_clearField(2);
}

class StreamClosedEvent extends $pb.GeneratedMessage {
  factory StreamClosedEvent({
    $core.bool? graceful,
    StableError? error,
  }) {
    final result = create();
    if (graceful != null) result.graceful = graceful;
    if (error != null) result.error = error;
    return result;
  }

  StreamClosedEvent._();

  factory StreamClosedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamClosedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamClosedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'graceful')
    ..aOM<StableError>(2, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamClosedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamClosedEvent copyWith(void Function(StreamClosedEvent) updates) =>
      super.copyWith((message) => updates(message as StreamClosedEvent))
          as StreamClosedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamClosedEvent create() => StreamClosedEvent._();
  @$core.override
  StreamClosedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamClosedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamClosedEvent>(create);
  static StreamClosedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get graceful => $_getBF(0);
  @$pb.TagNumber(1)
  set graceful($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGraceful() => $_has(0);
  @$pb.TagNumber(1)
  void clearGraceful() => $_clearField(1);

  @$pb.TagNumber(2)
  StableError get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(StableError value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  StableError ensureError() => $_ensure(1);
}

enum Cancel_Target { requestId, streamId, transferId, notSet }

class Cancel extends $pb.GeneratedMessage {
  factory Cancel({
    $fixnum.Int64? requestId,
    $core.String? streamId,
    $core.String? transferId,
    $core.String? reason,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (streamId != null) result.streamId = streamId;
    if (transferId != null) result.transferId = transferId;
    if (reason != null) result.reason = reason;
    return result;
  }

  Cancel._();

  factory Cancel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Cancel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Cancel_Target> _Cancel_TargetByTag = {
    1: Cancel_Target.requestId,
    2: Cancel_Target.streamId,
    3: Cancel_Target.transferId,
    0: Cancel_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Cancel',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'streamId')
    ..aOS(3, _omitFieldNames ? '' : 'transferId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cancel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cancel copyWith(void Function(Cancel) updates) =>
      super.copyWith((message) => updates(message as Cancel)) as Cancel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cancel create() => Cancel._();
  @$core.override
  Cancel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Cancel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cancel>(create);
  static Cancel? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  Cancel_Target whichTarget() => _Cancel_TargetByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get streamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set streamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStreamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearStreamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get transferId => $_getSZ(2);
  @$pb.TagNumber(3)
  set transferId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTransferId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransferId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

enum WindowUpdate_Target { streamId, transferId, notSet }

class WindowUpdate extends $pb.GeneratedMessage {
  factory WindowUpdate({
    $core.String? streamId,
    $core.String? transferId,
    $core.int? creditMessages,
    $fixnum.Int64? creditBytes,
  }) {
    final result = create();
    if (streamId != null) result.streamId = streamId;
    if (transferId != null) result.transferId = transferId;
    if (creditMessages != null) result.creditMessages = creditMessages;
    if (creditBytes != null) result.creditBytes = creditBytes;
    return result;
  }

  WindowUpdate._();

  factory WindowUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WindowUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WindowUpdate_Target>
      _WindowUpdate_TargetByTag = {
    1: WindowUpdate_Target.streamId,
    2: WindowUpdate_Target.transferId,
    0: WindowUpdate_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WindowUpdate',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'streamId')
    ..aOS(2, _omitFieldNames ? '' : 'transferId')
    ..aI(3, _omitFieldNames ? '' : 'creditMessages',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'creditBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindowUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindowUpdate copyWith(void Function(WindowUpdate) updates) =>
      super.copyWith((message) => updates(message as WindowUpdate))
          as WindowUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WindowUpdate create() => WindowUpdate._();
  @$core.override
  WindowUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WindowUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WindowUpdate>(create);
  static WindowUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  WindowUpdate_Target whichTarget() =>
      _WindowUpdate_TargetByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearTarget() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get streamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set streamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStreamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStreamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get transferId => $_getSZ(1);
  @$pb.TagNumber(2)
  set transferId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTransferId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransferId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get creditMessages => $_getIZ(2);
  @$pb.TagNumber(3)
  set creditMessages($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreditMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreditMessages() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get creditBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set creditBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreditBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreditBytes() => $_clearField(4);
}

class TransferOpen extends $pb.GeneratedMessage {
  factory TransferOpen({
    $core.String? transferId,
    TransferDirection? direction,
    TransferPurpose? purpose,
    $core.String? contentType,
    $core.String? fileName,
    $fixnum.Int64? totalBytes,
    $core.int? chunkBytes,
    $core.List<$core.int>? sha256,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (direction != null) result.direction = direction;
    if (purpose != null) result.purpose = purpose;
    if (contentType != null) result.contentType = contentType;
    if (fileName != null) result.fileName = fileName;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (chunkBytes != null) result.chunkBytes = chunkBytes;
    if (sha256 != null) result.sha256 = sha256;
    return result;
  }

  TransferOpen._();

  factory TransferOpen.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferOpen.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOpen',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transferId')
    ..aE<TransferDirection>(2, _omitFieldNames ? '' : 'direction',
        enumValues: TransferDirection.values)
    ..aE<TransferPurpose>(3, _omitFieldNames ? '' : 'purpose',
        enumValues: TransferPurpose.values)
    ..aOS(4, _omitFieldNames ? '' : 'contentType')
    ..aOS(5, _omitFieldNames ? '' : 'fileName')
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'totalBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'chunkBytes', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'sha256', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOpen clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOpen copyWith(void Function(TransferOpen) updates) =>
      super.copyWith((message) => updates(message as TransferOpen))
          as TransferOpen;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOpen create() => TransferOpen._();
  @$core.override
  TransferOpen createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferOpen getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOpen>(create);
  static TransferOpen? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transferId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transferId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  TransferDirection get direction => $_getN(1);
  @$pb.TagNumber(2)
  set direction(TransferDirection value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDirection() => $_has(1);
  @$pb.TagNumber(2)
  void clearDirection() => $_clearField(2);

  @$pb.TagNumber(3)
  TransferPurpose get purpose => $_getN(2);
  @$pb.TagNumber(3)
  set purpose(TransferPurpose value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPurpose() => $_has(2);
  @$pb.TagNumber(3)
  void clearPurpose() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get contentType => $_getSZ(3);
  @$pb.TagNumber(4)
  set contentType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContentType() => $_has(3);
  @$pb.TagNumber(4)
  void clearContentType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fileName => $_getSZ(4);
  @$pb.TagNumber(5)
  set fileName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFileName() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileName() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set totalBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get chunkBytes => $_getIZ(6);
  @$pb.TagNumber(7)
  set chunkBytes($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChunkBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearChunkBytes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get sha256 => $_getN(7);
  @$pb.TagNumber(8)
  set sha256($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSha256() => $_has(7);
  @$pb.TagNumber(8)
  void clearSha256() => $_clearField(8);
}

class TransferChunk extends $pb.GeneratedMessage {
  factory TransferChunk({
    $core.String? transferId,
    $fixnum.Int64? chunkSequence,
    $fixnum.Int64? offset,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (chunkSequence != null) result.chunkSequence = chunkSequence;
    if (offset != null) result.offset = offset;
    if (data != null) result.data = data;
    return result;
  }

  TransferChunk._();

  factory TransferChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferChunk',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transferId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'chunkSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferChunk copyWith(void Function(TransferChunk) updates) =>
      super.copyWith((message) => updates(message as TransferChunk))
          as TransferChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferChunk create() => TransferChunk._();
  @$core.override
  TransferChunk createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferChunk getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferChunk>(create);
  static TransferChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transferId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transferId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get chunkSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set chunkSequence($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChunkSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearChunkSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(3)
  set offset($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get data => $_getN(3);
  @$pb.TagNumber(4)
  set data($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => $_clearField(4);
}

class TransferAck extends $pb.GeneratedMessage {
  factory TransferAck({
    $core.String? transferId,
    $fixnum.Int64? acknowledgedSequence,
    $fixnum.Int64? committedBytes,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (acknowledgedSequence != null)
      result.acknowledgedSequence = acknowledgedSequence;
    if (committedBytes != null) result.committedBytes = committedBytes;
    return result;
  }

  TransferAck._();

  factory TransferAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferAck',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transferId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'acknowledgedSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'committedBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferAck copyWith(void Function(TransferAck) updates) =>
      super.copyWith((message) => updates(message as TransferAck))
          as TransferAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferAck create() => TransferAck._();
  @$core.override
  TransferAck createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferAck>(create);
  static TransferAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transferId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transferId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get acknowledgedSequence => $_getI64(1);
  @$pb.TagNumber(2)
  set acknowledgedSequence($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAcknowledgedSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearAcknowledgedSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get committedBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set committedBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommittedBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommittedBytes() => $_clearField(3);
}

class TransferComplete extends $pb.GeneratedMessage {
  factory TransferComplete({
    $core.String? transferId,
    $fixnum.Int64? totalBytes,
    $core.List<$core.int>? sha256,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (sha256 != null) result.sha256 = sha256;
    return result;
  }

  TransferComplete._();

  factory TransferComplete.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferComplete.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferComplete',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transferId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'totalBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'sha256', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferComplete clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferComplete copyWith(void Function(TransferComplete) updates) =>
      super.copyWith((message) => updates(message as TransferComplete))
          as TransferComplete;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferComplete create() => TransferComplete._();
  @$core.override
  TransferComplete createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferComplete getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferComplete>(create);
  static TransferComplete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transferId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transferId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get sha256 => $_getN(2);
  @$pb.TagNumber(3)
  set sha256($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearSha256() => $_clearField(3);
}

class TransferAbort extends $pb.GeneratedMessage {
  factory TransferAbort({
    $core.String? transferId,
    StableError? error,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (error != null) result.error = error;
    return result;
  }

  TransferAbort._();

  factory TransferAbort.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferAbort.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferAbort',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'transferId')
    ..aOM<StableError>(2, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferAbort clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferAbort copyWith(void Function(TransferAbort) updates) =>
      super.copyWith((message) => updates(message as TransferAbort))
          as TransferAbort;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferAbort create() => TransferAbort._();
  @$core.override
  TransferAbort createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferAbort getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferAbort>(create);
  static TransferAbort? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get transferId => $_getSZ(0);
  @$pb.TagNumber(1)
  set transferId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  StableError get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(StableError value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  StableError ensureError() => $_ensure(1);
}

class StableError extends $pb.GeneratedMessage {
  factory StableError({
    ErrorCode? code,
    $core.bool? retryable,
    $core.int? retryAfterMillis,
    $core.String? safeMessage,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (retryable != null) result.retryable = retryable;
    if (retryAfterMillis != null) result.retryAfterMillis = retryAfterMillis;
    if (safeMessage != null) result.safeMessage = safeMessage;
    return result;
  }

  StableError._();

  factory StableError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StableError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StableError',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aE<ErrorCode>(1, _omitFieldNames ? '' : 'code',
        enumValues: ErrorCode.values)
    ..aOB(2, _omitFieldNames ? '' : 'retryable')
    ..aI(3, _omitFieldNames ? '' : 'retryAfterMillis',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'safeMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StableError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StableError copyWith(void Function(StableError) updates) =>
      super.copyWith((message) => updates(message as StableError))
          as StableError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StableError create() => StableError._();
  @$core.override
  StableError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StableError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StableError>(create);
  static StableError? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(ErrorCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get retryable => $_getBF(1);
  @$pb.TagNumber(2)
  set retryable($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRetryable() => $_has(1);
  @$pb.TagNumber(2)
  void clearRetryable() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get retryAfterMillis => $_getIZ(2);
  @$pb.TagNumber(3)
  set retryAfterMillis($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRetryAfterMillis() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetryAfterMillis() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get safeMessage => $_getSZ(3);
  @$pb.TagNumber(4)
  set safeMessage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSafeMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearSafeMessage() => $_clearField(4);
}

enum ErrorEnvelope_Correlation { requestId, streamId, transferId, notSet }

class ErrorEnvelope extends $pb.GeneratedMessage {
  factory ErrorEnvelope({
    $fixnum.Int64? requestId,
    $core.String? streamId,
    $core.String? transferId,
    StableError? error,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (streamId != null) result.streamId = streamId;
    if (transferId != null) result.transferId = transferId;
    if (error != null) result.error = error;
    return result;
  }

  ErrorEnvelope._();

  factory ErrorEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ErrorEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ErrorEnvelope_Correlation>
      _ErrorEnvelope_CorrelationByTag = {
    1: ErrorEnvelope_Correlation.requestId,
    2: ErrorEnvelope_Correlation.streamId,
    3: ErrorEnvelope_Correlation.transferId,
    0: ErrorEnvelope_Correlation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ErrorEnvelope',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'streamId')
    ..aOS(3, _omitFieldNames ? '' : 'transferId')
    ..aOM<StableError>(4, _omitFieldNames ? '' : 'error',
        subBuilder: StableError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorEnvelope copyWith(void Function(ErrorEnvelope) updates) =>
      super.copyWith((message) => updates(message as ErrorEnvelope))
          as ErrorEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ErrorEnvelope create() => ErrorEnvelope._();
  @$core.override
  ErrorEnvelope createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ErrorEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ErrorEnvelope>(create);
  static ErrorEnvelope? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  ErrorEnvelope_Correlation whichCorrelation() =>
      _ErrorEnvelope_CorrelationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearCorrelation() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get streamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set streamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStreamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearStreamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get transferId => $_getSZ(2);
  @$pb.TagNumber(3)
  set transferId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTransferId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransferId() => $_clearField(3);

  @$pb.TagNumber(4)
  StableError get error => $_getN(3);
  @$pb.TagNumber(4)
  set error(StableError value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  StableError ensureError() => $_ensure(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
