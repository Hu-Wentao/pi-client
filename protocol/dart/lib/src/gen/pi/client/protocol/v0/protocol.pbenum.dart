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

import 'package:protobuf/protobuf.dart' as $pb;

class PeerRole extends $pb.ProtobufEnum {
  static const PeerRole PEER_ROLE_UNSPECIFIED =
      PeerRole._(0, _omitEnumNames ? '' : 'PEER_ROLE_UNSPECIFIED');
  static const PeerRole PEER_ROLE_CLIENT =
      PeerRole._(1, _omitEnumNames ? '' : 'PEER_ROLE_CLIENT');
  static const PeerRole PEER_ROLE_NODE =
      PeerRole._(2, _omitEnumNames ? '' : 'PEER_ROLE_NODE');

  static const $core.List<PeerRole> values = <PeerRole>[
    PEER_ROLE_UNSPECIFIED,
    PEER_ROLE_CLIENT,
    PEER_ROLE_NODE,
  ];

  static final $core.List<PeerRole?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static PeerRole? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PeerRole._(super.value, super.name);
}

class Capability extends $pb.ProtobufEnum {
  static const Capability CAPABILITY_UNSPECIFIED =
      Capability._(0, _omitEnumNames ? '' : 'CAPABILITY_UNSPECIFIED');
  static const Capability CAPABILITY_HEALTH_UNARY =
      Capability._(1, _omitEnumNames ? '' : 'CAPABILITY_HEALTH_UNARY');
  static const Capability CAPABILITY_EVENT_STREAM =
      Capability._(2, _omitEnumNames ? '' : 'CAPABILITY_EVENT_STREAM');
  static const Capability CAPABILITY_CANCELLATION =
      Capability._(3, _omitEnumNames ? '' : 'CAPABILITY_CANCELLATION');
  static const Capability CAPABILITY_FLOW_CONTROL =
      Capability._(4, _omitEnumNames ? '' : 'CAPABILITY_FLOW_CONTROL');
  static const Capability CAPABILITY_TRANSFER =
      Capability._(5, _omitEnumNames ? '' : 'CAPABILITY_TRANSFER');

  static const $core.List<Capability> values = <Capability>[
    CAPABILITY_UNSPECIFIED,
    CAPABILITY_HEALTH_UNARY,
    CAPABILITY_EVENT_STREAM,
    CAPABILITY_CANCELLATION,
    CAPABILITY_FLOW_CONTROL,
    CAPABILITY_TRANSFER,
  ];

  static final $core.List<Capability?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Capability? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Capability._(super.value, super.name);
}

class HealthStatus extends $pb.ProtobufEnum {
  static const HealthStatus HEALTH_STATUS_UNSPECIFIED =
      HealthStatus._(0, _omitEnumNames ? '' : 'HEALTH_STATUS_UNSPECIFIED');
  static const HealthStatus HEALTH_STATUS_STARTING =
      HealthStatus._(1, _omitEnumNames ? '' : 'HEALTH_STATUS_STARTING');
  static const HealthStatus HEALTH_STATUS_SERVING =
      HealthStatus._(2, _omitEnumNames ? '' : 'HEALTH_STATUS_SERVING');
  static const HealthStatus HEALTH_STATUS_DEGRADED =
      HealthStatus._(3, _omitEnumNames ? '' : 'HEALTH_STATUS_DEGRADED');
  static const HealthStatus HEALTH_STATUS_STOPPING =
      HealthStatus._(4, _omitEnumNames ? '' : 'HEALTH_STATUS_STOPPING');

  static const $core.List<HealthStatus> values = <HealthStatus>[
    HEALTH_STATUS_UNSPECIFIED,
    HEALTH_STATUS_STARTING,
    HEALTH_STATUS_SERVING,
    HEALTH_STATUS_DEGRADED,
    HEALTH_STATUS_STOPPING,
  ];

  static final $core.List<HealthStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static HealthStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HealthStatus._(super.value, super.name);
}

class TransferDirection extends $pb.ProtobufEnum {
  static const TransferDirection TRANSFER_DIRECTION_UNSPECIFIED =
      TransferDirection._(
          0, _omitEnumNames ? '' : 'TRANSFER_DIRECTION_UNSPECIFIED');
  static const TransferDirection TRANSFER_DIRECTION_UPLOAD =
      TransferDirection._(1, _omitEnumNames ? '' : 'TRANSFER_DIRECTION_UPLOAD');
  static const TransferDirection TRANSFER_DIRECTION_DOWNLOAD =
      TransferDirection._(
          2, _omitEnumNames ? '' : 'TRANSFER_DIRECTION_DOWNLOAD');

  static const $core.List<TransferDirection> values = <TransferDirection>[
    TRANSFER_DIRECTION_UNSPECIFIED,
    TRANSFER_DIRECTION_UPLOAD,
    TRANSFER_DIRECTION_DOWNLOAD,
  ];

  static final $core.List<TransferDirection?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static TransferDirection? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TransferDirection._(super.value, super.name);
}

