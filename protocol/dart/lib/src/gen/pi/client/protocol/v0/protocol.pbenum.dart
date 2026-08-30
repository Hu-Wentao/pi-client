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

class Capability extends $pb.ProtobufEnum {
  static const Capability CAPABILITY_UNSPECIFIED =
      Capability._(0, _omitEnumNames ? '' : 'CAPABILITY_UNSPECIFIED');
  static const Capability CAPABILITY_SESSION_READ =
      Capability._(1, _omitEnumNames ? '' : 'CAPABILITY_SESSION_READ');
  static const Capability CAPABILITY_SESSION_CREATE =
      Capability._(2, _omitEnumNames ? '' : 'CAPABILITY_SESSION_CREATE');
  static const Capability CAPABILITY_PROMPT_COMMAND =
      Capability._(3, _omitEnumNames ? '' : 'CAPABILITY_PROMPT_COMMAND');
  static const Capability CAPABILITY_ABORT_COMMAND =
      Capability._(4, _omitEnumNames ? '' : 'CAPABILITY_ABORT_COMMAND');
  static const Capability CAPABILITY_SESSION_EVENTS =
      Capability._(5, _omitEnumNames ? '' : 'CAPABILITY_SESSION_EVENTS');
  static const Capability CAPABILITY_HEALTH =
      Capability._(6, _omitEnumNames ? '' : 'CAPABILITY_HEALTH');
  static const Capability CAPABILITY_CANCELLATION =
      Capability._(7, _omitEnumNames ? '' : 'CAPABILITY_CANCELLATION');
  static const Capability CAPABILITY_FLOW_CONTROL =
      Capability._(8, _omitEnumNames ? '' : 'CAPABILITY_FLOW_CONTROL');
  static const Capability CAPABILITY_TRANSFER =
      Capability._(9, _omitEnumNames ? '' : 'CAPABILITY_TRANSFER');
  static const Capability CAPABILITY_PROJECT_DISCOVERY =
      Capability._(10, _omitEnumNames ? '' : 'CAPABILITY_PROJECT_DISCOVERY');
  static const Capability CAPABILITY_PROJECT_TRUST =
      Capability._(11, _omitEnumNames ? '' : 'CAPABILITY_PROJECT_TRUST');

  static const $core.List<Capability> values = <Capability>[
    CAPABILITY_UNSPECIFIED,
    CAPABILITY_SESSION_READ,
    CAPABILITY_SESSION_CREATE,
    CAPABILITY_PROMPT_COMMAND,
    CAPABILITY_ABORT_COMMAND,
    CAPABILITY_SESSION_EVENTS,
    CAPABILITY_HEALTH,
    CAPABILITY_CANCELLATION,
    CAPABILITY_FLOW_CONTROL,
    CAPABILITY_TRANSFER,
    CAPABILITY_PROJECT_DISCOVERY,
    CAPABILITY_PROJECT_TRUST,
  ];

  static final $core.List<Capability?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 11);
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

class ProjectTrustStatus extends $pb.ProtobufEnum {
  static const ProjectTrustStatus PROJECT_TRUST_STATUS_UNSPECIFIED =
      ProjectTrustStatus._(
          0, _omitEnumNames ? '' : 'PROJECT_TRUST_STATUS_UNSPECIFIED');
  static const ProjectTrustStatus PROJECT_TRUST_STATUS_NOT_REQUIRED =
      ProjectTrustStatus._(
          1, _omitEnumNames ? '' : 'PROJECT_TRUST_STATUS_NOT_REQUIRED');
  static const ProjectTrustStatus PROJECT_TRUST_STATUS_TRUSTED =
      ProjectTrustStatus._(
          2, _omitEnumNames ? '' : 'PROJECT_TRUST_STATUS_TRUSTED');
  static const ProjectTrustStatus PROJECT_TRUST_STATUS_APPROVAL_REQUIRED =
      ProjectTrustStatus._(
          3, _omitEnumNames ? '' : 'PROJECT_TRUST_STATUS_APPROVAL_REQUIRED');
  static const ProjectTrustStatus PROJECT_TRUST_STATUS_DENIED =
      ProjectTrustStatus._(
          4, _omitEnumNames ? '' : 'PROJECT_TRUST_STATUS_DENIED');

