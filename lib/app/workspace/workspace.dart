import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../api/pi_node/pi_node.dart';
import '../../components/branch_navigator/branch_navigator.dart';
import '../../components/conversation/conversation.dart';
import '../../components/node_connection/node_connection.dart';
import '../../components/project_browser/project_browser.dart';
import '../../components/prompt_composer/prompt_composer.dart';
import '../../components/session_browser/session_browser.dart';
import '../../core/pi_node_composition.dart';
import '../../platform/session_export/session_export_saver.dart';
import 'workspace.srv.dart';

part 'workspace.c.dart';
part 'workspace.v.dart';
part 'workspace.vm.dart';
part 'workspace.freezed.dart';
part 'workspace.g.dart';