class TransferPurpose extends $pb.ProtobufEnum {
  static const TransferPurpose TRANSFER_PURPOSE_UNSPECIFIED = TransferPurpose._(
      0, _omitEnumNames ? '' : 'TRANSFER_PURPOSE_UNSPECIFIED');
  static const TransferPurpose TRANSFER_PURPOSE_FILE =
      TransferPurpose._(1, _omitEnumNames ? '' : 'TRANSFER_PURPOSE_FILE');
  static const TransferPurpose TRANSFER_PURPOSE_ATTACHMENT =
      TransferPurpose._(2, _omitEnumNames ? '' : 'TRANSFER_PURPOSE_ATTACHMENT');
  static const TransferPurpose TRANSFER_PURPOSE_EXPORT =
      TransferPurpose._(3, _omitEnumNames ? '' : 'TRANSFER_PURPOSE_EXPORT');

  static const $core.List<TransferPurpose> values = <TransferPurpose>[
    TRANSFER_PURPOSE_UNSPECIFIED,
    TRANSFER_PURPOSE_FILE,
    TRANSFER_PURPOSE_ATTACHMENT,
    TRANSFER_PURPOSE_EXPORT,
  ];

  static final $core.List<TransferPurpose?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TransferPurpose? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TransferPurpose._(super.value, super.name);
}

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_CODE_UNSPECIFIED =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_CODE_UNSPECIFIED');
  static const ErrorCode ERROR_CODE_INVALID_ARGUMENT =
      ErrorCode._(1, _omitEnumNames ? '' : 'ERROR_CODE_INVALID_ARGUMENT');
  static const ErrorCode ERROR_CODE_UNAUTHENTICATED =
      ErrorCode._(2, _omitEnumNames ? '' : 'ERROR_CODE_UNAUTHENTICATED');
  static const ErrorCode ERROR_CODE_PERMISSION_DENIED =
      ErrorCode._(3, _omitEnumNames ? '' : 'ERROR_CODE_PERMISSION_DENIED');
  static const ErrorCode ERROR_CODE_NOT_FOUND =
      ErrorCode._(4, _omitEnumNames ? '' : 'ERROR_CODE_NOT_FOUND');
  static const ErrorCode ERROR_CODE_ALREADY_EXISTS =
      ErrorCode._(5, _omitEnumNames ? '' : 'ERROR_CODE_ALREADY_EXISTS');
  static const ErrorCode ERROR_CODE_CONFLICT =
      ErrorCode._(6, _omitEnumNames ? '' : 'ERROR_CODE_CONFLICT');
  static const ErrorCode ERROR_CODE_FAILED_PRECONDITION =
      ErrorCode._(7, _omitEnumNames ? '' : 'ERROR_CODE_FAILED_PRECONDITION');
  static const ErrorCode ERROR_CODE_RESOURCE_EXHAUSTED =
      ErrorCode._(8, _omitEnumNames ? '' : 'ERROR_CODE_RESOURCE_EXHAUSTED');
  static const ErrorCode ERROR_CODE_CANCELLED =
      ErrorCode._(9, _omitEnumNames ? '' : 'ERROR_CODE_CANCELLED');
  static const ErrorCode ERROR_CODE_DEADLINE_EXCEEDED =
      ErrorCode._(10, _omitEnumNames ? '' : 'ERROR_CODE_DEADLINE_EXCEEDED');
  static const ErrorCode ERROR_CODE_UNAVAILABLE =
      ErrorCode._(11, _omitEnumNames ? '' : 'ERROR_CODE_UNAVAILABLE');
  static const ErrorCode ERROR_CODE_DATA_LOSS =
      ErrorCode._(12, _omitEnumNames ? '' : 'ERROR_CODE_DATA_LOSS');
  static const ErrorCode ERROR_CODE_INTERNAL =
      ErrorCode._(13, _omitEnumNames ? '' : 'ERROR_CODE_INTERNAL');
  static const ErrorCode ERROR_CODE_PROTOCOL_VIOLATION =
      ErrorCode._(14, _omitEnumNames ? '' : 'ERROR_CODE_PROTOCOL_VIOLATION');
  static const ErrorCode ERROR_CODE_UNSUPPORTED_VERSION =
      ErrorCode._(15, _omitEnumNames ? '' : 'ERROR_CODE_UNSUPPORTED_VERSION');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_CODE_UNSPECIFIED,
    ERROR_CODE_INVALID_ARGUMENT,
    ERROR_CODE_UNAUTHENTICATED,
    ERROR_CODE_PERMISSION_DENIED,
    ERROR_CODE_NOT_FOUND,
    ERROR_CODE_ALREADY_EXISTS,
    ERROR_CODE_CONFLICT,
    ERROR_CODE_FAILED_PRECONDITION,
    ERROR_CODE_RESOURCE_EXHAUSTED,
    ERROR_CODE_CANCELLED,
    ERROR_CODE_DEADLINE_EXCEEDED,
    ERROR_CODE_UNAVAILABLE,
    ERROR_CODE_DATA_LOSS,
    ERROR_CODE_INTERNAL,
    ERROR_CODE_PROTOCOL_VIOLATION,
    ERROR_CODE_UNSUPPORTED_VERSION,
  ];

  static final $core.List<ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 15);
  static ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
