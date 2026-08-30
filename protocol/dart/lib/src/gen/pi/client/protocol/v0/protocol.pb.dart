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
  sessionEventStream,
  eventStream,
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
    SessionEventStreamEnvelope? sessionEventStream,
    EventStreamEnvelope? eventStream,
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
    if (sessionEventStream != null)
      result.sessionEventStream = sessionEventStream;
    if (eventStream != null) result.eventStream = eventStream;
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
    50: PiTransportFrame_Operation.sessionEventStream,
    51: PiTransportFrame_Operation.eventStream,
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
      50,
      51,
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
    ..aOM<SessionEventStreamEnvelope>(
        50, _omitFieldNames ? '' : 'sessionEventStream',
        subBuilder: SessionEventStreamEnvelope.create)
    ..aOM<EventStreamEnvelope>(51, _omitFieldNames ? '' : 'eventStream',
        subBuilder: EventStreamEnvelope.create)
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
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
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
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
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

  @$pb.TagNumber(30)
  ListSessionsRequest get listSessionsRequest => $_getN(6);
  @$pb.TagNumber(30)
  set listSessionsRequest(ListSessionsRequest value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasListSessionsRequest() => $_has(6);
  @$pb.TagNumber(30)
  void clearListSessionsRequest() => $_clearField(30);
  @$pb.TagNumber(30)
  ListSessionsRequest ensureListSessionsRequest() => $_ensure(6);

  @$pb.TagNumber(31)
  ListSessionsResponse get listSessionsResponse => $_getN(7);
  @$pb.TagNumber(31)
  set listSessionsResponse(ListSessionsResponse value) => $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasListSessionsResponse() => $_has(7);
  @$pb.TagNumber(31)
  void clearListSessionsResponse() => $_clearField(31);
  @$pb.TagNumber(31)
  ListSessionsResponse ensureListSessionsResponse() => $_ensure(7);

  @$pb.TagNumber(32)
  GetSessionRequest get getSessionRequest => $_getN(8);
  @$pb.TagNumber(32)
  set getSessionRequest(GetSessionRequest value) => $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasGetSessionRequest() => $_has(8);
  @$pb.TagNumber(32)
  void clearGetSessionRequest() => $_clearField(32);
  @$pb.TagNumber(32)
  GetSessionRequest ensureGetSessionRequest() => $_ensure(8);

  @$pb.TagNumber(33)
  GetSessionResponse get getSessionResponse => $_getN(9);
  @$pb.TagNumber(33)
  set getSessionResponse(GetSessionResponse value) => $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasGetSessionResponse() => $_has(9);
  @$pb.TagNumber(33)
  void clearGetSessionResponse() => $_clearField(33);
  @$pb.TagNumber(33)
  GetSessionResponse ensureGetSessionResponse() => $_ensure(9);

  @$pb.TagNumber(34)
  CreateSessionRequest get createSessionRequest => $_getN(10);
  @$pb.TagNumber(34)
  set createSessionRequest(CreateSessionRequest value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasCreateSessionRequest() => $_has(10);
  @$pb.TagNumber(34)
  void clearCreateSessionRequest() => $_clearField(34);
  @$pb.TagNumber(34)
  CreateSessionRequest ensureCreateSessionRequest() => $_ensure(10);

  @$pb.TagNumber(35)
  CreateSessionResponse get createSessionResponse => $_getN(11);
  @$pb.TagNumber(35)
  set createSessionResponse(CreateSessionResponse value) =>
      $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasCreateSessionResponse() => $_has(11);
  @$pb.TagNumber(35)
  void clearCreateSessionResponse() => $_clearField(35);
  @$pb.TagNumber(35)
  CreateSessionResponse ensureCreateSessionResponse() => $_ensure(11);

  @$pb.TagNumber(36)
  PromptCommand get promptCommand => $_getN(12);
  @$pb.TagNumber(36)
  set promptCommand(PromptCommand value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasPromptCommand() => $_has(12);
  @$pb.TagNumber(36)
  void clearPromptCommand() => $_clearField(36);
  @$pb.TagNumber(36)
  PromptCommand ensurePromptCommand() => $_ensure(12);

  @$pb.TagNumber(37)
  AbortCommand get abortCommand => $_getN(13);
  @$pb.TagNumber(37)
  set abortCommand(AbortCommand value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasAbortCommand() => $_has(13);
  @$pb.TagNumber(37)
  void clearAbortCommand() => $_clearField(37);
  @$pb.TagNumber(37)
  AbortCommand ensureAbortCommand() => $_ensure(13);

  @$pb.TagNumber(38)
  RequestRejected get requestRejected => $_getN(14);
  @$pb.TagNumber(38)
  set requestRejected(RequestRejected value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasRequestRejected() => $_has(14);
  @$pb.TagNumber(38)
  void clearRequestRejected() => $_clearField(38);
  @$pb.TagNumber(38)
  RequestRejected ensureRequestRejected() => $_ensure(14);

  @$pb.TagNumber(39)
  CommandAccepted get commandAccepted => $_getN(15);
  @$pb.TagNumber(39)
  set commandAccepted(CommandAccepted value) => $_setField(39, value);
  @$pb.TagNumber(39)
  $core.bool hasCommandAccepted() => $_has(15);
  @$pb.TagNumber(39)
  void clearCommandAccepted() => $_clearField(39);
  @$pb.TagNumber(39)
  CommandAccepted ensureCommandAccepted() => $_ensure(15);

  @$pb.TagNumber(40)
  CommandRejected get commandRejected => $_getN(16);
  @$pb.TagNumber(40)
  set commandRejected(CommandRejected value) => $_setField(40, value);
  @$pb.TagNumber(40)
  $core.bool hasCommandRejected() => $_has(16);
  @$pb.TagNumber(40)
  void clearCommandRejected() => $_clearField(40);
  @$pb.TagNumber(40)
  CommandRejected ensureCommandRejected() => $_ensure(16);

  @$pb.TagNumber(50)
  SessionEventStreamEnvelope get sessionEventStream => $_getN(17);
  @$pb.TagNumber(50)
  set sessionEventStream(SessionEventStreamEnvelope value) =>
      $_setField(50, value);
  @$pb.TagNumber(50)
  $core.bool hasSessionEventStream() => $_has(17);
  @$pb.TagNumber(50)
  void clearSessionEventStream() => $_clearField(50);
  @$pb.TagNumber(50)
  SessionEventStreamEnvelope ensureSessionEventStream() => $_ensure(17);

  @$pb.TagNumber(51)
  EventStreamEnvelope get eventStream => $_getN(18);
  @$pb.TagNumber(51)
  set eventStream(EventStreamEnvelope value) => $_setField(51, value);
  @$pb.TagNumber(51)
  $core.bool hasEventStream() => $_has(18);
  @$pb.TagNumber(51)
  void clearEventStream() => $_clearField(51);
  @$pb.TagNumber(51)
  EventStreamEnvelope ensureEventStream() => $_ensure(18);

  @$pb.TagNumber(60)
  Cancel get cancel => $_getN(19);
  @$pb.TagNumber(60)
  set cancel(Cancel value) => $_setField(60, value);
  @$pb.TagNumber(60)
  $core.bool hasCancel() => $_has(19);
  @$pb.TagNumber(60)
  void clearCancel() => $_clearField(60);
  @$pb.TagNumber(60)
  Cancel ensureCancel() => $_ensure(19);

  @$pb.TagNumber(61)
  WindowUpdate get windowUpdate => $_getN(20);
  @$pb.TagNumber(61)
  set windowUpdate(WindowUpdate value) => $_setField(61, value);
  @$pb.TagNumber(61)
  $core.bool hasWindowUpdate() => $_has(20);
  @$pb.TagNumber(61)
  void clearWindowUpdate() => $_clearField(61);
  @$pb.TagNumber(61)
  WindowUpdate ensureWindowUpdate() => $_ensure(20);

  @$pb.TagNumber(70)
  TransferOpen get transferOpen => $_getN(21);
  @$pb.TagNumber(70)
  set transferOpen(TransferOpen value) => $_setField(70, value);
  @$pb.TagNumber(70)
  $core.bool hasTransferOpen() => $_has(21);
  @$pb.TagNumber(70)
  void clearTransferOpen() => $_clearField(70);
  @$pb.TagNumber(70)
  TransferOpen ensureTransferOpen() => $_ensure(21);

  @$pb.TagNumber(71)
  TransferChunk get transferChunk => $_getN(22);
  @$pb.TagNumber(71)
  set transferChunk(TransferChunk value) => $_setField(71, value);
  @$pb.TagNumber(71)
  $core.bool hasTransferChunk() => $_has(22);
  @$pb.TagNumber(71)
  void clearTransferChunk() => $_clearField(71);
  @$pb.TagNumber(71)
  TransferChunk ensureTransferChunk() => $_ensure(22);

  @$pb.TagNumber(72)
  TransferAck get transferAck => $_getN(23);
  @$pb.TagNumber(72)
  set transferAck(TransferAck value) => $_setField(72, value);
  @$pb.TagNumber(72)
  $core.bool hasTransferAck() => $_has(23);
  @$pb.TagNumber(72)
  void clearTransferAck() => $_clearField(72);
  @$pb.TagNumber(72)
  TransferAck ensureTransferAck() => $_ensure(23);

  @$pb.TagNumber(73)
  TransferComplete get transferComplete => $_getN(24);
  @$pb.TagNumber(73)
  set transferComplete(TransferComplete value) => $_setField(73, value);
  @$pb.TagNumber(73)
  $core.bool hasTransferComplete() => $_has(24);
  @$pb.TagNumber(73)
  void clearTransferComplete() => $_clearField(73);
  @$pb.TagNumber(73)
  TransferComplete ensureTransferComplete() => $_ensure(24);

  @$pb.TagNumber(74)
  TransferAbort get transferAbort => $_getN(25);
  @$pb.TagNumber(74)
  set transferAbort(TransferAbort value) => $_setField(74, value);
  @$pb.TagNumber(74)
  $core.bool hasTransferAbort() => $_has(25);
  @$pb.TagNumber(74)
  void clearTransferAbort() => $_clearField(74);
  @$pb.TagNumber(74)
  TransferAbort ensureTransferAbort() => $_ensure(25);

  @$pb.TagNumber(80)
  ErrorEnvelope get error => $_getN(26);
  @$pb.TagNumber(80)
  set error(ErrorEnvelope value) => $_setField(80, value);
  @$pb.TagNumber(80)
  $core.bool hasError() => $_has(26);
  @$pb.TagNumber(80)
  void clearError() => $_clearField(80);
  @$pb.TagNumber(80)
  ErrorEnvelope ensureError() => $_ensure(26);
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

class ListSessionsRequest extends $pb.GeneratedMessage {
  factory ListSessionsRequest({
    $fixnum.Int64? requestId,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
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
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (sessionId != null) result.sessionId = sessionId;
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
    $core.String? workingDirectory,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (workingDirectory != null) result.workingDirectory = workingDirectory;
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
    ..aOS(2, _omitFieldNames ? '' : 'workingDirectory')
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
  $core.String get workingDirectory => $_getSZ(1);
  @$pb.TagNumber(2)
  set workingDirectory($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWorkingDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkingDirectory() => $_clearField(2);
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