  static const $core.List<ProjectTrustStatus> values = <ProjectTrustStatus>[
    PROJECT_TRUST_STATUS_UNSPECIFIED,
    PROJECT_TRUST_STATUS_NOT_REQUIRED,
    PROJECT_TRUST_STATUS_TRUSTED,
    PROJECT_TRUST_STATUS_APPROVAL_REQUIRED,
    PROJECT_TRUST_STATUS_DENIED,
  ];

  static final $core.List<ProjectTrustStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ProjectTrustStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProjectTrustStatus._(super.value, super.name);
}

class ProjectTrustReason extends $pb.ProtobufEnum {
  static const ProjectTrustReason PROJECT_TRUST_REASON_UNSPECIFIED =
      ProjectTrustReason._(
          0, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_UNSPECIFIED');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_SETTINGS =
      ProjectTrustReason._(
          1, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_SETTINGS');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_EXTENSIONS =
      ProjectTrustReason._(
          2, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_EXTENSIONS');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_SKILLS =
      ProjectTrustReason._(
          3, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_SKILLS');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_PROMPTS =
      ProjectTrustReason._(
          4, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_PROMPTS');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_THEMES =
      ProjectTrustReason._(
          5, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_THEMES');
  static const ProjectTrustReason PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT =
      ProjectTrustReason._(
          6, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT');
  static const ProjectTrustReason PROJECT_TRUST_REASON_AGENT_SKILLS =
      ProjectTrustReason._(
          7, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_AGENT_SKILLS');
  static const ProjectTrustReason PROJECT_TRUST_REASON_SAVED_APPROVAL =
      ProjectTrustReason._(
          8, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_SAVED_APPROVAL');
  static const ProjectTrustReason PROJECT_TRUST_REASON_SAVED_DENIAL =
      ProjectTrustReason._(
          9, _omitEnumNames ? '' : 'PROJECT_TRUST_REASON_SAVED_DENIAL');

  static const $core.List<ProjectTrustReason> values = <ProjectTrustReason>[
    PROJECT_TRUST_REASON_UNSPECIFIED,
    PROJECT_TRUST_REASON_PI_SETTINGS,
    PROJECT_TRUST_REASON_PI_EXTENSIONS,
    PROJECT_TRUST_REASON_PI_SKILLS,
    PROJECT_TRUST_REASON_PI_PROMPTS,
    PROJECT_TRUST_REASON_PI_THEMES,
    PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT,
    PROJECT_TRUST_REASON_AGENT_SKILLS,
    PROJECT_TRUST_REASON_SAVED_APPROVAL,
    PROJECT_TRUST_REASON_SAVED_DENIAL,
  ];

  static final $core.List<ProjectTrustReason?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static ProjectTrustReason? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProjectTrustReason._(super.value, super.name);
}

class MessageRole extends $pb.ProtobufEnum {
  static const MessageRole MESSAGE_ROLE_UNSPECIFIED =
      MessageRole._(0, _omitEnumNames ? '' : 'MESSAGE_ROLE_UNSPECIFIED');
  static const MessageRole MESSAGE_ROLE_USER =
      MessageRole._(1, _omitEnumNames ? '' : 'MESSAGE_ROLE_USER');
  static const MessageRole MESSAGE_ROLE_ASSISTANT =
      MessageRole._(2, _omitEnumNames ? '' : 'MESSAGE_ROLE_ASSISTANT');
  static const MessageRole MESSAGE_ROLE_TOOL =
      MessageRole._(3, _omitEnumNames ? '' : 'MESSAGE_ROLE_TOOL');
  static const MessageRole MESSAGE_ROLE_SYSTEM =
      MessageRole._(4, _omitEnumNames ? '' : 'MESSAGE_ROLE_SYSTEM');

  static const $core.List<MessageRole> values = <MessageRole>[
    MESSAGE_ROLE_UNSPECIFIED,
    MESSAGE_ROLE_USER,
    MESSAGE_ROLE_ASSISTANT,
    MESSAGE_ROLE_TOOL,
    MESSAGE_ROLE_SYSTEM,
  ];

  static final $core.List<MessageRole?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MessageRole? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageRole._(super.value, super.name);
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

/// ErrorCode maps to the hand-written Flutter semantic error boundary. Unknown
/// numeric enum values are protocol violations rather than remote rejections.
class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_CODE_UNSPECIFIED =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_CODE_UNSPECIFIED');
  static const ErrorCode ERROR_CODE_AUTHENTICATION_REQUIRED = ErrorCode._(
      1, _omitEnumNames ? '' : 'ERROR_CODE_AUTHENTICATION_REQUIRED');
  static const ErrorCode ERROR_CODE_PERMISSION_DENIED =
      ErrorCode._(2, _omitEnumNames ? '' : 'ERROR_CODE_PERMISSION_DENIED');
  static const ErrorCode ERROR_CODE_NOT_FOUND =
      ErrorCode._(3, _omitEnumNames ? '' : 'ERROR_CODE_NOT_FOUND');
  static const ErrorCode ERROR_CODE_INVALID_REQUEST =
      ErrorCode._(4, _omitEnumNames ? '' : 'ERROR_CODE_INVALID_REQUEST');
  static const ErrorCode ERROR_CODE_CONFLICT =
      ErrorCode._(5, _omitEnumNames ? '' : 'ERROR_CODE_CONFLICT');
  static const ErrorCode ERROR_CODE_NODE_BUSY =
      ErrorCode._(6, _omitEnumNames ? '' : 'ERROR_CODE_NODE_BUSY');
  static const ErrorCode ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED = ErrorCode._(
      7, _omitEnumNames ? '' : 'ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED');
  static const ErrorCode ERROR_CODE_CANCELLED =
      ErrorCode._(8, _omitEnumNames ? '' : 'ERROR_CODE_CANCELLED');
  static const ErrorCode ERROR_CODE_DEADLINE_EXCEEDED =
      ErrorCode._(9, _omitEnumNames ? '' : 'ERROR_CODE_DEADLINE_EXCEEDED');
  static const ErrorCode ERROR_CODE_UNAVAILABLE =
      ErrorCode._(10, _omitEnumNames ? '' : 'ERROR_CODE_UNAVAILABLE');
  static const ErrorCode ERROR_CODE_DATA_LOSS =
      ErrorCode._(11, _omitEnumNames ? '' : 'ERROR_CODE_DATA_LOSS');
  static const ErrorCode ERROR_CODE_INTERNAL =
      ErrorCode._(12, _omitEnumNames ? '' : 'ERROR_CODE_INTERNAL');
  static const ErrorCode ERROR_CODE_PROTOCOL_VIOLATION =
      ErrorCode._(13, _omitEnumNames ? '' : 'ERROR_CODE_PROTOCOL_VIOLATION');
  static const ErrorCode ERROR_CODE_RESOURCE_EXHAUSTED =
      ErrorCode._(14, _omitEnumNames ? '' : 'ERROR_CODE_RESOURCE_EXHAUSTED');
  static const ErrorCode ERROR_CODE_ALREADY_EXISTS =
      ErrorCode._(15, _omitEnumNames ? '' : 'ERROR_CODE_ALREADY_EXISTS');
  static const ErrorCode ERROR_CODE_FAILED_PRECONDITION =
      ErrorCode._(16, _omitEnumNames ? '' : 'ERROR_CODE_FAILED_PRECONDITION');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_CODE_UNSPECIFIED,
    ERROR_CODE_AUTHENTICATION_REQUIRED,
    ERROR_CODE_PERMISSION_DENIED,
    ERROR_CODE_NOT_FOUND,
    ERROR_CODE_INVALID_REQUEST,
    ERROR_CODE_CONFLICT,
    ERROR_CODE_NODE_BUSY,
    ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED,
    ERROR_CODE_CANCELLED,
    ERROR_CODE_DEADLINE_EXCEEDED,
    ERROR_CODE_UNAVAILABLE,
    ERROR_CODE_DATA_LOSS,
    ERROR_CODE_INTERNAL,
    ERROR_CODE_PROTOCOL_VIOLATION,
    ERROR_CODE_RESOURCE_EXHAUSTED,
    ERROR_CODE_ALREADY_EXISTS,
    ERROR_CODE_FAILED_PRECONDITION,
  ];

  static final $core.List<ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 16);
  static ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
