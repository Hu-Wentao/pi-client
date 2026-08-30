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
  bootstrapHello,
  healthRequest,
  healthResponse,
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

/// PiTransportFrame is the single public Protobuf wire envelope. Multiplexing
/// identifiers remain flat scalar fields on typed operations.
class PiTransportFrame extends $pb.GeneratedMessage {
  factory PiTransportFrame({
    $fixnum.Int64? frameSequence,
    BootstrapHello? bootstrapHello,
    HealthRequest? healthRequest,
    HealthResponse? healthResponse,
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
    if (bootstrapHello != null) result.bootstrapHello = bootstrapHello;
    if (healthRequest != null) result.healthRequest = healthRequest;
    if (healthResponse != null) result.healthResponse = healthResponse;
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
    10: PiTransportFrame_Operation.bootstrapHello,
    11: PiTransportFrame_Operation.healthRequest,
    12: PiTransportFrame_Operation.healthResponse,
    13: PiTransportFrame_Operation.eventStream,
    14: PiTransportFrame_Operation.cancel,
    15: PiTransportFrame_Operation.windowUpdate,
    16: PiTransportFrame_Operation.transferOpen,
    17: PiTransportFrame_Operation.transferChunk,
    18: PiTransportFrame_Operation.transferAck,
    19: PiTransportFrame_Operation.transferComplete,
    20: PiTransportFrame_Operation.transferAbort,
    21: PiTransportFrame_Operation.error,
    0: PiTransportFrame_Operation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PiTransportFrame',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21])
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'frameSequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<BootstrapHello>(10, _omitFieldNames ? '' : 'bootstrapHello',
        subBuilder: BootstrapHello.create)
    ..aOM<HealthRequest>(11, _omitFieldNames ? '' : 'healthRequest',
        subBuilder: HealthRequest.create)
    ..aOM<HealthResponse>(12, _omitFieldNames ? '' : 'healthResponse',
        subBuilder: HealthResponse.create)
    ..aOM<EventStreamEnvelope>(13, _omitFieldNames ? '' : 'eventStream',
        subBuilder: EventStreamEnvelope.create)
    ..aOM<Cancel>(14, _omitFieldNames ? '' : 'cancel',
        subBuilder: Cancel.create)
    ..aOM<WindowUpdate>(15, _omitFieldNames ? '' : 'windowUpdate',
        subBuilder: WindowUpdate.create)
    ..aOM<TransferOpen>(16, _omitFieldNames ? '' : 'transferOpen',
        subBuilder: TransferOpen.create)
    ..aOM<TransferChunk>(17, _omitFieldNames ? '' : 'transferChunk',
        subBuilder: TransferChunk.create)
    ..aOM<TransferAck>(18, _omitFieldNames ? '' : 'transferAck',
        subBuilder: TransferAck.create)
    ..aOM<TransferComplete>(19, _omitFieldNames ? '' : 'transferComplete',
        subBuilder: TransferComplete.create)
    ..aOM<TransferAbort>(20, _omitFieldNames ? '' : 'transferAbort',
        subBuilder: TransferAbort.create)
    ..aOM<ErrorEnvelope>(21, _omitFieldNames ? '' : 'error',
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
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  PiTransportFrame_Operation whichOperation() =>
      _PiTransportFrame_OperationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
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
  BootstrapHello get bootstrapHello => $_getN(1);
  @$pb.TagNumber(10)
  set bootstrapHello(BootstrapHello value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBootstrapHello() => $_has(1);
  @$pb.TagNumber(10)
  void clearBootstrapHello() => $_clearField(10);
  @$pb.TagNumber(10)
  BootstrapHello ensureBootstrapHello() => $_ensure(1);

  @$pb.TagNumber(11)
  HealthRequest get healthRequest => $_getN(2);
  @$pb.TagNumber(11)
  set healthRequest(HealthRequest value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasHealthRequest() => $_has(2);
  @$pb.TagNumber(11)
  void clearHealthRequest() => $_clearField(11);
  @$pb.TagNumber(11)
  HealthRequest ensureHealthRequest() => $_ensure(2);

  @$pb.TagNumber(12)
  HealthResponse get healthResponse => $_getN(3);
  @$pb.TagNumber(12)
  set healthResponse(HealthResponse value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasHealthResponse() => $_has(3);
  @$pb.TagNumber(12)
  void clearHealthResponse() => $_clearField(12);
  @$pb.TagNumber(12)
  HealthResponse ensureHealthResponse() => $_ensure(3);

  @$pb.TagNumber(13)
  EventStreamEnvelope get eventStream => $_getN(4);
  @$pb.TagNumber(13)
  set eventStream(EventStreamEnvelope value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasEventStream() => $_has(4);
  @$pb.TagNumber(13)
  void clearEventStream() => $_clearField(13);
  @$pb.TagNumber(13)
  EventStreamEnvelope ensureEventStream() => $_ensure(4);

  @$pb.TagNumber(14)
  Cancel get cancel => $_getN(5);
  @$pb.TagNumber(14)
  set cancel(Cancel value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCancel() => $_has(5);
  @$pb.TagNumber(14)
  void clearCancel() => $_clearField(14);
  @$pb.TagNumber(14)
  Cancel ensureCancel() => $_ensure(5);

  @$pb.TagNumber(15)
  WindowUpdate get windowUpdate => $_getN(6);
  @$pb.TagNumber(15)
  set windowUpdate(WindowUpdate value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasWindowUpdate() => $_has(6);
  @$pb.TagNumber(15)
  void clearWindowUpdate() => $_clearField(15);
  @$pb.TagNumber(15)
  WindowUpdate ensureWindowUpdate() => $_ensure(6);

  @$pb.TagNumber(16)
  TransferOpen get transferOpen => $_getN(7);
  @$pb.TagNumber(16)
  set transferOpen(TransferOpen value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasTransferOpen() => $_has(7);
  @$pb.TagNumber(16)
  void clearTransferOpen() => $_clearField(16);
  @$pb.TagNumber(16)
  TransferOpen ensureTransferOpen() => $_ensure(7);

  @$pb.TagNumber(17)
  TransferChunk get transferChunk => $_getN(8);
  @$pb.TagNumber(17)
  set transferChunk(TransferChunk value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasTransferChunk() => $_has(8);
  @$pb.TagNumber(17)
  void clearTransferChunk() => $_clearField(17);
  @$pb.TagNumber(17)
  TransferChunk ensureTransferChunk() => $_ensure(8);

  @$pb.TagNumber(18)
  TransferAck get transferAck => $_getN(9);
  @$pb.TagNumber(18)
  set transferAck(TransferAck value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasTransferAck() => $_has(9);
  @$pb.TagNumber(18)
  void clearTransferAck() => $_clearField(18);
  @$pb.TagNumber(18)
  TransferAck ensureTransferAck() => $_ensure(9);

  @$pb.TagNumber(19)
  TransferComplete get transferComplete => $_getN(10);
  @$pb.TagNumber(19)
  set transferComplete(TransferComplete value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasTransferComplete() => $_has(10);
  @$pb.TagNumber(19)
  void clearTransferComplete() => $_clearField(19);
  @$pb.TagNumber(19)
  TransferComplete ensureTransferComplete() => $_ensure(10);

  @$pb.TagNumber(20)
  TransferAbort get transferAbort => $_getN(11);
  @$pb.TagNumber(20)
  set transferAbort(TransferAbort value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasTransferAbort() => $_has(11);
  @$pb.TagNumber(20)
  void clearTransferAbort() => $_clearField(20);
  @$pb.TagNumber(20)
  TransferAbort ensureTransferAbort() => $_ensure(11);

  @$pb.TagNumber(21)
  ErrorEnvelope get error => $_getN(12);
  @$pb.TagNumber(21)
  set error(ErrorEnvelope value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasError() => $_has(12);
  @$pb.TagNumber(21)
  void clearError() => $_clearField(21);
  @$pb.TagNumber(21)
  ErrorEnvelope ensureError() => $_ensure(12);
}

class BootstrapHello extends $pb.GeneratedMessage {
  factory BootstrapHello({
    $core.String? connectionId,
    $core.String? peerId,
    PeerRole? role,
    $core.int? protocolMajor,
    $core.int? protocolMinor,
    $core.String? implementationName,
    $core.String? implementationVersion,
    $core.int? maxFrameBytes,
    $core.int? maxTransferChunkBytes,
    $core.Iterable<Capability>? capabilities,
  }) {
    final result = create();
    if (connectionId != null) result.connectionId = connectionId;
    if (peerId != null) result.peerId = peerId;
    if (role != null) result.role = role;
    if (protocolMajor != null) result.protocolMajor = protocolMajor;
    if (protocolMinor != null) result.protocolMinor = protocolMinor;
    if (implementationName != null)
      result.implementationName = implementationName;
    if (implementationVersion != null)
      result.implementationVersion = implementationVersion;
    if (maxFrameBytes != null) result.maxFrameBytes = maxFrameBytes;
    if (maxTransferChunkBytes != null)
      result.maxTransferChunkBytes = maxTransferChunkBytes;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    return result;
  }

  BootstrapHello._();

  factory BootstrapHello.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BootstrapHello.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BootstrapHello',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'pi.client.protocol.v0'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connectionId')
    ..aOS(2, _omitFieldNames ? '' : 'peerId')
    ..aE<PeerRole>(3, _omitFieldNames ? '' : 'role',
        enumValues: PeerRole.values)
    ..aI(4, _omitFieldNames ? '' : 'protocolMajor',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'protocolMinor',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'implementationName')
    ..aOS(7, _omitFieldNames ? '' : 'implementationVersion')
    ..aI(8, _omitFieldNames ? '' : 'maxFrameBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'maxTransferChunkBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..pc<Capability>(
        10, _omitFieldNames ? '' : 'capabilities', $pb.PbFieldType.KE,
        valueOf: Capability.valueOf,
        enumValues: Capability.values,
        defaultEnumValue: Capability.CAPABILITY_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BootstrapHello clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BootstrapHello copyWith(void Function(BootstrapHello) updates) =>
      super.copyWith((message) => updates(message as BootstrapHello))
          as BootstrapHello;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BootstrapHello create() => BootstrapHello._();
  @$core.override
  BootstrapHello createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BootstrapHello getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BootstrapHello>(create);
  static BootstrapHello? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get connectionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set connectionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnectionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnectionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get peerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set peerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerId() => $_clearField(2);

  @$pb.TagNumber(3)
  PeerRole get role => $_getN(2);
  @$pb.TagNumber(3)
  set role(PeerRole value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get protocolMajor => $_getIZ(3);
  @$pb.TagNumber(4)
  set protocolMajor($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocolMajor() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocolMajor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get protocolMinor => $_getIZ(4);
  @$pb.TagNumber(5)
  set protocolMinor($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProtocolMinor() => $_has(4);
  @$pb.TagNumber(5)
  void clearProtocolMinor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get implementationName => $_getSZ(5);
  @$pb.TagNumber(6)
  set implementationName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImplementationName() => $_has(5);
  @$pb.TagNumber(6)
  void clearImplementationName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get implementationVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set implementationVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasImplementationVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearImplementationVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxFrameBytes => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxFrameBytes($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxFrameBytes() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxFrameBytes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get maxTransferChunkBytes => $_getIZ(8);
  @$pb.TagNumber(9)
  set maxTransferChunkBytes($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxTransferChunkBytes() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxTransferChunkBytes() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<Capability> get capabilities => $_getList(9);
}

class HealthRequest extends $pb.GeneratedMessage {
  factory HealthRequest({
    $core.String? requestId,
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
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
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
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
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
    $core.String? requestId,
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
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
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
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
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

enum EventStreamEnvelope_Event {
  heartbeat,
  healthStatusChanged,
  streamClosed,
  notSet
}

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
    $core.String? requestId,
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
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
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
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
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
    $core.String? message,
    $core.bool? retryable,
    $core.int? retryAfterMillis,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (retryable != null) result.retryable = retryable;
    if (retryAfterMillis != null) result.retryAfterMillis = retryAfterMillis;
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
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOB(3, _omitFieldNames ? '' : 'retryable')
    ..aI(4, _omitFieldNames ? '' : 'retryAfterMillis',
        fieldType: $pb.PbFieldType.OU3)
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
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get retryable => $_getBF(2);
  @$pb.TagNumber(3)
  set retryable($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRetryable() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetryable() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get retryAfterMillis => $_getIZ(3);
  @$pb.TagNumber(4)
  set retryAfterMillis($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRetryAfterMillis() => $_has(3);
  @$pb.TagNumber(4)
  void clearRetryAfterMillis() => $_clearField(4);
}

enum ErrorEnvelope_Correlation { requestId, streamId, transferId, notSet }

class ErrorEnvelope extends $pb.GeneratedMessage {
  factory ErrorEnvelope({
    $core.String? requestId,
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
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
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
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
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
